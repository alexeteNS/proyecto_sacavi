use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260807_021000_extend_vehicle_requests"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(VehicleRequests::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(VehicleRequests::Brand)
                            .string()
                            .not_null()
                            .default(""),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(VehicleRequests::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(VehicleRequests::Model)
                            .string()
                            .not_null()
                            .default(""),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(VehicleRequests::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(VehicleRequests::Color)
                            .string()
                            .not_null()
                            .default(""),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(VehicleRequests::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(VehicleRequests::UpdatedAt).date_time().null(),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(VehicleRequests::Table)
                    .drop_column(VehicleRequests::Brand)
                    .drop_column(VehicleRequests::Model)
                    .drop_column(VehicleRequests::Color)
                    .drop_column(VehicleRequests::UpdatedAt)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum VehicleRequests {
    Table,
    Brand,
    Model,
    Color,
    UpdatedAt,
}
