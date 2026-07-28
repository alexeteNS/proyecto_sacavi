use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "devices")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_device")]
    pub id: i64,
    pub name: String,
    pub location: String,
    #[sea_orm(unique)]
    pub device_key: String,
    pub status: String,
    pub last_connection: Option<chrono::NaiveDateTime>,
    pub created_at: chrono::NaiveDateTime,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
