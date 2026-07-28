#[derive(serde::Deserialize)]
pub struct VehicleCreateDto {
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}

#[derive(serde::Serialize)]
pub struct VehicleResponseDto {
    pub id_vehicle: i64,
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
}
