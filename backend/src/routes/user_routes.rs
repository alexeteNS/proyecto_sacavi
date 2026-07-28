use crate::controllers::{role_controller, user_controller};
use crate::middlewares::auth::auth_middleware;
use crate::state::AppState;
use axum::{middleware, routing::{get, post, put}, Router};

pub fn route_user() -> Router<AppState> {
    let public_routes = Router::<AppState>::new()
        .route("/hello", get(user_controller::hello))
        .route("/register", post(user_controller::register))
        .route("/login", post(user_controller::login));

    let protected_routes = Router::<AppState>::new()
        .route("/profile", get(user_controller::profile))
        .route("/update", put(user_controller::update_profile))
        .route("/{id}/role", put(role_controller::change_user_role))
        .route_layer(middleware::from_fn(auth_middleware));

    public_routes.merge(protected_routes)
}
