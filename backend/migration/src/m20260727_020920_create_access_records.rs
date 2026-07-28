use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020920_create_access_records"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(AccessRecords::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(AccessRecords::IdRecord)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(AccessRecords::IdVehicle).big_integer().not_null())
                    .col(ColumnDef::new(AccessRecords::DateTime).date_time().not_null())
                    .col(ColumnDef::new(AccessRecords::Type).string().not_null())
                    .col(ColumnDef::new(AccessRecords::Status).string().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .from(AccessRecords::Table, AccessRecords::IdVehicle)
                            .to(Vehicles::Table, Vehicles::IdVehicle),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(AccessRecords::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum AccessRecords {
    Table,
    IdRecord,
    IdVehicle,
    DateTime,
    Type,
    Status,
}

#[derive(DeriveIden)]
enum Vehicles {
    Table,
    IdVehicle,
}
