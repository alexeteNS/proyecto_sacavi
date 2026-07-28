mod controllers;
mod databases;
mod dtos;
mod entities;
mod errors;
mod helpers;
mod interfaces;
mod middlewares;
mod repositories;
mod routes;
mod services;
mod state;
mod utils;

use axum::Router;
use sea_orm_migration::MigratorTrait;
use tower_http::cors::{Any, CorsLayer};

use crate::{
    repositories::{
        access_repository, device_repository, log_repository, qr_repository, role_repository,
        user_repository, vehicle_repository,
    },
    services::{access_service, device_service, qr_service, user_service, vehicle_service},
    state::AppState,
};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenvy::dotenv().ok();
    let body = reqwest::get("http://localhost:4040/api/tunnels")
        .await?
        .text()
        .await?;
    let body_des: serde_json::Value = serde_json::from_str(&body)?;
    let url = body_des["tunnels"][0]["public_url"].to_string();
    let db = databases::connect::connect().await.unwrap();

    migration::Migrator::up(&db, None).await.unwrap();

    seed_admin_user(&db).await;

    let user_repository = user_repository::UserRepository { db: db.clone() };
    let vehicle_repository = vehicle_repository::VehicleRepository { db: db.clone() };
    let qr_repository = qr_repository::QrRepository { db: db.clone() };
    let access_repository = access_repository::AccessRepository { db: db.clone() };
    let role_repository = role_repository::RoleRepository { db: db.clone() };
    let device_repository = device_repository::DeviceRepository { db: db.clone() };
    let log_repository = log_repository::LogRepository { db };

    let user_service = user_service::UserService {
        user_repository,
        log_repository: log_repository.clone(),
    };
    let qr_service = qr_service::QrService { qr_repository };
    let vehicle_service = vehicle_service::VehicleService {
        vehicle_repository: vehicle_repository.clone(),
    };
    let device_service = device_service::DeviceService { device_repository };
    let access_service = access_service::AccessService {
        access_repository,
        vehicle_repository,
        qr_service: qr_service.clone(),
        device_service: device_service.clone(),
        log_repository: log_repository.clone(),
    };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let state_app = AppState {
        user_service,
        vehicle_service,
        qr_service,
        access_service,
        device_service,
        role_repository,
        log_repository,
    };

    let app = Router::<AppState>::new()
        .nest("/user", routes::user_routes::route_user())
        .nest("/registro", routes::register_routes::route_register())
        .nest("/vehicle", routes::vehicle_routes::route_vehicle())
        .nest("/qr", routes::qr_routes::route_qr())
        .nest("/access", routes::access_routes::route_access())
        .nest("/roles", routes::role_routes::route_role())
        .nest("/device", routes::device_routes::route_device())
        .layer(cors)
        .with_state(state_app);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();

    println!("Servidor escuchando en: {}", &url);

    axum::serve(listener, app).await.unwrap();
    Ok(())
}

async fn seed_admin_user(db: &sea_orm::DatabaseConnection) {
    use sea_orm::{ActiveModelTrait, ColumnTrait, EntityTrait, QueryFilter};

    let existing = crate::entities::user::Entity::find()
        .filter(crate::entities::user::Column::Email.eq("admin@sacavi.edu"))
        .one(db)
        .await
        .unwrap();

    if existing.is_none() {
        let admin_role = crate::entities::role::Entity::find()
            .filter(crate::entities::role::Column::NameRole.eq("ADMIN"))
            .one(db)
            .await
            .unwrap()
            .expect("ADMIN role must exist in seed data");
        let hash = crate::helpers::bycrpt::hash_password("admin123".to_string());
        let _ = crate::entities::user::ActiveModel {
            name: sea_orm::Set("Admin".to_string()),
            email: sea_orm::Set("admin@sacavi.edu".to_string()),
            hash_password: sea_orm::Set(hash),
            id_role: sea_orm::Set(admin_role.id_role),
            ..Default::default()
        }
        .insert(db)
        .await
        .unwrap();
        println!("Admin user seeded: admin@sacavi.edu / admin123");
    }
}
