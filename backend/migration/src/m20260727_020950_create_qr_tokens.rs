use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020950_create_qr_tokens"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(QrTokens::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(QrTokens::IdQr)
                            .big_integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(QrTokens::IdUser).big_integer().not_null())
                    .col(ColumnDef::new(QrTokens::IdVehicle).big_integer())
                    .col(ColumnDef::new(QrTokens::Token).string().not_null().unique_key())
                    .col(ColumnDef::new(QrTokens::ExpiresAt).date_time().not_null())
                    .col(ColumnDef::new(QrTokens::Used).boolean().not_null().default(false))
                    .col(ColumnDef::new(QrTokens::CreatedAt).date_time().not_null().default(Expr::current_timestamp()))
                    .foreign_key(
                        ForeignKey::create()
                            .from(QrTokens::Table, QrTokens::IdUser)
                            .to(Users::Table, Users::IdUser),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(QrTokens::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum QrTokens {
    Table,
    IdQr,
    IdUser,
    IdVehicle,
    Token,
    ExpiresAt,
    Used,
    CreatedAt,
}

#[derive(DeriveIden)]
enum Users {
    Table,
    IdUser,
}
