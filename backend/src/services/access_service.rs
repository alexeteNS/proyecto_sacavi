use crate::dtos::access_dtos::AccessResponseDto;
use crate::dtos::device_dtos::ScanResponseDto;
use crate::interfaces::repositories::i_access_repository::IAccessRepository;
use crate::interfaces::repositories::i_log_repository::ILogRepository;
use crate::interfaces::repositories::i_vehicle_repository::IVehicleRepository;
use crate::interfaces::services::i_access_service::IAccessService;
use crate::interfaces::services::i_device_service::IDeviceService;
use crate::interfaces::services::i_qr_service::IQrService;
use crate::repositories::access_repository::AccessRepository;
use crate::repositories::log_repository::LogRepository;
use crate::repositories::vehicle_repository::VehicleRepository;
use crate::services::device_service::DeviceService;
use crate::services::qr_service::QrService;

#[derive(Clone)]
pub struct AccessService {
    pub access_repository: AccessRepository,
    pub vehicle_repository: VehicleRepository,
    pub qr_service: QrService,
    pub device_service: DeviceService,
    pub log_repository: LogRepository,
}

impl IAccessService for AccessService {
    async fn scan_qr(&self, token: String, device_id: Option<i64>) -> Result<ScanResponseDto, String> {
        let device_str = device_id.map(|d| d.to_string());

        if let Some(did) = device_id {
            if let Err(e) = self.device_service.validate_device(did).await {
                let _ = self
                    .log_repository
                    .log(None, "QR_DENIED", device_str.as_deref(), "FAILED")
                    .await;
                return Err(e);
            }
        }

        let (user_id, _) = match self.qr_service.validate_qr(token).await {
            Ok(r) => r,
            Err(e) => {
                let _ = self
                    .log_repository
                    .log(None, "QR_DENIED", device_str.as_deref(), "FAILED")
                    .await;
                return Err(e);
            }
        };

        let vehicles = self
            .vehicle_repository
            .find_by_user(user_id)
            .await
            .map_err(|e| e.to_string())?;

        if vehicles.is_empty() {
            let _ = self
                .log_repository
                .log(Some(user_id), "QR_DENIED", device_str.as_deref(), "FAILED")
                .await;
            return Err("No vehicle found for user".to_string());
        }

        let vehicle_id = vehicles[0].id;

        let last = self
            .access_repository
            .get_last_by_vehicle(vehicle_id)
            .await
            .map_err(|e| e.to_string())?;

        let record_type = match last {
            Some(r) if r.r#type == "ENTRADA" => "SALIDA".to_string(),
            _ => "ENTRADA".to_string(),
        };

        self.access_repository
            .create_record(vehicle_id, record_type.clone(), "APROBADO".to_string())
            .await
            .map_err(|e| e.to_string())?;

        let _ = self
            .log_repository
            .log(Some(user_id), "QR_ACCEPTED", device_str.as_deref(), "SUCCESS")
            .await;

        Ok(ScanResponseDto {
            allowed: true,
            action: "OPEN_GATE".to_string(),
        })
    }

    async fn get_history(&self, user_id: i64, _user_role: &str) -> Result<Vec<AccessResponseDto>, String> {
        let vehicles = self
            .vehicle_repository
            .find_by_user(user_id)
            .await
            .map_err(|e| e.to_string())?;

        let vehicle_ids: Vec<i64> = vehicles.iter().map(|v| v.id).collect();
        if vehicle_ids.is_empty() {
            return Ok(vec![]);
        }

        let records = self
            .access_repository
            .get_history(vehicle_ids.clone())
            .await
            .map_err(|e| e.to_string())?;

        let vehicle_map: std::collections::HashMap<i64, String> = vehicles
            .into_iter()
            .map(|v| (v.id, v.plate))
            .collect();

        Ok(records
            .into_iter()
            .map(|r| AccessResponseDto {
                id_record: r.id,
                vehicle_plate: vehicle_map.get(&r.id_vehicle).cloned().unwrap_or_default(),
                date_time: r.date_time.to_string(),
                r#type: r.r#type,
                status: r.status,
            })
            .collect())
    }

    async fn open_gate(&self, id_vehicle: i64, user_id: i64, user_role: &str) -> Result<AccessResponseDto, String> {
        if user_role != "ADMIN" && user_role != "GUARDIA" {
            let _ = self
                .log_repository
                .log(Some(user_id), "GATE_OPEN_DENIED", None, "FAILED")
                .await;
            return Err("Unauthorized: only ADMIN or GUARDIA can open the gate".to_string());
        }

        let vehicle = self
            .vehicle_repository
            .find_by_id(id_vehicle)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Vehicle not found".to_string())?;

        let record = self
            .access_repository
            .create_record(id_vehicle, "MANUAL".to_string(), "APROBADO".to_string())
            .await
            .map_err(|e| e.to_string())?;

        let _ = self
            .log_repository
            .log(Some(user_id), "GATE_OPEN_MANUAL", None, "SUCCESS")
            .await;

        Ok(AccessResponseDto {
            id_record: record.id,
            vehicle_plate: vehicle.plate,
            date_time: record.date_time.to_string(),
            r#type: "MANUAL".to_string(),
            status: record.status,
        })
    }
}
