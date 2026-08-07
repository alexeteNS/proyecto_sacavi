use crate::entities::device::Model;
use sea_orm::DbErr;

pub trait IDeviceRepository {
    async fn register(
        &self,
        name: String,
        location: String,
        device_key: String,
    ) -> Result<Model, DbErr>;
    async fn find_by_id(&self, id: i64) -> Result<Option<Model>, DbErr>;
    async fn find_by_key(&self, key: String) -> Result<Option<Model>, DbErr>;
    async fn update_status(&self, id: i64, status: String) -> Result<(), DbErr>;
    async fn update_last_connection(&self, id: i64) -> Result<(), DbErr>;
    async fn get_all(&self) -> Result<Vec<Model>, DbErr>;
    async fn count_online(&self) -> Result<i64, DbErr>;
    async fn delete(&self, id: i64) -> Result<(), DbErr>;
    async fn update_device_info(
        &self,
        id: i64,
        ip_address: Option<String>,
        mac_address: Option<String>,
        firmware: Option<String>,
        version: Option<String>,
        uptime_seconds: Option<i64>,
    ) -> Result<(), DbErr>;
}
