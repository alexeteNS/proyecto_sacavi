use crate::dtos::log_dtos::LogFilterParams;
use crate::entities::system_log::Model;
use sea_orm::DbErr;

pub trait ILogRepository {
    async fn log(
        &self,
        id_user: Option<i64>,
        action: &str,
        device: Option<&str>,
        result: &str,
    ) -> Result<(), DbErr>;
    async fn get_filtered(&self, filters: &LogFilterParams) -> Result<Vec<Model>, DbErr>;
}
