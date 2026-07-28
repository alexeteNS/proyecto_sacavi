use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020855_create_role_permissions"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(RolePermissions::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(RolePermissions::IdRole)
                            .big_integer()
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(RolePermissions::IdPermission)
                            .big_integer()
                            .not_null(),
                    )
                    .primary_key(
                        Index::create()
                            .col(RolePermissions::IdRole)
                            .col(RolePermissions::IdPermission),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_role_permission_role")
                            .from(RolePermissions::Table, RolePermissions::IdRole)
                            .to(Roles::Table, Roles::IdRole),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk_role_permission_permission")
                            .from(RolePermissions::Table, RolePermissions::IdPermission)
                            .to(Permissions::Table, Permissions::IdPermission),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(RolePermissions::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum RolePermissions {
    Table,

    IdRole,

    IdPermission,
}

#[derive(DeriveIden)]
enum Roles {
    Table,

    IdRole,
}

#[derive(DeriveIden)]
enum Permissions {
    Table,

    IdPermission,
}
