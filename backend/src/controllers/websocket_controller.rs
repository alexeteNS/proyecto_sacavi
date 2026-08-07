use axum::extract::{
    Query, State, WebSocketUpgrade,
    ws::{Message, WebSocket},
};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};

use crate::services::websocket_manager::DeviceCommand;
use crate::state::AppState;
use crate::utils::jwt::verify_token;
use axum::extract::ConnectInfo;
use serde::Deserialize;
use std::net::SocketAddr;
use tokio::sync::mpsc;
use tracing::{error, info};

#[derive(Deserialize)]
pub struct WsQuery {
    pub device_id: i64,
    pub token: Option<String>,
}

pub async fn websocket_handler(
    ws: WebSocketUpgrade,
    Query(query): Query<WsQuery>,
    State(state): State<AppState>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> Response {
    // Validación JWT del token para autenticación de dispositivos
    let token = query.token.unwrap_or_default();
    if let Err(e) = verify_token(&token) {
        error!("Rechazada conexión WS (Unauthorized): {}", e);
        return (StatusCode::UNAUTHORIZED, "Invalid authentication token").into_response();
    }

    ws.on_upgrade(move |socket| handle_socket(socket, query.device_id, state, addr))
}

async fn handle_socket(mut socket: WebSocket, device_id: i64, state: AppState, addr: SocketAddr) {
    let (tx, mut rx) = mpsc::channel::<crate::services::websocket_manager::DeviceCommand>(32);
    let connection_id = state.ws_manager.add_connection(device_id, tx, addr);
    let manager = state.ws_manager.clone();

    tracing::info!(
        ">>> [ENTRADA] handle_socket iniciado | device_id: {} | connection_id: {}",
        device_id,
        connection_id
    );

    let mut ping_interval = tokio::time::interval(tokio::time::Duration::from_secs(15));

    loop {
        tokio::select! {
            _ = ping_interval.tick() => {
                if let Err(e) = socket.send(Message::Ping(vec![].into())).await {
                    tracing::error!(">>> [ERROR_ENVIANDO_PING] device {}: {:?}", device_id, e);
                    break;
                }
            }
            msg = socket.recv() => {
                match msg {
                    Some(Ok(Message::Ping(_))) => {
                        tracing::info!(">>> [PING_RECIBIDO] device_id: {}", device_id);
                        manager.update_ping(device_id);
                    }
                    Some(Ok(Message::Pong(_))) => {
                        tracing::info!(">>> [PONG_RECIBIDO] device_id: {}", device_id);
                        manager.update_ping(device_id);
                    }
                    Some(Ok(Message::Text(text))) => {
                        tracing::info!(">>> [TEXT_RECIBIDO] device_id: {} | text: {}", device_id, text);
                        manager.update_ping(device_id);
                    }
                    Some(Ok(Message::Close(c))) => {
                        tracing::info!(">>> [CLOSE_RECIBIDO] device_id: {} | frame: {:?}", device_id, c);
                        break;
                    }
                    Some(Ok(_)) => {
                        tracing::info!(">>> [OTRO_FRAME_RECIBIDO] device_id: {}", device_id);
                    }
                    Some(Err(e)) => {
                        tracing::error!(">>> [ERROR_LEYENDO_WS] device {}: {:?}", device_id, e);
                        break;
                    }
                    None => {
                        tracing::warn!(">>> [STREAM_DEVUELVE_NONE] El receiver devolvió None para device {}", device_id);
                        break;
                    }
                }
            }
            command = rx.recv() => {
                if let Some(cmd) = command {
                    let cmd_str = format!("{:?}", cmd);
                    tracing::info!(">>> [PRE-ENVIANDO_COMANDO] device_id: {} | comando: {}", device_id, cmd_str);
                    if let Ok(json) = serde_json::to_string(&cmd) {
                        if let Err(e) = socket.send(Message::Text(json.into())).await {
                            tracing::error!(">>> [ERROR_SENDING] Error enviando frame al device {}: {:?}", device_id, e);
                            break;
                        } else {
                            tracing::info!(">>> [COMANDO_ENVIADO] device_id: {}", device_id);
                        }
                    }
                } else {
                    break;
                }
            }
        }
    }

    tracing::info!(
        ">>> [SALIENDO_DE_HANDLE_SOCKET] haciendo remove_connection para device_id {}",
        device_id
    );
    state.ws_manager.remove_connection(device_id, connection_id);
}
