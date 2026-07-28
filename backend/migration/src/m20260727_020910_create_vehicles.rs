use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020910_create_vehicles"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Vehicles::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Vehicles::IdVehicle)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Vehicles::Plate).string().not_null().unique_key())
                    .col(ColumnDef::new(Vehicles::Brand).string().not_null())
                    .col(ColumnDef::new(Vehicles::Model).string().not_null())
                    .col(ColumnDef::new(Vehicles::Color).string().not_null())
                    .col(ColumnDef::new(Vehicles::IdUser).big_integer().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .from(Vehicles::Table, Vehicles::IdUser)
                            .to(Users::Table, Users::IdUser),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Vehicles::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Vehicles {
    Table,
    IdVehicle,
    Plate,
    Brand,
    Model,
    Color,
    IdUser,
}

#[derive(DeriveIden)]
enum Users {
    Table,
    IdUser,
}
