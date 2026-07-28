use crate::dtos::{access_dtos, device_dtos, qr_dtos};
use crate::interfaces::services::i_access_service::IAccessService;
use crate::state::AppState;
use crate::utils::jwt::Claims;
use axum::extract::{Extension, Json, State};
use axum::http::StatusCode;

pub async fn scan_qr(
    State(state): State<AppState>,
    Json(dto): Json<qr_dtos::QrScanRequest>,
) -> Result<Json<device_dtos::ScanResponseDto>, (StatusCode, String)> {
    let res = state
        .access_service
        .scan_qr(dto.token, dto.device_id)
        .await
        .map_err(|e| (StatusCode::BAD_REQUEST, e))?;

    Ok(Json(res))
}

pub async fn get_history(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<Vec<access_dtos::AccessResponseDto>>, (StatusCode, String)> {
    let res = state
        .access_service
        .get_history(claims.sub, &claims.role)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e))?;

    Ok(Json(res))
}

pub async fn open_gate(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(dto): Json<access_dtos::OpenGateDto>,
) -> Result<Json<access_dtos::AccessResponseDto>, (StatusCode, String)> {
    let res = state
        .access_service
        .open_gate(dto.id_vehicle, claims.sub, &claims.role)
        .await
        .map_err(|e| (StatusCode::UNAUTHORIZED, e))?;

    Ok(Json(res))
}
