use crate::entities::access_record;
use crate::interfaces::repositories::i_access_repository::IAccessRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct AccessRepository {
    pub db: DatabaseConnection,
}

impl IAccessRepository for AccessRepository {
    async fn create_record(
        &self,
        id_vehicle: i64,
        r#type: String,
        status: String,
    ) -> Result<access_record::Model, DbErr> {
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

    async fn get_last_by_vehicle(
        &self,
        id_vehicle: i64,
    ) -> Result<Option<access_record::Model>, DbErr> {
        access_record::Entity::find()
            .filter(access_record::Column::IdVehicle.eq(id_vehicle))
            .order_by_desc(access_record::Column::DateTime)
            .one(&self.db)
            .await
    }

    async fn count_today(&self) -> Result<i64, DbErr> {
        let today = chrono::Utc::now().naive_utc().date();
        let start = today.and_hms_opt(0, 0, 0).unwrap();
        let end = today.and_hms_opt(23, 59, 59).unwrap();
        access_record::Entity::find()
            .filter(access_record::Column::DateTime.between(start, end))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn count_entries_today(&self) -> Result<i64, DbErr> {
        let today = chrono::Utc::now().naive_utc().date();
        let start = today.and_hms_opt(0, 0, 0).unwrap();
        let end = today.and_hms_opt(23, 59, 59).unwrap();
        access_record::Entity::find()
            .filter(access_record::Column::DateTime.between(start, end))
            .filter(access_record::Column::Type.eq("ENTRADA"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn count_exits_today(&self) -> Result<i64, DbErr> {
        let today = chrono::Utc::now().naive_utc().date();
        let start = today.and_hms_opt(0, 0, 0).unwrap();
        let end = today.and_hms_opt(23, 59, 59).unwrap();
        access_record::Entity::find()
            .filter(access_record::Column::DateTime.between(start, end))
            .filter(access_record::Column::Type.eq("SALIDA"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }

    async fn get_all_history(&self, limit: u64) -> Result<Vec<access_record::Model>, DbErr> {
        access_record::Entity::find()
            .order_by_desc(access_record::Column::DateTime)
            .limit(limit)
            .all(&self.db)
            .await
    }

    async fn get_recent(&self, n: u64) -> Result<Vec<access_record::Model>, DbErr> {
        access_record::Entity::find()
            .order_by_desc(access_record::Column::DateTime)
            .limit(n)
            .all(&self.db)
            .await
    }

    async fn get_enriched_history(&self, filters: crate::dtos::log_dtos::LogFilterParams) -> Result<Vec<crate::dtos::admin_dtos::AccessHistoryResponseDto>, DbErr> {
        // Raw SQL for joining
        let limit = filters.limit.unwrap_or(50);
        let mut query_params: Vec<sea_orm::Value> = vec![];
        let mut conditions = vec!["1=1".to_string()];

        if let Some(user_id) = filters.user_id {
            conditions.push(format!("u.id_user = ${}", query_params.len() + 1));
            query_params.push(user_id.into());
        }

        let sql = format!(
            r#"
            SELECT 
                a.id_record, a.date_time, a.type as type_, a.status,
                d.id_device, d.name as device_name, d.location as device_location,
                v.id_vehicle, v.plate, v.brand, v.model, v.color,
                u.id_user, u.name as user_name, u.email as user_email,
                r.name_role
            FROM access_records a
            LEFT JOIN devices d ON a.id_device = d.id_device
            INNER JOIN vehicles v ON a.id_vehicle = v.id_vehicle
            INNER JOIN users u ON v.id_user = u.id_user
            INNER JOIN roles r ON u.id_role = r.id_role
            WHERE {}
            ORDER BY a.date_time DESC
            LIMIT ${}
            "#,
            conditions.join(" AND "),
            query_params.len() + 1
        );
        query_params.push(limit.into());

        let backend = self.db.get_database_backend();
        let stmt = Statement::from_sql_and_values(backend, &sql, query_params);
        
        let results = FlatAccessRecord::find_by_statement(stmt)
            .all(&self.db)
            .await?;

        Ok(results.into_iter().map(|row| row.into_dto()).collect())
    }

    async fn count_denied_today(&self) -> Result<i64, DbErr> {
        let today = chrono::Utc::now().naive_utc().date();
        let start = today.and_hms_opt(0, 0, 0).unwrap();
        let end = today.and_hms_opt(23, 59, 59).unwrap();
        access_record::Entity::find()
            .filter(access_record::Column::DateTime.between(start, end))
            .filter(access_record::Column::Status.eq("RECHAZADO"))
            .count(&self.db)
            .await
            .map(|c| c as i64)
    }
}

#[derive(FromQueryResult)]
struct FlatAccessRecord {
    id_record: i64,
    date_time: chrono::NaiveDateTime,
    type_: String,
    status: String,
    id_device: Option<i64>,
    device_name: Option<String>,
    device_location: Option<String>,
    id_vehicle: i64,
    plate: String,
    brand: String,
    model: String,
    color: String,
    id_user: i64,
    user_name: String,
    user_email: String,
    name_role: String,
}

impl FlatAccessRecord {
    fn into_dto(self) -> crate::dtos::admin_dtos::AccessHistoryResponseDto {
        crate::dtos::admin_dtos::AccessHistoryResponseDto {
            id_record: self.id_record,
            date_time: self.date_time.format("%Y-%m-%dT%H:%M:%S").to_string(),
            r#type: self.type_,
            status: self.status,
            device: self.id_device.map(|id| crate::dtos::admin_dtos::DeviceInfoDto {
                id_device: id,
                name: self.device_name.unwrap_or_default(),
                location: self.device_location.unwrap_or_default(),
            }),
            vehicle: crate::dtos::admin_dtos::VehicleInfoDto {
                id_vehicle: self.id_vehicle,
                plate: self.plate,
                brand: self.brand,
                model: self.model,
                color: self.color,
            },
            owner: crate::dtos::admin_dtos::OwnerInfoDto {
                id_user: self.id_user,
                name: self.user_name,
                email: self.user_email,
                role: self.name_role,
            },
        }
    }
}
