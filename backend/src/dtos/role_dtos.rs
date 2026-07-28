use serde::Serialize;

#[derive(Serialize)]
pub struct RolePermissionsResponse {
    pub role: String,
    pub permissions: Vec<String>,
}

#[derive(serde::Deserialize)]
pub struct ChangeRoleDto {
    pub id_role: i64,
}
