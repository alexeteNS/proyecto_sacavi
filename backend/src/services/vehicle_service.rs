use crate::dtos::vehicle_dtos::{VehicleCreateDto, VehicleResponseDto};
use crate::interfaces::repositories::i_vehicle_repository::IVehicleRepository;
use crate::interfaces::services::i_vehicle_service::IVehicleService;
use crate::repositories::vehicle_repository::VehicleRepository;

#[derive(Clone)]
pub struct VehicleService {
    pub vehicle_repository: VehicleRepository,
}

impl IVehicleService for VehicleService {
    async fn create(
        &self,
        dto: VehicleCreateDto,
        user_id: i64,
    ) -> Result<VehicleResponseDto, String> {
        if self
            .vehicle_repository
            .find_by_plate(dto.plate.clone())
            .await
            .map_err(|e| e.to_string())?
            .is_some()
        {
            return Err("Plate already registered".to_string());
        }

        let vehicle = self
            .vehicle_repository
            .create(dto.plate, dto.brand, dto.model, dto.color, user_id)
            .await
            .map_err(|e| e.to_string())?;

        Ok(VehicleResponseDto {
            id_vehicle: vehicle.id,
            plate: vehicle.plate,
            brand: vehicle.brand,
            model: vehicle.model,
            color: vehicle.color,
        })
    }

    async fn get_my_vehicles(&self, user_id: i64) -> Result<Vec<VehicleResponseDto>, String> {
        let vehicles = self
            .vehicle_repository
            .find_by_user(user_id)
            .await
            .map_err(|e| e.to_string())?;

        Ok(vehicles
            .into_iter()
            .map(|v| VehicleResponseDto {
                id_vehicle: v.id,
                plate: v.plate,
                brand: v.brand,
                model: v.model,
                color: v.color,
            })
            .collect())
    }

    async fn delete(&self, id: i64, user_id: i64, role: &str) -> Result<(), String> {
        let vehicle = self
            .vehicle_repository
            .find_by_id(id)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Vehicle not found".to_string())?;

        if vehicle.id_user != user_id && role != "ADMIN" {
            return Err("Unauthorized".to_string());
        }

        self.vehicle_repository
            .delete(id)
            .await
            .map_err(|e| e.to_string())
    }
}
