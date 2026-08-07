use axum::extract::ws::Message;
use dashmap::DashMap;
use std::sync::Arc;
use tokio::sync::mpsc;
use uuid::Uuid;

#[derive(Clone)]
pub struct DashboardHub {
    pub connections: Arc<DashMap<Uuid, mpsc::Sender<serde_json::Value>>>,
}

impl DashboardHub {
    pub fn new() -> Self {
        Self {
            connections: Arc::new(DashMap::new()),
        }
    }

    pub fn broadcast(&self, message: serde_json::Value) {
        let conns = self.connections.clone();
        tokio::spawn(async move {
            for entry in conns.iter() {
                let _ = entry.value().send(message.clone()).await;
            }
        });
    }

    pub fn add_connection(&self, sender: mpsc::Sender<serde_json::Value>) -> Uuid {
        let connection_id = Uuid::new_v4();
        self.connections.insert(connection_id, sender);
        connection_id
    }

    pub fn remove_connection(&self, connection_id: Uuid) {
        self.connections.remove(&connection_id);
    }
}
