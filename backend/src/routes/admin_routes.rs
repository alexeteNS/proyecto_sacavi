use crate::controllers::admin_controller;
use crate::controllers::admin_access_controller;
use crate::controllers::vehicle_request_controller;
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::{
    Router,
    routing::{delete, get, post, put},
};

pub fn route_admin() -> Router<AppState> {
    Router::new()
        .route("/dashboard", get(admin_controller::get_dashboard))
        .route("/logs", get(admin_controller::get_logs))
        .route("/users", get(admin_controller::get_users))
        .route("/users", post(admin_controller::create_user))
        .route("/users/{id}", get(admin_controller::get_user))
        .route("/users/{id}", put(admin_controller::update_user))
        .route("/users/{id}", delete(admin_controller::delete_user))
        .route(
            "/users/{id}/reset-password",
            put(admin_controller::reset_password),
        )
        .route("/access/history", get(admin_access_controller::get_access_history))
        .route("/access/stats", get(admin_access_controller::get_access_stats))
        .route(
            "/vehicle-requests",
            get(vehicle_request_controller::get_all),
        )
        .route(
            "/vehicle-requests/pending",
            get(vehicle_request_controller::get_pending),
        )
        .route(
            "/vehicle-requests/in-revision",
            get(vehicle_request_controller::get_in_revision),
        )
        .route(
            "/vehicle-requests/{id}/in-revision",
            put(vehicle_request_controller::set_in_revision),
        )
        .route(
            "/vehicle-requests/{id}/approve",
            put(vehicle_request_controller::approve),
        )
        .route(
            "/vehicle-requests/{id}/reject",
            put(vehicle_request_controller::reject),
        )
        .route_layer(axum::middleware::from_fn(auth_middleware))
}
