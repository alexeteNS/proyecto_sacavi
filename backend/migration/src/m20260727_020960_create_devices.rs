use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020960_create_devices"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Devices::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Devices::IdDevice)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Devices::Name).string().not_null())
                    .col(ColumnDef::new(Devices::Location).string().not_null())
                    .col(ColumnDef::new(Devices::DeviceKey).string().not_null().unique_key())
                    .col(ColumnDef::new(Devices::Status).string().not_null().default("ONLINE"))
                    .col(ColumnDef::new(Devices::LastConnection).date_time())
                    .col(ColumnDef::new(Devices::CreatedAt).date_time().not_null().default(Expr::current_timestamp()))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Devices::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Devices {
    Table,
    IdDevice,
    Name,
    Location,
    DeviceKey,
    Status,
    LastConnection,
    CreatedAt,
}
