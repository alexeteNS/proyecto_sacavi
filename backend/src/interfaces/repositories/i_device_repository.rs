use crate::entities::device::Model;
use sea_orm::DbErr;

pub trait IDeviceRepository {
    async fn register(&self, name: String, location: String, device_key: String) -> Result<Model, DbErr>;
    async fn find_by_id(&self, id: i64) -> Result<Option<Model>, DbErr>;
    async fn find_by_key(&self, key: String) -> Result<Option<Model>, DbErr>;
    async fn update_status(&self, id: i64, status: String) -> Result<(), DbErr>;
    async fn update_last_connection(&self, id: i64) -> Result<(), DbErr>;
}
