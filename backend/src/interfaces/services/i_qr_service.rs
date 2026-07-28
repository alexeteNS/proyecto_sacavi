use crate::dtos::qr_dtos::QrGenerateResponse;

pub trait IQrService {
    async fn generate_qr(&self, user_id: i64) -> Result<QrGenerateResponse, String>;
    async fn validate_qr(&self, token: String) -> Result<(i64, Option<i64>), String>;
}
