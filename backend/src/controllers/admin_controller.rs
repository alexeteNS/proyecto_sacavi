use crate::{
    dtos::admin_dtos::{AdminCreateUserDto, AdminUpdateUserDto},
    dtos::log_dtos::LogFilterParams,
    interfaces::services::i_dashboard_service::IDashboardService,
    interfaces::services::i_log_service::ILogService,
    interfaces::services::i_user_service::IUserService,
    state::AppState,
    utils::jwt::Claims,
};
use axum::{
    Json,
    extract::{Path, Query, State, Extension},
    http::StatusCode,
    response::IntoResponse,
};

pub async fn get_dashboard(State(state): State<AppState>, Extension(claims): Extension<Claims>) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.dashboard_service.get_dashboard().await {
        Ok(summary) => (StatusCode::OK, Json(summary)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_logs(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Query(filters): Query<LogFilterParams>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.log_service.get_logs(filters).await {
        Ok(logs) => (StatusCode::OK, Json(logs)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_users(State(state): State<AppState>, Extension(claims): Extension<Claims>) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.get_all_users_admin().await {
        Ok(users) => (StatusCode::OK, Json(users)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_user(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.get_user_admin(id).await {
        Ok(user) => (StatusCode::OK, Json(user)).into_response(),
        Err(e) => (StatusCode::NOT_FOUND, e).into_response(),
    }
}

pub async fn create_user(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(dto): Json<AdminCreateUserDto>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.create_user(dto).await {
        Ok(user) => (StatusCode::CREATED, Json(user)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn update_user(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
    Json(dto): Json<AdminUpdateUserDto>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.update_user_admin(id, dto).await {
        Ok(user) => (StatusCode::OK, Json(user)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn delete_user(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.delete_user(id).await {
        Ok(_) => (StatusCode::OK, "User deleted successfully").into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn reset_password(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
    Json(dto): Json<crate::dtos::admin_dtos::AdminResetPasswordDto>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.user_service.reset_password_admin(id, dto).await {
        Ok(_) => (StatusCode::OK, "Password reset successfully").into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}
