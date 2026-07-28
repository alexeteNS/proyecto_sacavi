use serde::Serialize;

#[derive(Serialize)]
pub struct QrGenerateResponse {
    pub token: String,
    pub expires_in_seconds: u64,
}

#[derive(serde::Deserialize)]
pub struct QrScanRequest {
    pub token: String,
    pub device_id: Option<i64>,
}
