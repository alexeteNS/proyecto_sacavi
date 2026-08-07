use axum::extract::ws::Message;
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::sync::mpsc;
use tokio::time::{Duration, Instant};
use tracing::{error, info};
use uuid::Uuid;

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "snake_case")]
pub enum DeviceEvent {
    GateOpen,
    GateClose,
    GateOpened, // Opcional para confirmación
    GateClosed, // Opcional para confirmación
    Ping,
    Pong,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct DeviceCommand {
    pub event: DeviceEvent,
}

pub struct DeviceConnection {
    pub connection_id: Uuid,
    pub sender: mpsc::Sender<DeviceCommand>,
    pub connected_at: Instant,
    pub last_ping: Instant,
    pub ip: SocketAddr,
    pub active_timer: Option<tokio::task::JoinHandle<()>>,
}

#[derive(Clone)]
pub struct WebSocketManager {
    // Mapa concurrente que asocia el ID del dispositivo con su conexión activa
    pub connections: Arc<DashMap<i64, DeviceConnection>>,
}

impl WebSocketManager {
    pub fn new() -> Self {
        Self {
            connections: Arc::new(DashMap::new()),
        }
    }

    /// Inicia un comprobador de salud en segundo plano para limpiar conexiones colgadas
    pub fn start_health_checker(manager: Arc<Self>) {
        tokio::spawn(async move {
            loop {
                tokio::time::sleep(Duration::from_secs(30)).await;
                let now = Instant::now();
                let mut to_remove = vec![];
                for entry in manager.connections.iter() {
                    // Si pasaron más de 35 segundos sin ping/actividad, asumimos desconexión zombie
                    if now.duration_since(entry.last_ping) > Duration::from_secs(35) {
                        to_remove.push(*entry.key());
                    }
                }
                for id in to_remove {
                    info!("Dispositivo {} desconectado por timeout (zombie)", id);
                    manager.connections.remove(&id);
                }
            }
        });
    }

    /// Registra una nueva conexión para un dispositivo y retorna su ID único
    pub fn add_connection(
        &self,
        device_id: i64,
        sender: mpsc::Sender<DeviceCommand>,
        ip: SocketAddr,
    ) -> Uuid {
        let connection_id = Uuid::new_v4();
        let conn = DeviceConnection {
            connection_id,
            sender,
            connected_at: Instant::now(),
            last_ping: Instant::now(),
            ip,
            active_timer: None,
        };
        self.connections.insert(device_id, conn);
        info!(
            "Dispositivo {} conectado desde {} (Conn ID: {})",
            device_id, ip, connection_id
        );
        connection_id
    }

    /// Elimina una conexión solo si el connection_id coincide, previniendo borrado accidental de reconexiones
    pub fn remove_connection(&self, device_id: i64, connection_id: Uuid) {
        let remove = {
            if let Some(conn) = self.connections.get(&device_id) {
                conn.connection_id == connection_id
            } else {
                false
            }
        };

        if remove {
            if self.connections.remove(&device_id).is_some() {
                info!("Dispositivo {} desconectado exitosamente", device_id);
            }
        }
    }

    /// Actualiza el último ping recibido del dispositivo
    pub fn update_ping(&self, device_id: i64) {
        if let Some(mut conn) = self.connections.get_mut(&device_id) {
            conn.last_ping = Instant::now();
        }
    }

    /// Método principal llamado por AccessService para abrir la pluma
    pub async fn open_gate(&self, device_id: i64) -> Result<(), String> {
        let (sender, connection_id) = {
            let mut conn = self
                .connections
                .get_mut(&device_id)
                .ok_or_else(|| format!("Dispositivo {} no está conectado", device_id))?;

            // Abortar el temporizador de cierre si existía previamente (simultaneous scans)
            if let Some(timer) = conn.active_timer.take() {
                timer.abort();
                info!("Cancelando cierre anterior para dispositivo {}", device_id);
            }

            (conn.sender.clone(), conn.connection_id)
        };

        let cmd_open = DeviceCommand {
            event: DeviceEvent::GateOpen,
        };

        // Enviar evento de abrir
        if sender.send(cmd_open).await.is_err() {
            error!("Error al enviar el comando GateOpen al socket (canal roto).");
            self.remove_connection(device_id, connection_id);
            return Err("Error enviando comando al ESP32 (conexión rota)".to_string());
        }

        // Crear una nueva tarea en background para cerrar después de 10 segundos
        let ws_manager = self.clone();
        let new_timer = tokio::spawn(async move {
            tokio::time::sleep(Duration::from_secs(5)).await;

            let cmd_close = DeviceCommand {
                event: DeviceEvent::GateClose,
            };

            // Extraemos el sender en un bloque síncrono para NO retener el lock del DashMap durante el .await
            let sender_opt = {
                if let Some(conn) = ws_manager.connections.get(&device_id) {
                    if conn.connection_id == connection_id {
                        Some(conn.sender.clone())
                    } else {
                        None
                    }
                } else {
                    None
                }
            };

            if let Some(sender) = sender_opt {
                if sender.send(cmd_close).await.is_err() {
                    error!("Fallo enviando GateClose al dispositivo {}.", device_id);
                    ws_manager.remove_connection(device_id, connection_id);
                } else {
                    info!("Enviado GateClose automáticamente a {}.", device_id);
                }
            }
        });

        // Guardamos el nuevo timer en la conexión actual
        if let Some(mut conn) = self.connections.get_mut(&device_id) {
            if conn.connection_id == connection_id {
                conn.active_timer = Some(new_timer);
            }
        }

        Ok(())
    }
}
