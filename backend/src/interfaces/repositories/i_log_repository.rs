use sea_orm::DbErr;

pub trait ILogRepository {
    async fn log(&self, id_user: Option<i64>, action: &str, device: Option<&str>, result: &str) -> Result<(), DbErr>;
}
