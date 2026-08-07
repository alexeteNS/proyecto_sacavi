use crate::dtos::access_dtos::AccessResponseDto;
use crate::dtos::admin_dtos::{DashboardDto, DashboardSummary};
use crate::dtos::device_dtos::DeviceResponseDto;
use crate::dtos::vehicle_dtos::VehicleRequestResponseDto;
use crate::interfaces::repositories::i_access_repository::IAccessRepository;
use crate::interfaces::repositories::i_device_repository::IDeviceRepository;
use crate::interfaces::repositories::i_user_repository::IUserRepository;
use crate::interfaces::repositories::i_vehicle_repository::IVehicleRepository;
use crate::interfaces::repositories::i_vehicle_request_repository::IVehicleRequestRepository;
use crate::interfaces::services::i_dashboard_service::IDashboardService;
use crate::repositories::access_repository::AccessRepository;
use crate::repositories::device_repository::DeviceRepository;
use crate::repositories::user_repository::UserRepository;
use crate::repositories::vehicle_repository::VehicleRepository;
use crate::repositories::vehicle_request_repository::VehicleRequestRepository;

#[derive(Clone)]
pub struct DashboardService {
    pub user_repository: UserRepository,
    pub vehicle_repository: VehicleRepository,
    pub vehicle_request_repository: VehicleRequestRepository,
    pub access_repository: AccessRepository,
    pub device_repository: DeviceRepository,
}

impl IDashboardService for DashboardService {
    async fn get_dashboard(&self) -> Result<DashboardDto, String> {
        // Ejecutar todas las queries en paralelo con tokio::join!
        let (
            users_result,
            vehicles_result,
            pending_result,
            in_revision_result,
            devices_online_result,
            entries_result,
            exits_result,
            recent_access_result,
            pending_requests_result,
            devices_result,
        ) = tokio::join!(
            self.user_repository.find_all(),
            self.vehicle_repository.count_all(),
            self.vehicle_request_repository.count_pending(),
            self.vehicle_request_repository.count_in_revision(),
            self.device_repository.count_online(),
            self.access_repository.count_entries_today(),
            self.access_repository.count_exits_today(),
            self.access_repository.get_recent(5),
            self.vehicle_request_repository.find_pending(),
            self.device_repository.get_all(),
        );

        let users = users_result.map_err(|e| e.to_string())?.len() as i64;
        let vehicles = vehicles_result.map_err(|e| e.to_string())?;
        let vehicle_requests_pending = pending_result.map_err(|e| e.to_string())?;
        let vehicle_requests_in_revision = in_revision_result.map_err(|e| e.to_string())?;
        let devices_online = devices_online_result.map_err(|e| e.to_string())?;
        let entries_today = entries_result.map_err(|e| e.to_string())?;
        let exits_today = exits_result.map_err(|e| e.to_string())?;
        let access_today = entries_today + exits_today;
        let recent_records = recent_access_result.map_err(|e| e.to_string())?;
        let pending_reqs = pending_requests_result.map_err(|e| e.to_string())?;
        let all_devices = devices_result.map_err(|e| e.to_string())?;

        let recent_access: Vec<AccessResponseDto> = recent_records
            .into_iter()
            .map(|r| AccessResponseDto {
                id_record: r.id,
                vehicle_plate: r.id_vehicle.to_string(), // se mostrará como ID
                date_time: r.date_time.to_string(),
                r#type: r.r#type,
                status: r.status,
            })
            .collect();

        let pending_requests: Vec<VehicleRequestResponseDto> = pending_reqs
            .into_iter()
            .map(|req| VehicleRequestResponseDto {
                id_request: req.id,
                id_user: req.id_user,
                plate: req.plate,
                brand: req.brand,
                model: req.model,
                color: req.color,
                status: req.status,
                created_at: req.created_at.to_string(),
                updated_at: req.updated_at.map(|t| t.to_string()),
            })
            .collect();

        let devices: Vec<DeviceResponseDto> = all_devices
            .into_iter()
            .map(|d| DeviceResponseDto {
                id_device: d.id,
                name: d.name,
                location: d.location,
                device_key: d.device_key,
                status: d.status,
                last_connection: d.last_connection.map(|t| t.to_string()),
                firmware: d.firmware,
                version: d.version,
                ip_address: d.ip_address,
                mac_address: d.mac_address,
                uptime_seconds: d.uptime_seconds,
            })
            .collect();

        Ok(DashboardDto {
            summary: DashboardSummary {
                users,
                vehicles,
                vehicle_requests_pending,
                vehicle_requests_in_revision,
                devices_online,
                access_today,
                entries_today,
                exits_today,
            },
            recent_access,
            pending_requests,
            devices,
        })
    }
}
