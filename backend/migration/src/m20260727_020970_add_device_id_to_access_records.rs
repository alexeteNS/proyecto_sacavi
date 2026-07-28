use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020970_add_device_id_to_access_records"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(AccessRecords::Table)
                    .add_column_if_not_exists(ColumnDef::new(AccessRecords::IdDevice).big_integer())
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(AccessRecords::Table)
                    .drop_column(AccessRecords::IdDevice)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum AccessRecords {
    Table,
    IdDevice,
}
