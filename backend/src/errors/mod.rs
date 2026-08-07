use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct ApiError {
    pub success: bool,
    pub message: String,
}

impl ApiError {
    #[allow(dead_code)]
    pub fn new(message: impl Into<String>) -> Self {
        Self {
            success: false,
            message: message.into(),
        }
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (StatusCode::BAD_REQUEST, axum::Json(self)).into_response()
    }
}

impl<E: ToString> From<E> for ApiError {
    fn from(err: E) -> Self {
        ApiError::new(err.to_string())
    }
}
