use crate::entities::vehicle_request::Model;
use sea_orm::DbErr;

pub trait IVehicleRequestRepository {
    async fn create(
        &self,
        id_user: i64,
        plate: String,
        brand: String,
        model: String,
        color: String,
    ) -> Result<Model, DbErr>;

    async fn find_by_user(&self, id_user: i64) -> Result<Vec<Model>, DbErr>;
    async fn find_all(&self) -> Result<Vec<Model>, DbErr>;
    async fn find_pending(&self) -> Result<Vec<Model>, DbErr>;
    async fn find_in_revision(&self) -> Result<Vec<Model>, DbErr>;
    async fn find_by_id(&self, id: i64) -> Result<Option<Model>, DbErr>;
    async fn update_status(&self, id: i64, status: String) -> Result<Model, DbErr>;
    async fn count_pending(&self) -> Result<i64, DbErr>;
    async fn count_in_revision(&self) -> Result<i64, DbErr>;
}
