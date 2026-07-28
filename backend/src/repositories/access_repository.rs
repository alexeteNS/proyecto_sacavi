use crate::entities::access_record;
use crate::interfaces::repositories::i_access_repository::IAccessRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct AccessRepository {
    pub db: DatabaseConnection,
}

impl IAccessRepository for AccessRepository {
    async fn create_record(&self, id_vehicle: i64, r#type: String, status: String) -> Result<access_record::Model, DbErr> {
        let record = access_record::ActiveModel {
            id_vehicle: Set(id_vehicle),
            date_time: Set(chrono::Utc::now().naive_utc()),
            r#type: Set(r#type),
            status: Set(status),
            ..Default::default()
        };
        record.insert(&self.db).await
    }

    async fn get_history(&self, vehicle_ids: Vec<i64>) -> Result<Vec<access_record::Model>, DbErr> {
        access_record::Entity::find()
            .filter(access_record::Column::IdVehicle.is_in(vehicle_ids))
            .order_by_desc(access_record::Column::DateTime)
            .all(&self.db)
            .await
    }

    async fn get_last_by_vehicle(&self, id_vehicle: i64) -> Result<Option<access_record::Model>, DbErr> {
        access_record::Entity::find()
            .filter(access_record::Column::IdVehicle.eq(id_vehicle))
            .order_by_desc(access_record::Column::DateTime)
            .one(&self.db)
            .await
    }
}
