use crate::dtos::vehicle_dtos::VehicleRequestResponseDto;
use crate::interfaces::repositories::i_log_repository::ILogRepository;

use crate::interfaces::repositories::i_vehicle_request_repository::IVehicleRequestRepository;
use crate::interfaces::services::i_vehicle_request_service::IVehicleRequestService;
use crate::repositories::log_repository::LogRepository;
use crate::repositories::vehicle_repository::VehicleRepository;
use crate::repositories::vehicle_request_repository::VehicleRequestRepository;
use crate::services::dashboard_hub::DashboardHub;
use sea_orm::{ActiveModelTrait, Set, TransactionTrait};

#[derive(Clone)]
pub struct VehicleRequestService {
    pub vehicle_request_repository: VehicleRequestRepository,
    pub vehicle_repository: VehicleRepository,
    pub log_repository: LogRepository,
    pub dashboard_hub: std::sync::Arc<DashboardHub>,
}

fn to_dto(req: crate::entities::vehicle_request::Model) -> VehicleRequestResponseDto {
    VehicleRequestResponseDto {
        id_request: req.id,
        id_user: req.id_user,
        plate: req.plate,
        brand: req.brand,
        model: req.model,
        color: req.color,
        status: req.status,
        created_at: req.created_at.to_string(),
        updated_at: req.updated_at.map(|t| t.to_string()),
    }
}

impl IVehicleRequestService for VehicleRequestService {
    async fn create_request(
        &self,
        plate: String,
        brand: String,
        model: String,
        color: String,
        user_id: i64,
    ) -> Result<VehicleRequestResponseDto, String> {
        let req = self
            .vehicle_request_repository
            .create(user_id, plate, brand, model, color)
            .await
            .map_err(|e| e.to_string())?;

        let _ = self
            .log_repository
            .log(Some(user_id), "VEHICLE_REQUEST_CREATED", None, "SUCCESS")
            .await;

        Ok(to_dto(req))
    }

    async fn get_my_requests(
        &self,
        user_id: i64,
    ) -> Result<Vec<VehicleRequestResponseDto>, String> {
        self.vehicle_request_repository
            .find_by_user(user_id)
            .await
            .map(|reqs| reqs.into_iter().map(to_dto).collect())
            .map_err(|e| e.to_string())
    }

    async fn get_all_requests(&self) -> Result<Vec<VehicleRequestResponseDto>, String> {
        let reqs = self
            .vehicle_request_repository
            .find_all()
            .await
            .map_err(|e| e.to_string())?;

        Ok(reqs.into_iter().map(to_dto).collect())
    }

    async fn get_pending(&self) -> Result<Vec<VehicleRequestResponseDto>, String> {
        let reqs = self
            .vehicle_request_repository
            .find_pending()
            .await
            .map_err(|e| e.to_string())?;

        Ok(reqs.into_iter().map(to_dto).collect())
    }

    async fn get_in_revision(&self) -> Result<Vec<VehicleRequestResponseDto>, String> {
        let reqs = self
            .vehicle_request_repository
            .find_in_revision()
            .await
            .map_err(|e| e.to_string())?;

        Ok(reqs.into_iter().map(to_dto).collect())
    }

    async fn mark_in_revision(
        &self,
        id: i64,
        admin_id: i64,
    ) -> Result<VehicleRequestResponseDto, String> {
        let req = self
            .vehicle_request_repository
            .update_status(id, "EN_REVISION".to_string())
            .await
            .map_err(|e| e.to_string())?;

        let _ = self
            .log_repository
            .log(
                Some(admin_id),
                "VEHICLE_REQUEST_IN_REVISION",
                None,
                "SUCCESS",
            )
            .await;

        // Notificar vía WebSocket para actualización en tiempo real
        self.dashboard_hub.broadcast(serde_json::json!({
            "event": "vehicle_request_updated",
            "id_request": id,
            "status": "EN_REVISION"
        }));

        Ok(to_dto(req))
    }

    /// Aprobación transaccional: crea vehículo + actualiza request + log + WS broadcast
    async fn approve(&self, id: i64, admin_id: i64) -> Result<VehicleRequestResponseDto, String> {
        let req = self
            .vehicle_request_repository
            .find_by_id(id)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Solicitud no encontrada".to_string())?;

        if req.status == "APROBADO" {
            return Err("La solicitud ya fue aprobada".to_string());
        }

        let txn = self
            .vehicle_request_repository
            .db
            .begin()
            .await
            .map_err(|e| e.to_string())?;

        // 1. Crear el vehículo
        let new_vehicle = crate::entities::vehicle::ActiveModel {
            plate: Set(req.plate.clone()),
            brand: Set(req.brand.clone()),
            model: Set(req.model.clone()),
            color: Set(req.color.clone()),
            id_user: Set(req.id_user),
            ..Default::default()
        };
        new_vehicle.insert(&txn).await.map_err(|e| e.to_string())?;

        // 2. Actualizar estado de la solicitud
        let mut req_am: crate::entities::vehicle_request::ActiveModel = req.clone().into();
        req_am.status = Set("APROBADO".to_string());
        req_am.updated_at = Set(Some(chrono::Utc::now().naive_utc()));
        let updated_req = req_am.update(&txn).await.map_err(|e| e.to_string())?;

        // 3. Registrar log
        let new_log = crate::entities::system_log::ActiveModel {
            id_user: Set(Some(admin_id)),
            action: Set("VEHICLE_REQUEST_APPROVED".to_string()),
            result: Set("SUCCESS".to_string()),
            created_at: Set(chrono::Utc::now().naive_utc()),
            ..Default::default()
        };
        new_log.insert(&txn).await.map_err(|e| e.to_string())?;

        txn.commit().await.map_err(|e| e.to_string())?;

        // 4. Notificar vía WebSocket
        self.dashboard_hub.broadcast(serde_json::json!({
            "event": "vehicle_request_approved",
            "id_request": id,
            "id_user": req.id_user,
            "plate": req.plate
        }));

        Ok(to_dto(updated_req))
    }

    async fn reject(&self, id: i64, admin_id: i64) -> Result<VehicleRequestResponseDto, String> {
        let updated_req = self
            .vehicle_request_repository
            .update_status(id, "RECHAZADO".to_string())
            .await
            .map_err(|e| e.to_string())?;

        let _ = self
            .log_repository
            .log(Some(admin_id), "VEHICLE_REQUEST_REJECTED", None, "SUCCESS")
            .await;

        self.dashboard_hub.broadcast(serde_json::json!({
            "event": "vehicle_request_rejected",
            "id_request": id,
            "id_user": updated_req.id_user
        }));

        Ok(to_dto(updated_req))
    }
}
