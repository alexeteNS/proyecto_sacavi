use crate::dtos::access_dtos::AccessResponseDto;
use crate::dtos::device_dtos::ScanResponseDto;

pub trait IAccessService {
    async fn scan_qr(&self, token: String, device_id: Option<i64>) -> Result<ScanResponseDto, String>;
    async fn get_history(&self, user_id: i64, user_role: &str) -> Result<Vec<AccessResponseDto>, String>;
    async fn open_gate(&self, id_vehicle: i64, user_id: i64, user_role: &str) -> Result<AccessResponseDto, String>;
}
