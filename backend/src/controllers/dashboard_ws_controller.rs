use axum::extract::{
    Query, State, WebSocketUpgrade,
    ws::{Message, WebSocket},
};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};

use crate::state::AppState;
use crate::utils::jwt::verify_token;
use serde::Deserialize;
use tokio::sync::mpsc;
use tracing::{error, info};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct WsDashboardQuery {
    pub token: Option<String>,
}

pub async fn dashboard_websocket_handler(
    ws: WebSocketUpgrade,
    Query(query): Query<WsDashboardQuery>,
    State(state): State<AppState>,
) -> Response {
    let token = query.token.unwrap_or_default();
    let claims = match verify_token(&token) {
        Ok(c) => c,
        Err(e) => {
            error!("Rechazada conexión WS Dashboard (Unauthorized): {}", e);
            return (StatusCode::UNAUTHORIZED, "Invalid authentication token").into_response();
        }
    };

    if claims.role != "ADMIN" && claims.role != "GUARDIA" {
        return (StatusCode::FORBIDDEN, "Forbidden: Admins and Guards only").into_response();
    }

    ws.on_upgrade(move |socket| handle_dashboard_socket(socket, state))
}

async fn handle_dashboard_socket(mut socket: WebSocket, state: AppState) {
    let (tx, mut rx) = mpsc::channel::<serde_json::Value>(32);
    let connection_id = state.dashboard_hub.add_connection(tx);
    let _hub = state.dashboard_hub.clone();

    tracing::info!(
        ">>> [ENTRADA] handle_dashboard_socket iniciado | connection_id: {}",
        connection_id
    );

    let mut ping_interval = tokio::time::interval(tokio::time::Duration::from_secs(15));

    loop {
        tokio::select! {
            _ = ping_interval.tick() => {
                if let Err(e) = socket.send(Message::Ping(vec![].into())).await {
                    tracing::error!(">>> [ERROR_ENVIANDO_PING] dashboard conn {}: {:?}", connection_id, e);
                    break;
                }
            }
            msg = socket.recv() => {
                match msg {
                    Some(Ok(Message::Ping(_))) => {
                        // Responded automatically by axum usually, or we can handle pong
                    }
                    Some(Ok(Message::Pong(_))) => {}
                    Some(Ok(Message::Close(c))) => {
                        tracing::info!(">>> [CLOSE_RECIBIDO] dashboard conn {}: {:?}", connection_id, c);
                        break;
                    }
                    Some(Ok(_)) => {}
                    Some(Err(e)) => {
                        tracing::error!(">>> [ERROR_LEYENDO_WS] dashboard conn {}: {:?}", connection_id, e);
                        break;
                    }
                    None => {
                        break;
                    }
                }
            }
            command = rx.recv() => {
                if let Some(cmd) = command {
                    let cmd_str = cmd.to_string();
                    if let Err(e) = socket.send(Message::Text(cmd_str.into())).await {
                        tracing::error!(">>> [ERROR_SENDING] Error enviando frame al dashboard conn {}: {:?}", connection_id, e);
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }

    tracing::info!(
        ">>> [SALIENDO_DE_HANDLE_DASHBOARD_SOCKET] desconectando {}",
        connection_id
    );
    state.dashboard_hub.remove_connection(connection_id);
}
