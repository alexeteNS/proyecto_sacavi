use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "system_logs")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_log")]
    pub id: i64,
    pub id_user: Option<i64>,
    pub action: String,
    pub device: Option<String>,
    pub result: String,
    pub created_at: chrono::NaiveDateTime,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
