use crate::controllers::role_controller;
use crate::state::AppState;
use axum::{routing::get, Router};

pub fn route_role() -> Router<AppState> {
    Router::<AppState>::new()
        .route("/{id}/permissions", get(role_controller::get_role_permissions))
}
