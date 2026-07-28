use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020930_create_vehicle_requests"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(VehicleRequests::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(VehicleRequests::IdRequest)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(VehicleRequests::IdUser).big_integer().not_null())
                    .col(ColumnDef::new(VehicleRequests::Plate).string().not_null())
                    .col(ColumnDef::new(VehicleRequests::Status).string().not_null())
                    .col(ColumnDef::new(VehicleRequests::CreatedAt).date_time().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .from(VehicleRequests::Table, VehicleRequests::IdUser)
                            .to(Users::Table, Users::IdUser),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(VehicleRequests::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum VehicleRequests {
    Table,
    IdRequest,
    IdUser,
    Plate,
    Status,
    CreatedAt,
}

#[derive(DeriveIden)]
enum Users {
    Table,
    IdUser,
}
