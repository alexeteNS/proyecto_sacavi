use axum::{
    extract::{Query, State},
    Json,
};

use crate::dtos::admin_dtos::{AccessHistoryResponseDto, AccessStatsResponseDto};
use crate::dtos::log_dtos::LogFilterParams;
use crate::interfaces::repositories::i_access_repository::IAccessRepository;
use crate::interfaces::repositories::i_device_repository::IDeviceRepository;
use crate::state::AppState;
use tracing::error;

pub async fn get_access_history(
    State(state): State<AppState>,
    Query(filters): Query<LogFilterParams>,
) -> Json<Vec<AccessHistoryResponseDto>> {
    match state.dashboard_service.access_repository.get_enriched_history(filters).await {
        Ok(history) => Json(history),
        Err(e) => {
            error!("Error fetching enriched access history: {:?}", e);
            Json(vec![])
        }
    }
}

pub async fn get_access_stats(
    State(state): State<AppState>,
) -> Json<AccessStatsResponseDto> {
    let today_total = state.dashboard_service.access_repository.count_today().await.unwrap_or(0);
    let entradas = state.dashboard_service.access_repository.count_entries_today().await.unwrap_or(0);
    let salidas = state.dashboard_service.access_repository.count_exits_today().await.unwrap_or(0);
    let denied = state.dashboard_service.access_repository.count_denied_today().await.unwrap_or(0);
    let active_esp32 = state.dashboard_service.device_repository.get_all().await.unwrap_or_default().len() as i64;

    Json(AccessStatsResponseDto {
        today_total,
        entradas,
        salidas,
        denied,
        avg_time: "N/A".to_string(),
        active_esp32,
    })
}
