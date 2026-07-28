use crate::dtos::device_dtos::{DeviceResponseDto, DeviceStatusResponse, RegisterDeviceDto};

pub trait IDeviceService {
    async fn register(&self, dto: RegisterDeviceDto) -> Result<DeviceResponseDto, String>;
    async fn get_status(&self, device_key: String) -> Result<DeviceStatusResponse, String>;
    async fn validate_device(&self, device_id: i64) -> Result<String, String>;
}
