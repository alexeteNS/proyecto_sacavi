use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "access_records")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_record")]
    pub id: i64,
    pub id_vehicle: i64,
    pub id_device: Option<i64>,
    pub date_time: chrono::NaiveDateTime,
    pub r#type: String,
    pub status: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
