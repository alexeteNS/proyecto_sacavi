use crate::dtos::vehicle_dtos::VehicleRequestResponseDto;

pub trait IVehicleRequestService {
    async fn create_request(
        &self,
        plate: String,
        brand: String,
        model: String,
        color: String,
        user_id: i64,
    ) -> Result<VehicleRequestResponseDto, String>;

    async fn get_my_requests(&self, user_id: i64)
    -> Result<Vec<VehicleRequestResponseDto>, String>;
    async fn get_all_requests(&self) -> Result<Vec<VehicleRequestResponseDto>, String>;
    async fn get_pending(&self) -> Result<Vec<VehicleRequestResponseDto>, String>;
    async fn get_in_revision(&self) -> Result<Vec<VehicleRequestResponseDto>, String>;

    /// Marca la solicitud como EN_REVISION
    async fn mark_in_revision(
        &self,
        id: i64,
        admin_id: i64,
    ) -> Result<VehicleRequestResponseDto, String>;

    /// Aprueba y crea el vehículo (transaccional)
    async fn approve(&self, id: i64, admin_id: i64) -> Result<VehicleRequestResponseDto, String>;

    /// Rechaza la solicitud
    async fn reject(&self, id: i64, admin_id: i64) -> Result<VehicleRequestResponseDto, String>;
}
