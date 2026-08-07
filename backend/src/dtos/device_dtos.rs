use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct RegisterDeviceDto {
    pub name: String,
    pub location: String,
    pub device_key: String,
}

#[derive(Serialize, Clone)]
pub struct DeviceResponseDto {
    pub id_device: i64,
    pub name: String,
    pub location: String,
    pub device_key: String,
    pub status: String,
    pub last_connection: Option<String>,
    pub firmware: Option<String>,
    pub version: Option<String>,
    pub ip_address: Option<String>,
    pub mac_address: Option<String>,
    pub uptime_seconds: Option<i64>,
}

#[derive(Serialize)]
pub struct DeviceStatusResponse {
    pub online: bool,
    pub status: String,
}

#[derive(Serialize)]
pub struct ScanResponseDto {
    pub allowed: bool,
    pub action: String,
}
