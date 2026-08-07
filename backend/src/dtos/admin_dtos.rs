use crate::dtos::access_dtos::AccessResponseDto;
use crate::dtos::device_dtos::DeviceResponseDto;
use crate::dtos::vehicle_dtos::VehicleRequestResponseDto;
use serde::Serialize;

// ─── Dashboard ────────────────────────────────────────────────────────────────

#[derive(Serialize)]
pub struct DashboardSummary {
    pub users: i64,
    pub vehicles: i64,
    pub vehicle_requests_pending: i64,
    pub vehicle_requests_in_revision: i64,
    pub devices_online: i64,
    pub access_today: i64,
    pub entries_today: i64,
    pub exits_today: i64,
}

/// Respuesta rica del dashboard: una sola petición alimenta casi todo el panel.
#[derive(Serialize)]
pub struct DashboardDto {
    pub summary: DashboardSummary,
    pub recent_access: Vec<AccessResponseDto>,
    pub pending_requests: Vec<VehicleRequestResponseDto>,
    pub devices: Vec<DeviceResponseDto>,
}

// ─── Admin User ───────────────────────────────────────────────────────────────

#[derive(Serialize)]
pub struct AdminUserResponseDto {
    pub id_user: i64,
    pub name: String,
    pub email: String,
    pub role: String,
    pub permissions: Vec<String>,
    pub created_at: Option<String>,
    pub vehicle_count: i64,
}

#[derive(serde::Deserialize)]
pub struct AdminCreateUserDto {
    pub name: String,
    pub email: String,
    pub password: String,
    pub id_role: i64,
}

#[derive(serde::Deserialize)]
pub struct AdminUpdateUserDto {
    pub name: String,
    pub email: String,
    pub id_role: i64,
}

#[derive(serde::Deserialize)]
pub struct AdminResetPasswordDto {
    pub new_password: String,
}

// ─── Access History ──────────────────────────────────────────────────────────

#[derive(Serialize)]
pub struct AccessStatsResponseDto {
    pub today_total: i64,
    pub entradas: i64,
    pub salidas: i64,
    pub denied: i64,
    pub avg_time: String,
    pub active_esp32: i64,
}

#[derive(Serialize, Clone)]
pub struct DeviceInfoDto {
    pub id_device: i64,
    pub name: String,
    pub location: String,
}

#[derive(Serialize, Clone)]
pub struct VehicleInfoDto {
    pub id_vehicle: i64,
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}

#[derive(Serialize, Clone)]
pub struct OwnerInfoDto {
    pub id_user: i64,
    pub name: String,
    pub email: String,
    pub role: String,
}

#[derive(Serialize, Clone)]
pub struct AccessHistoryResponseDto {
    pub id_record: i64,
    pub date_time: String,
    pub r#type: String,
    pub status: String,
    pub device: Option<DeviceInfoDto>,
    pub vehicle: VehicleInfoDto,
    pub owner: OwnerInfoDto,
}
