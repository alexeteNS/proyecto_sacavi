use sea_orm::entity::prelude::*;
use strum::EnumIter;

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, DeriveActiveModelBehavior)]
#[sea_orm(table_name = "qr_tokens")]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true, column_name = "id_qr")]
    pub id: i64,
    pub id_user: i64,
    pub id_vehicle: Option<i64>,
    #[sea_orm(unique)]
    pub token: String,
    pub expires_at: chrono::NaiveDateTime,
    pub used: bool,
    pub created_at: chrono::NaiveDateTime,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, EnumIter, DeriveRelation)]
pub enum Relation {}
