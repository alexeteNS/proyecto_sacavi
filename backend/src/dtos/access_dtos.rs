use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct AccessResponseDto {
    pub id_record: i64,
    pub vehicle_plate: String,
    pub date_time: String,
    pub r#type: String,
    pub status: String,
}

#[derive(Deserialize)]
pub struct OpenGateDto {
    pub id_vehicle: i64,
}
