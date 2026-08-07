use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct LogResponseDto {
    pub id_log: i64,
    pub id_user: Option<i64>,
    pub action: String,
    pub device: Option<String>,
    pub result: String,
    pub created_at: String,
}

/// Query params para filtrar logs.
#[derive(Deserialize, Default)]
pub struct LogFilterParams {
    pub limit: Option<u64>,
    pub user_id: Option<i64>,
    pub action: Option<String>,
    pub from: Option<String>,
    pub to: Option<String>,
}
