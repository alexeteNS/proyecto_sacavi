use crate::{controllers::user_controller, state::AppState};

use axum::{Router, routing::get};
pub fn route_register() -> Router<AppState> {
    Router::<AppState>::new().route("/hello", get(user_controller::hello))
}
