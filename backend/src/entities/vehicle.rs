use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "vehicles")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_vehicle")]
    pub id: i64,
    #[sea_orm(unique)]
    pub plate: String,
    pub brand: String,
    pub model: String,
    pub color: String,
    pub id_user: i64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
