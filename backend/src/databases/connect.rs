use sea_orm::{Database, DatabaseConnection, DbErr};

pub async fn connect() -> Result<DatabaseConnection, DbErr> {
    let url = std::env::var("DATABASE_URL").expect("DATABASE_URL no configurada");
    println!("Base de datos conectada");
    Database::connect(url).await
}
