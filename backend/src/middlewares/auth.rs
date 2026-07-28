use crate::utils::jwt;
use axum::{
    extract::Request,
    http::StatusCode,
    middleware::Next,
    response::{IntoResponse, Response},
};

pub async fn auth_middleware(mut req: Request, next: Next) -> Response {
    let auth_header = req
        .headers()
        .get("Authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "));

    match auth_header {
        Some(token) => match jwt::verify_token(token) {
            Ok(claims) => {
                req.extensions_mut().insert(claims);
                next.run(req).await
            }
            Err(_) => (StatusCode::UNAUTHORIZED, "Invalid token").into_response(),
        },
        None => (StatusCode::UNAUTHORIZED, "Missing token").into_response(),
    }
}
