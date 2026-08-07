use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct VehicleCreateDto {
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}

#[derive(Serialize)]
pub struct VehicleResponseDto {
    pub id_vehicle: i64,
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}

// ─── Vehicle Request DTOs ─────────────────────────────────────────────────────

#[derive(Deserialize)]
pub struct VehicleRequestCreateDto {
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}

#[derive(Serialize, Clone)]
pub struct VehicleRequestResponseDto {
    pub id_request: i64,
    pub id_user: i64,
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
    /// PENDIENTE | EN_REVISION | APROBADO | RECHAZADO
    pub status: String,
    pub created_at: String,
    pub updated_at: Option<String>,
}
