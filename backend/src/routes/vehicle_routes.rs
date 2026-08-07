use crate::controllers::{vehicle_controller, vehicle_request_controller};
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::routing::{delete, get, post};
use axum::{Router, middleware};

pub fn route_vehicle() -> Router<AppState> {
    Router::<AppState>::new()
        // Eliminado `post(vehicle_controller::create_vehicle)` para forzar uso de solicitudes
        .route("/my", get(vehicle_controller::get_my_vehicles))
        .route("/{id}", delete(vehicle_controller::delete_vehicle))
        .route("/request", post(vehicle_request_controller::create_request))
        .route("/request/my", get(vehicle_request_controller::get_my_requests))
        .route_layer(middleware::from_fn(auth_middleware))
}
