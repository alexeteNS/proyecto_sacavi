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
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::vehicle::Entity",
        from = "Column::IdVehicle",
        to = "super::vehicle::Column::Id"
    )]
    Vehicle,
    #[sea_orm(
        belongs_to = "super::device::Entity",
        from = "Column::IdDevice",
        to = "super::device::Column::Id"
    )]
    Device,
}

impl Related<super::vehicle::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Vehicle.def()
    }
}

impl Related<super::device::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Device.def()
    }
}
