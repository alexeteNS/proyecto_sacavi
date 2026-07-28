use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "users")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_user")]
    pub id: i64,
    pub name: String,
    #[sea_orm(unique)]
    pub email: String,
    pub hash_password: String,
    pub id_role: i64,
    pub created_at: Option<chrono::NaiveDateTime>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
