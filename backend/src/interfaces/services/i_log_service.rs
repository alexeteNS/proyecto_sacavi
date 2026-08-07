use crate::dtos::log_dtos::{LogFilterParams, LogResponseDto};

pub trait ILogService {
    async fn get_logs(&self, filters: LogFilterParams) -> Result<Vec<LogResponseDto>, String>;
}
