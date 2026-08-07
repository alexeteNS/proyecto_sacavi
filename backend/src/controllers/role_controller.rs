use crate::dtos::{role_dtos, user_dtos};
use crate::entities::role;
use crate::interfaces::repositories::i_role_repository::IRoleRepository;
use crate::interfaces::services::i_user_service::IUserService;
use crate::state::AppState;
use crate::utils::jwt::Claims;
use axum::extract::{Extension, Json, Path, State};
use axum::http::StatusCode;
use sea_orm::EntityTrait;

pub async fn get_role_permissions(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<role_dtos::RolePermissionsResponse>, (StatusCode, String)> {
    let role_entity = role::Entity::find_by_id(id)
        .one(&state.user_service.user_repository.db)
        .await
        .map_err(|e| (StatusCode::NOT_FOUND, e.to_string()))?
        .ok_or_else(|| (StatusCode::NOT_FOUND, "Role not found".to_string()))?;

    let permissions = state
        .role_repository
        .get_permissions_by_role(id)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    Ok(Json(role_dtos::RolePermissionsResponse {
        role: role_entity.name_role,
        permissions,
    }))
}

pub async fn change_user_role(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
    Json(dto): Json<role_dtos::ChangeRoleDto>,
) -> Result<Json<user_dtos::UserResponseDto>, (StatusCode, String)> {
    if claims.role != "ADMIN" {
        return Err((
            StatusCode::FORBIDDEN,
            "Only ADMIN can change roles".to_string(),
        ));
    }

    let user = state
        .user_service
        .change_role(id, dto.id_role)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;

    Ok(Json(user))
}
