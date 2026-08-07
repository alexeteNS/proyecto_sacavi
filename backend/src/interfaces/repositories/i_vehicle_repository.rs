use crate::entities::vehicle::Model;
use sea_orm::DbErr;

pub trait IVehicleRepository {
    async fn create(
        &self,
        plate: String,
        brand: String,
        model: String,
        color: String,
        id_user: i64,
    ) -> Result<Model, DbErr>;
    async fn find_by_id(&self, id: i64) -> Result<Option<Model>, DbErr>;
    async fn find_by_user(&self, id_user: i64) -> Result<Vec<Model>, DbErr>;
    async fn find_by_plate(&self, plate: String) -> Result<Option<Model>, DbErr>;
    async fn delete(&self, id: i64) -> Result<(), DbErr>;
    async fn find_all(&self) -> Result<Vec<Model>, DbErr>;
    async fn count_all(&self) -> Result<i64, DbErr>;
    async fn count_by_user(&self, id_user: i64) -> Result<i64, DbErr>;
}
