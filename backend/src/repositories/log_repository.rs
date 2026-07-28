use crate::entities::system_log;
use crate::interfaces::repositories::i_log_repository::ILogRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct LogRepository {
    pub db: DatabaseConnection,
}

impl ILogRepository for LogRepository {
    async fn log(&self, id_user: Option<i64>, action: &str, device: Option<&str>, result: &str) -> Result<(), DbErr> {
        let log = system_log::ActiveModel {
            id_user: Set(id_user),
            action: Set(action.to_owned()),
            device: Set(device.map(|d| d.to_owned())),
            result: Set(result.to_owned()),
            ..Default::default()
        };
        log.insert(&self.db).await?;
        Ok(())
    }
}
