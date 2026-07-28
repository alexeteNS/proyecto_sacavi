use crate::entities::device;
use crate::interfaces::repositories::i_device_repository::IDeviceRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct DeviceRepository {
    pub db: DatabaseConnection,
}

impl IDeviceRepository for DeviceRepository {
    async fn register(&self, name: String, location: String, device_key: String) -> Result<device::Model, DbErr> {
        let d = device::ActiveModel {
            name: Set(name),
            location: Set(location),
            device_key: Set(device_key),
            status: Set("ONLINE".to_string()),
            ..Default::default()
        };
        d.insert(&self.db).await
    }

    async fn find_by_id(&self, id: i64) -> Result<Option<device::Model>, DbErr> {
        device::Entity::find_by_id(id).one(&self.db).await
    }

    async fn find_by_key(&self, key: String) -> Result<Option<device::Model>, DbErr> {
        device::Entity::find()
            .filter(device::Column::DeviceKey.eq(key))
            .one(&self.db)
            .await
    }

    async fn update_status(&self, id: i64, status: String) -> Result<(), DbErr> {
        let d: Option<device::Model> = device::Entity::find_by_id(id).one(&self.db).await?;
        let mut d: device::ActiveModel = d.ok_or(DbErr::RecordNotFound("Device not found".to_string()))?.into();
        d.status = Set(status);
        d.update(&self.db).await?;
        Ok(())
    }

    async fn update_last_connection(&self, id: i64) -> Result<(), DbErr> {
        let d: Option<device::Model> = device::Entity::find_by_id(id).one(&self.db).await?;
        let mut d: device::ActiveModel = d.ok_or(DbErr::RecordNotFound("Device not found".to_string()))?.into();
        d.last_connection = Set(Some(chrono::Utc::now().naive_utc()));
        d.update(&self.db).await?;
        Ok(())
    }
}
