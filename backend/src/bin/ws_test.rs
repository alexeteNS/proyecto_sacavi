#![allow(dead_code, unused_variables, unused_imports)]
use futures_util::{SinkExt, StreamExt};
use tokio_tungstenite::{connect_async, tungstenite::protocol::Message};
use url::Url;

#[tokio::main]
async fn main() {
    let url = Url::parse("ws://127.0.0.1:3000/ws?device_id=2&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsInJvbGUiOiJERVZJQ0UiLCJleHAiOjE4MTcxODQ5NTd9.03zbwmvsXh6kagB5eXIHgsTR6SiwL9SDB-sN_-gWIXI").unwrap();

    let (mut ws_stream, _) = connect_async(url.as_str())
        .await
        .expect("Failed to connect");
    println!("WebSocket handshake has been successfully completed");

    // Recibir mensajes
    while let Some(msg) = ws_stream.next().await {
        let msg = msg.unwrap();
        println!("Received: {}", msg);
    }
}
