use crate::dtos::log_dtos::{LogFilterParams, LogResponseDto};
use crate::interfaces::repositories::i_log_repository::ILogRepository;
use crate::interfaces::services::i_log_service::ILogService;
use crate::repositories::log_repository::LogRepository;

#[derive(Clone)]
pub struct LogService {
    pub log_repository: LogRepository,
}

impl ILogService for LogService {
    async fn get_logs(&self, filters: LogFilterParams) -> Result<Vec<LogResponseDto>, String> {
        let logs = self
            .log_repository
            .get_filtered(&filters)
            .await
            .map_err(|e| e.to_string())?;

        Ok(logs
            .into_iter()
            .map(|l| LogResponseDto {
                id_log: l.id,
                id_user: l.id_user,
                action: l.action,
                device: l.device,
                result: l.result,
                created_at: l.created_at.to_string(),
            })
            .collect())
    }
}
