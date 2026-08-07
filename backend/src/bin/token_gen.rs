use jsonwebtoken::{EncodingKey, Header, encode};
use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Claims {
    pub sub: i64,
    pub role: String,
    pub exp: usize,
}

fn main() {
    let secret = "clave_super_secreta";
    let expiration = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as usize
        + (86400 * 365); // 1 año de validez para el ESP32

    let claims = Claims {
        sub: 1, // device_id o user_id dummy
        role: "DEVICE".to_string(),
        exp: expiration,
    };

    let token = encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .unwrap();

    println!("Copia este Token JWT en tu ESP32:\n\n{}\n", token);
}
