use crate::dtos::user_dtos;
use crate::interfaces::services::i_user_service::IUserService;
use crate::state::AppState;
use crate::utils::jwt::Claims;
use axum::extract::{Extension, Json, State};
use axum::http::StatusCode;

pub async fn hello(State(_appstate): State<AppState>) -> &'static str {
    "Hola mundo"
}

pub async fn register(
    State(state): State<AppState>,
    Json(dto): Json<user_dtos::UserRegisterDto>,
) -> Result<Json<user_dtos::UserResponseDto>, (StatusCode, String)> {
    let user = state
        .user_service
        .register(dto)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;
    Ok(Json(user))
}

pub async fn login(
    State(state): State<AppState>,
    Json(dto): Json<user_dtos::UserLoginDto>,
) -> Result<Json<user_dtos::LoginResponseDto>, (StatusCode, String)> {
    let res = state
        .user_service
        .login(dto)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;
    Ok(Json(res))
}

pub async fn profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<user_dtos::UserResponseDto>, (StatusCode, String)> {
    let user = state
        .user_service
        .get_user(claims.sub)
        .await
        .map_err(|e| (StatusCode::NOT_FOUND, e))?;
    Ok(Json(user))
}

pub async fn update_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(dto): Json<user_dtos::UserUpdateDto>,
) -> Result<Json<user_dtos::UserResponseDto>, (StatusCode, String)> {
    let user = state
        .user_service
        .update_user(claims.sub, dto.name, dto.email)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;
    Ok(Json(user))
}
