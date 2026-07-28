use crate::dtos::user_dtos::{LoginResponseDto, UserLoginDto, UserRegisterDto, UserResponseDto};
use crate::entities::{permission, role, role_permission, user};
use crate::helpers::bycrpt;
use crate::interfaces::repositories::i_log_repository::ILogRepository;
use crate::interfaces::repositories::i_user_repository::IUserRepository;
use crate::interfaces::services::i_user_service::IUserService;
use crate::repositories::log_repository::LogRepository;
use crate::repositories::user_repository::UserRepository;
use crate::utils::jwt;
use sea_orm::*;

#[derive(Clone)]
pub struct UserService {
    pub user_repository: UserRepository,
    pub log_repository: LogRepository,
}

impl UserService {
    async fn user_to_response(&self, user: user::Model) -> Result<UserResponseDto, String> {
        let role = role::Entity::find_by_id(user.id_role)
            .one(&self.user_repository.db)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Role not found".to_string())?;

        let role_perms = role_permission::Entity::find()
            .filter(role_permission::Column::IdRole.eq(user.id_role))
            .all(&self.user_repository.db)
            .await
            .map_err(|e| e.to_string())?;

        let mut permissions = Vec::new();
        for rp in role_perms {
            let perm = permission::Entity::find_by_id(rp.id_permission)
                .one(&self.user_repository.db)
                .await
                .map_err(|e| e.to_string())?;
            if let Some(p) = perm {
                permissions.push(p.name_permission);
            }
        }

        Ok(UserResponseDto {
            id_user: user.id,
            name: user.name,
            email: user.email,
            role: role.name_role,
            permissions,
        })
    }
}

impl IUserService for UserService {
    async fn register(&self, mut dto: UserRegisterDto) -> Result<UserResponseDto, String> {
        dto.password = bycrpt::hash_password(dto.password);
        if dto.id_role.is_none() {
            let estudiante = role::Entity::find()
                .filter(role::Column::NameRole.eq("ESTUDIANTE"))
                .one(&self.user_repository.db)
                .await
                .map_err(|e| e.to_string())?
                .ok_or_else(|| "Default role ESTUDIANTE not found".to_string())?;
            dto.id_role = Some(estudiante.id_role);
        }
        let user = self
            .user_repository
            .register(dto)
            .await
            .map_err(|e| e.to_string())?;
        self.user_to_response(user).await
    }

    async fn login(&self, dto: UserLoginDto) -> Result<LoginResponseDto, String> {
        let user = self
            .user_repository
            .find_by_email(dto.email)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Invalid credentials".to_string())?;

        if !bycrpt::verify_password(dto.password, user.hash_password.clone()) {
            let _ = self
                .log_repository
                .log(Some(user.id), "LOGIN_FAILED", None, "FAILED")
                .await;
            return Err("Invalid credentials".to_string());
        }

        let role = role::Entity::find_by_id(user.id_role)
            .one(&self.user_repository.db)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "Role not found".to_string())?;

        let token = jwt::create_token(user.id, &role.name_role)?;
        let user_response = self.user_to_response(user).await?;

        let _ = self
            .log_repository
            .log(Some(user_response.id_user), "LOGIN_SUCCESS", None, "SUCCESS")
            .await;

        Ok(LoginResponseDto {
            token,
            user: user_response,
        })
    }

    async fn get_user(&self, id_user: i64) -> Result<UserResponseDto, String> {
        let user = self
            .user_repository
            .find_by_id(id_user)
            .await
            .map_err(|e| e.to_string())?
            .ok_or_else(|| "User not found".to_string())?;
        self.user_to_response(user).await
    }

    async fn update_user(
        &self,
        id_user: i64,
        name: String,
        email: String,
    ) -> Result<UserResponseDto, String> {
        let user = self
            .user_repository
            .update(id_user, name, email)
            .await
            .map_err(|e| e.to_string())?;
        self.user_to_response(user).await
    }

    async fn change_role(&self, id_user: i64, id_role: i64) -> Result<UserResponseDto, String> {
        let user = self
            .user_repository
            .update_role(id_user, id_role)
            .await
            .map_err(|e| e.to_string())?;
        let _ = self
            .log_repository
            .log(Some(id_user), "ROLE_CHANGED", None, "SUCCESS")
            .await;
        self.user_to_response(user).await
    }

    async fn delete_user(&self, id_user: i64) -> Result<(), String> {
        self.user_repository
            .delete(id_user)
            .await
            .map_err(|e| e.to_string())
    }
}
