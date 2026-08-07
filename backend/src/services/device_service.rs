use crate::dtos::device_dtos::{DeviceResponseDto, DeviceStatusResponse, RegisterDeviceDto};
use crate::interfaces::repositories::i_device_repository::IDeviceRepository;
use crate::interfaces::services::i_device_service::IDeviceService;
use crate::repositories::device_repository::DeviceRepository;

#[derive(Clone)]
pub struct DeviceService {
    pub device_repository: DeviceRepository,
}

impl IDeviceService for DeviceService {
    async fn register(&self, dto: RegisterDeviceDto) -> Result<DeviceResponseDto, String> {
        let device = self
            .device_repository
            .register(dto.name, dto.location, dto.device_key)
            .await
            .map_err(|e| e.to_string())?;

        Ok(DeviceResponseDto {
            id_device: device.id,
            name: device.name,
            location: device.location,
            device_key: device.device_key,
            status: device.status,
            last_connection: device.last_connection.map(|t| t.to_string()),
            firmware: device.firmware,
            version: device.version,
            ip_address: device.ip_address,
            mac_address: device.mac_address,
            uptime_seconds: device.uptime_seconds,
        })
    }

    async fn get_status(&self, device_key: String) -> Result<DeviceStatusResponse, String> {
        let device = self
            .device_repository
            .find_by_key(device_key)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Device not found".to_string())?;

        self.device_repository
            .update_last_connection(device.id)
            .await
            .map_err(|e| e.to_string())?;

        Ok(DeviceStatusResponse {
            online: device.status == "ONLINE",
            status: device.status,
        })
    }

    async fn validate_device(&self, device_id: i64) -> Result<String, String> {
        let device = self
            .device_repository
            .find_by_id(device_id)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Device not found".to_string())?;

        if device.status != "ONLINE" {
            return Err("Device is offline".to_string());
        }

        self.device_repository
            .update_last_connection(device.id)
            .await
            .map_err(|e| e.to_string())?;

        Ok(device.device_key)
    }
}
