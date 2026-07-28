use crate::dtos::qr_dtos;
use crate::interfaces::services::i_qr_service::IQrService;
use crate::state::AppState;
use crate::utils::jwt::Claims;
use axum::extract::{Extension, Json, State};
use axum::http::StatusCode;

pub async fn generate_qr(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<qr_dtos::QrGenerateResponse>, (StatusCode, String)> {
    let res = state
        .qr_service
        .generate_qr(claims.sub)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e))?;

    Ok(Json(res))
}
