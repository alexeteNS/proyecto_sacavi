use crate::entities::{permission, role, role_permission};
use crate::interfaces::repositories::i_role_repository::IRoleRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct RoleRepository {
    pub db: DatabaseConnection,
}

impl IRoleRepository for RoleRepository {
    async fn get_permissions_by_role(&self, id_role: i64) -> Result<Vec<String>, DbErr> {
        let _role = role::Entity::find_by_id(id_role)
            .one(&self.db)
            .await?
            .ok_or(DbErr::RecordNotFound("Role not found".to_string()))?;

        let rps = role_permission::Entity::find()
            .filter(role_permission::Column::IdRole.eq(id_role))
            .all(&self.db)
            .await?;

        let mut perms = Vec::new();
        for rp in rps {
            let perm = permission::Entity::find_by_id(rp.id_permission)
                .one(&self.db)
                .await?;
            if let Some(p) = perm {
                perms.push(p.name_permission);
            }
        }
        Ok(perms)
    }
}
