use crate::controllers::access_controller;
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::{middleware, routing::{get, post}, Router};

pub fn route_access() -> Router<AppState> {
    let public_routes = Router::<AppState>::new()
        .route("/scan", post(access_controller::scan_qr));

    let protected_routes = Router::<AppState>::new()
        .route("/history", get(access_controller::get_history))
        .route("/open", post(access_controller::open_gate))
        .route_layer(middleware::from_fn(auth_middleware));

    public_routes.merge(protected_routes)
}
