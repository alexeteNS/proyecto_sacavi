use crate::entities::vehicle;
use crate::interfaces::repositories::i_vehicle_repository::IVehicleRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct VehicleRepository {
    pub db: DatabaseConnection,
}

impl IVehicleRepository for VehicleRepository {
    async fn create(
        &self,
        plate: String,
        brand: String,
        model: String,
        color: String,
        id_user: i64,
    ) -> Result<vehicle::Model, DbErr> {
        let v = vehicle::ActiveModel {
            plate: Set(plate),
            brand: Set(brand),
            model: Set(model),
            color: Set(color),
            id_user: Set(id_user),
            ..Default::default()
        };
        v.insert(&self.db).await
    }

    async fn find_by_id(&self, id: i64) -> Result<Option<vehicle::Model>, DbErr> {
        vehicle::Entity::find_by_id(id).one(&self.db).await
    }

    async fn find_by_user(&self, id_user: i64) -> Result<Vec<vehicle::Model>, DbErr> {
        vehicle::Entity::find()
            .filter(vehicle::Column::IdUser.eq(id_user))
            .all(&self.db)
            .await
    }

    async fn find_by_plate(&self, plate: String) -> Result<Option<vehicle::Model>, DbErr> {
        vehicle::Entity::find()
            .filter(vehicle::Column::Plate.eq(plate))
            .one(&self.db)
            .await
    }

    async fn delete(&self, id: i64) -> Result<(), DbErr> {
        vehicle::Entity::delete_by_id(id).exec(&self.db).await?;
        Ok(())
    }

    async fn find_all(&self) -> Result<Vec<vehicle::Model>, DbErr> {
        vehicle::Entity::find().all(&self.db).await
    }

    async fn count_all(&self) -> Result<i64, DbErr> {
        vehicle::Entity::find()
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn count_by_user(&self, id_user: i64) -> Result<i64, DbErr> {
        vehicle::Entity::find()
            .filter(vehicle::Column::IdUser.eq(id_user))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }
}
