use crate::entities::access_record::Model;
use sea_orm::DbErr;

pub trait IAccessRepository {
    async fn create_record(
        &self,
        id_vehicle: i64,
        r#type: String,
        status: String,
    ) -> Result<Model, DbErr>;
    async fn get_history(&self, vehicle_ids: Vec<i64>) -> Result<Vec<Model>, DbErr>;
    async fn get_last_by_vehicle(&self, id_vehicle: i64) -> Result<Option<Model>, DbErr>;
    async fn count_today(&self) -> Result<i64, DbErr>;
    async fn count_entries_today(&self) -> Result<i64, DbErr>;
    async fn count_exits_today(&self) -> Result<i64, DbErr>;
    async fn get_all_history(&self, limit: u64) -> Result<Vec<Model>, DbErr>;
    async fn get_recent(&self, n: u64) -> Result<Vec<Model>, DbErr>;
    async fn get_enriched_history(&self, filters: crate::dtos::log_dtos::LogFilterParams) -> Result<Vec<crate::dtos::admin_dtos::AccessHistoryResponseDto>, DbErr>;
    async fn count_denied_today(&self) -> Result<i64, DbErr>;
}
