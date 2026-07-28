use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020980_create_system_logs"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(SystemLogs::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(SystemLogs::IdLog)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(SystemLogs::IdUser).big_integer())
                    .col(ColumnDef::new(SystemLogs::Action).string().not_null())
                    .col(ColumnDef::new(SystemLogs::Device).string())
                    .col(ColumnDef::new(SystemLogs::Result).string().not_null())
                    .col(ColumnDef::new(SystemLogs::CreatedAt).date_time().not_null().default(Expr::current_timestamp()))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(SystemLogs::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum SystemLogs {
    Table,
    IdLog,
    IdUser,
    Action,
    Device,
    Result,
    CreatedAt,
}
