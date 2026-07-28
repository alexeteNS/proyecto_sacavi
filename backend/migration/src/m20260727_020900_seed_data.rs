use sea_orm_migration::prelude::*;

pub struct Migration;

impl MigrationName for Migration {
    fn name(&self) -> &str {
        "m20260727_020900_seed_data"
    }
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();

        db.execute_unprepared(
            r#"INSERT INTO roles (name_role) VALUES
                ('ADMIN'),
                ('GUARDIA'),
                ('ESTUDIANTE')
            ON CONFLICT DO NOTHING"#,
        )
        .await?;

        db.execute_unprepared(
            r#"INSERT INTO permissions (name_permission) VALUES
                ('ABRIR_PLUMA'),
                ('VER_REGISTROS'),
                ('REGISTRAR_VEHICULO')
            ON CONFLICT DO NOTHING"#,
        )
        .await?;

        db.execute_unprepared(
            r#"
                INSERT INTO role_permissions (id_role, id_permission) VALUES
                    (1, 1), (1, 2), (1, 3),
                    (2, 1), (2, 2),
                    (3, 3)
                ON CONFLICT DO NOTHING
            "#,
        )
        .await?;

        Ok(())
    }

    async fn down(&self, _manager: &SchemaManager) -> Result<(), DbErr> {
        Ok(())
    }
}
