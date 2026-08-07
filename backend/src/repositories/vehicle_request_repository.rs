use crate::entities::vehicle_request;
use crate::interfaces::repositories::i_vehicle_request_repository::IVehicleRequestRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct VehicleRequestRepository {
    pub db: DatabaseConnection,
}

impl IVehicleRequestRepository for VehicleRequestRepository {
    async fn create(
        &self,
        id_user: i64,
        plate: String,
        brand: String,
        model: String,
        color: String,
    ) -> Result<vehicle_request::Model, DbErr> {
        let req = vehicle_request::ActiveModel {
            id_user: Set(id_user),
            plate: Set(plate),
            brand: Set(brand),
            model: Set(model),
            color: Set(color),
            status: Set("PENDIENTE".to_string()),
            created_at: Set(chrono::Utc::now().naive_utc()),
            updated_at: Set(None),
            ..Default::default()
        };
        req.insert(&self.db).await
    }

    async fn find_by_user(&self, id_user: i64) -> Result<Vec<vehicle_request::Model>, DbErr> {
        vehicle_request::Entity::find()
            .filter(vehicle_request::Column::IdUser.eq(id_user))
            .order_by_desc(vehicle_request::Column::CreatedAt)
            .all(&self.db)
            .await
    }

    async fn find_all(&self) -> Result<Vec<vehicle_request::Model>, DbErr> {
        vehicle_request::Entity::find()
            .order_by_desc(vehicle_request::Column::CreatedAt)
            .all(&self.db)
            .await
    }

    async fn find_pending(&self) -> Result<Vec<vehicle_request::Model>, DbErr> {
        vehicle_request::Entity::find()
            .filter(vehicle_request::Column::Status.eq("PENDIENTE"))
            .order_by_asc(vehicle_request::Column::CreatedAt)
            .all(&self.db)
            .await
    }

    async fn find_in_revision(&self) -> Result<Vec<vehicle_request::Model>, DbErr> {
        vehicle_request::Entity::find()
            .filter(vehicle_request::Column::Status.eq("EN_REVISION"))
            .order_by_asc(vehicle_request::Column::CreatedAt)
            .all(&self.db)
            .await
    }

    async fn find_by_id(&self, id: i64) -> Result<Option<vehicle_request::Model>, DbErr> {
        vehicle_request::Entity::find_by_id(id).one(&self.db).await
    }

    async fn update_status(
        &self,
        id: i64,
        status: String,
    ) -> Result<vehicle_request::Model, DbErr> {
        let req = vehicle_request::Entity::find_by_id(id)
            .one(&self.db)
            .await?
            .ok_or(DbErr::RecordNotFound(
                "VehicleRequest not found".to_string(),
            ))?;
        let mut req: vehicle_request::ActiveModel = req.into();
        req.status = Set(status);
        req.updated_at = Set(Some(chrono::Utc::now().naive_utc()));
        req.update(&self.db).await
    }

    async fn count_pending(&self) -> Result<i64, DbErr> {
        vehicle_request::Entity::find()
            .filter(vehicle_request::Column::Status.eq("PENDIENTE"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn count_in_revision(&self) -> Result<i64, DbErr> {
        vehicle_request::Entity::find()
            .filter(vehicle_request::Column::Status.eq("EN_REVISION"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }
}
