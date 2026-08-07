use crate::dtos::log_dtos::LogFilterParams;
use crate::entities::system_log;
use crate::interfaces::repositories::i_log_repository::ILogRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct LogRepository {
    pub db: DatabaseConnection,
}

impl ILogRepository for LogRepository {
    async fn log(
        &self,
        id_user: Option<i64>,
        action: &str,
        device: Option<&str>,
        result: &str,
    ) -> Result<(), DbErr> {
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

    async fn get_filtered(
        &self,
        filters: &LogFilterParams,
    ) -> Result<Vec<system_log::Model>, DbErr> {
        let limit = filters.limit.unwrap_or(100);
        let mut query = system_log::Entity::find().order_by_desc(system_log::Column::CreatedAt);

        if let Some(uid) = filters.user_id {
            query = query.filter(system_log::Column::IdUser.eq(uid));
        }
        if let Some(ref action) = filters.action {
            query = query.filter(system_log::Column::Action.eq(action.as_str()));
        }
        if let (Some(from), Ok(dt)) = (&filters.from, chrono::NaiveDateTime::parse_from_str(filters.from.as_deref().unwrap_or(""), "%Y-%m-%dT%H:%M:%S")) {
            query = query.filter(system_log::Column::CreatedAt.gte(dt));
        }
        if let (Some(to), Ok(dt)) = (&filters.to, chrono::NaiveDateTime::parse_from_str(filters.to.as_deref().unwrap_or(""), "%Y-%m-%dT%H:%M:%S")) {
            query = query.filter(system_log::Column::CreatedAt.lte(dt));
        }

        query.limit(limit).all(&self.db).await
    }
}
