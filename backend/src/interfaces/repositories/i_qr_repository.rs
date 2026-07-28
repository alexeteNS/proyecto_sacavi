use crate::entities::qr_token::Model;
use sea_orm::DbErr;

pub trait IQrRepository {
    async fn create_token(&self, id_user: i64, id_vehicle: Option<i64>, token: String, expires_at: chrono::NaiveDateTime) -> Result<Model, DbErr>;
    async fn find_by_token(&self, token: String) -> Result<Option<Model>, DbErr>;
    async fn mark_used(&self, id: i64) -> Result<(), DbErr>;
    async fn delete_expired(&self) -> Result<(), DbErr>;
}
