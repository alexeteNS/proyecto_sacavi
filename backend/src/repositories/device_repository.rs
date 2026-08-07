use crate::entities::device;
use crate::interfaces::repositories::i_device_repository::IDeviceRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct DeviceRepository {
    pub db: DatabaseConnection,
}

impl IDeviceRepository for DeviceRepository {
    async fn register(
        &self,
        name: String,
        location: String,
        device_key: String,
    ) -> Result<device::Model, DbErr> {
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
        let mut d: device::ActiveModel = d
            .ok_or(DbErr::RecordNotFound("Device not found".to_string()))?
            .into();
        d.status = Set(status);
        d.update(&self.db).await?;
        Ok(())
    }

    async fn update_last_connection(&self, id: i64) -> Result<(), DbErr> {
        let d: Option<device::Model> = device::Entity::find_by_id(id).one(&self.db).await?;
        let mut d: device::ActiveModel = d
            .ok_or(DbErr::RecordNotFound("Device not found".to_string()))?
            .into();
        d.last_connection = Set(Some(chrono::Utc::now().naive_utc()));
        d.update(&self.db).await?;
        Ok(())
    }

    async fn get_all(&self) -> Result<Vec<device::Model>, DbErr> {
        device::Entity::find()
            .order_by_asc(device::Column::Name)
            .all(&self.db)
            .await
    }

    async fn count_online(&self) -> Result<i64, DbErr> {
        device::Entity::find()
            .filter(device::Column::Status.eq("ONLINE"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn delete(&self, id: i64) -> Result<(), DbErr> {
        device::Entity::delete_by_id(id).exec(&self.db).await?;
        Ok(())
    }

    async fn update_device_info(
        &self,
        id: i64,
        ip_address: Option<String>,
        mac_address: Option<String>,
        firmware: Option<String>,
        version: Option<String>,
        uptime_seconds: Option<i64>,
    ) -> Result<(), DbErr> {
        let d: Option<device::Model> = device::Entity::find_by_id(id).one(&self.db).await?;
        let mut d: device::ActiveModel = d
            .ok_or(DbErr::RecordNotFound("Device not found".to_string()))?
            .into();
        if ip_address.is_some() {
            d.ip_address = Set(ip_address);
        }
        if mac_address.is_some() {
            d.mac_address = Set(mac_address);
        }
        if firmware.is_some() {
            d.firmware = Set(firmware);
        }
        if version.is_some() {
            d.version = Set(version);
        }
        if uptime_seconds.is_some() {
            d.uptime_seconds = Set(uptime_seconds);
        }
        d.update(&self.db).await?;
        Ok(())
    }
}
