use crate::controllers::qr_controller;
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::{Router, middleware, routing::get};

pub fn route_qr() -> Router<AppState> {
    Router::<AppState>::new()
        .route("/generate", get(qr_controller::generate_qr))
        .route_layer(middleware::from_fn(auth_middleware))
}
