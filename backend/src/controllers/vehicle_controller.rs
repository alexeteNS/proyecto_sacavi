use crate::dtos::vehicle_dtos::{VehicleCreateDto, VehicleResponseDto};
use crate::interfaces::services::i_vehicle_service::IVehicleService;
use crate::state::AppState;
use crate::utils::jwt::Claims;
use axum::extract::{Extension, Json, Path, State};
use axum::http::StatusCode;
use axum::response::IntoResponse;

pub async fn create_vehicle(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(dto): Json<VehicleCreateDto>,
) -> Result<Json<VehicleResponseDto>, (StatusCode, String)> {
    let vehicle = state
        .vehicle_service
        .create(dto, claims.sub)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;

    Ok(Json(vehicle))
}

pub async fn get_my_vehicles(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Json<Vec<VehicleResponseDto>> {
    let vehicles = state
        .vehicle_service
        .get_my_vehicles(claims.sub)
        .await
        .unwrap_or_default();

    Json(vehicles)
}

pub async fn delete_vehicle(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    state
        .vehicle_service
        .delete(id, claims.sub, &claims.role)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;

    Ok(StatusCode::NO_CONTENT)
}
