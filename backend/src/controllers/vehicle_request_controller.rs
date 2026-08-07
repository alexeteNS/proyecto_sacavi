use crate::{
    interfaces::services::i_vehicle_request_service::IVehicleRequestService, state::AppState,
    utils::jwt::Claims,
};
use axum::{
    Json,
    extract::{Path, State, Extension},
    http::StatusCode,
    response::IntoResponse,
};
use crate::dtos::vehicle_dtos::VehicleRequestCreateDto;

pub async fn create_request(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(dto): Json<VehicleRequestCreateDto>,
) -> impl IntoResponse {
    match state
        .vehicle_request_service
        .create_request(dto.plate, dto.brand, dto.model, dto.color, claims.sub)
        .await
    {
        Ok(req) => (StatusCode::CREATED, Json(req)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn get_my_requests(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> impl IntoResponse {
    match state.vehicle_request_service.get_my_requests(claims.sub).await {
        Ok(reqs) => (StatusCode::OK, Json(reqs)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_all(State(state): State<AppState>, Extension(claims): Extension<Claims>) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.get_all_requests().await {
        Ok(reqs) => (StatusCode::OK, Json(reqs)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_pending(State(state): State<AppState>, Extension(claims): Extension<Claims>) -> impl IntoResponse {
    if claims.role != "ADMIN" && claims.role != "GUARDIA" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.get_pending().await {
        Ok(reqs) => (StatusCode::OK, Json(reqs)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn get_in_revision(State(state): State<AppState>, Extension(claims): Extension<Claims>) -> impl IntoResponse {
    if claims.role != "ADMIN" && claims.role != "GUARDIA" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.get_in_revision().await {
        Ok(reqs) => (StatusCode::OK, Json(reqs)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e).into_response(),
    }
}

pub async fn set_in_revision(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.mark_in_revision(id, claims.sub).await {
        Ok(req) => (StatusCode::OK, Json(req)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn approve(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.approve(id, claims.sub).await {
        Ok(req) => (StatusCode::OK, Json(req)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}

pub async fn reject(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    if claims.role != "ADMIN" {
        return (StatusCode::FORBIDDEN, "Access denied").into_response();
    }
    match state.vehicle_request_service.reject(id, claims.sub).await {
        Ok(req) => (StatusCode::OK, Json(req)).into_response(),
        Err(e) => (StatusCode::BAD_REQUEST, e).into_response(),
    }
}
