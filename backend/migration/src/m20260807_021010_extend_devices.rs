use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260807_021010_extend_devices"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Devices::Firmware).string().null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Devices::Version).string().null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Devices::IpAddress).string().null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Devices::MacAddress).string().null(),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Devices::UptimeSeconds).big_integer().null(),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Devices::Table)
                    .drop_column(Devices::Firmware)
                    .drop_column(Devices::Version)
                    .drop_column(Devices::IpAddress)
                    .drop_column(Devices::MacAddress)
                    .drop_column(Devices::UptimeSeconds)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum Devices {
    Table,
    Firmware,
    Version,
    IpAddress,
    MacAddress,
    UptimeSeconds,
}
