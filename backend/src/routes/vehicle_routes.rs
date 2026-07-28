use crate::controllers::vehicle_controller;
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::routing::{delete, get, post};
use axum::{middleware, Router};

pub fn route_vehicle() -> Router<AppState> {
    Router::<AppState>::new()
        .route("/", post(vehicle_controller::create_vehicle))
        .route("/my", get(vehicle_controller::get_my_vehicles))
        .route("/{id}", delete(vehicle_controller::delete_vehicle))
        .route_layer(middleware::from_fn(auth_middleware))
}
