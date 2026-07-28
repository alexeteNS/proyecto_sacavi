use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "role_permissions")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id_role: i64,
    #[sea_orm(primary_key, auto_increment = false)]
    pub id_permission: i64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
