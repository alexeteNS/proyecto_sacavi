use crate::controllers::device_controller;
use crate::state::AppState;
use axum::{routing::{get, post}, Router};

pub fn route_device() -> Router<AppState> {
    Router::<AppState>::new()
        .route("/register", post(device_controller::register_device))
        .route("/status/{device_key}", get(device_controller::get_status))
}
