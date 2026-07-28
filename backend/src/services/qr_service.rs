use crate::dtos::qr_dtos::QrGenerateResponse;
use crate::interfaces::repositories::i_qr_repository::IQrRepository;
use crate::interfaces::services::i_qr_service::IQrService;
use crate::repositories::qr_repository::QrRepository;
use chrono::{Duration, Utc};
use uuid::Uuid;

#[derive(Clone)]
pub struct QrService {
    pub qr_repository: QrRepository,
}

const QR_EXPIRY_SECONDS: u64 = 30;

impl IQrService for QrService {
    async fn generate_qr(&self, user_id: i64) -> Result<QrGenerateResponse, String> {
        let token = Uuid::new_v4().to_string();
        let expires_at = (Utc::now() + Duration::seconds(QR_EXPIRY_SECONDS as i64)).naive_utc();

        self.qr_repository
            .create_token(user_id, None, token.clone(), expires_at)
            .await
            .map_err(|e| e.to_string())?;

        Ok(QrGenerateResponse {
            token,
            expires_in_seconds: QR_EXPIRY_SECONDS,
        })
    }

    async fn validate_qr(&self, token: String) -> Result<(i64, Option<i64>), String> {
        let qr = self
            .qr_repository
            .find_by_token(token)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Invalid QR token".to_string())?;

        if qr.used {
            return Err("QR already used".to_string());
        }

        if qr.expires_at < Utc::now().naive_utc() {
            return Err("QR expired".to_string());
        }

        self.qr_repository
            .mark_used(qr.id)
            .await
            .map_err(|e| e.to_string())?;

        Ok((qr.id_user, qr.id_vehicle))
    }
}
