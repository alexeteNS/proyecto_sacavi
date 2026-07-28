use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "vehicle_requests")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_request")]
    pub id: i64,
    pub id_user: i64,
    pub plate: String,
    pub status: String,
    pub created_at: chrono::NaiveDateTime,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
