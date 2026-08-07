use crate::dtos::vehicle_dtos::{VehicleCreateDto, VehicleResponseDto};

pub trait IVehicleService {
    async fn create(
        &self,
        dto: VehicleCreateDto,
        user_id: i64,
    ) -> Result<VehicleResponseDto, String>;
    async fn get_my_vehicles(&self, user_id: i64) -> Result<Vec<VehicleResponseDto>, String>;
    async fn delete(&self, id: i64, user_id: i64, role: &str) -> Result<(), String>;
}
