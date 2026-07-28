use crate::dtos::device_dtos;
use crate::interfaces::services::i_device_service::IDeviceService;
use crate::state::AppState;
use axum::extract::{Json, Path, State};
use axum::http::StatusCode;

pub async fn register_device(
    State(state): State<AppState>,
    Json(dto): Json<device_dtos::RegisterDeviceDto>,
) -> Result<Json<device_dtos::DeviceResponseDto>, (StatusCode, String)> {
    let device = state
        .device_service
        .register(dto)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;

    Ok(Json(device))
}

pub async fn get_status(
    State(state): State<AppState>,
    Path(device_key): Path<String>,
) -> Result<Json<device_dtos::DeviceStatusResponse>, (StatusCode, String)> {
    let status = state
        .device_service
        .get_status(device_key)
        .await
        .map_err(|e| (StatusCode::NOT_FOUND, e))?;

    Ok(Json(status))
}
