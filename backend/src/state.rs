use crate::repositories::{log_repository::LogRepository, role_repository::RoleRepository};
use crate::services::{access_service, device_service, qr_service, user_service, vehicle_service};

#[derive(Clone)]
pub struct AppState {
    pub user_service: user_service::UserService,
    pub vehicle_service: vehicle_service::VehicleService,
    pub qr_service: qr_service::QrService,
    pub access_service: access_service::AccessService,
    pub device_service: device_service::DeviceService,
    pub role_repository: RoleRepository,
    pub log_repository: LogRepository,
}
