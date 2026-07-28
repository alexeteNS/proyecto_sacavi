#[derive(serde::Serialize, serde::Deserialize)]
pub struct UserRegisterDto {
    pub name: String,
    pub email: String,
    pub password: String,
    #[serde(skip)]
    pub id_role: Option<i64>,
}
#[derive(serde::Serialize, serde::Deserialize)]
pub struct UserLoginDto {
    pub email: String,
    pub password: String,
}
#[derive(serde::Serialize, serde::Deserialize)]
pub struct UserResponseDto {
    pub id_user: i64,
    pub name: String,
    pub email: String,
    pub role: String,
    pub permissions: Vec<String>,
}
#[derive(serde::Serialize, serde::Deserialize)]
pub struct UserUpdateDto {
    pub name: String,
    pub email: String,
}
#[derive(serde::Serialize, serde::Deserialize)]
pub struct ChangePasswordDto {
    pub old_password: String,
    pub new_password: String,
}
#[derive(serde::Serialize, serde::Deserialize)]
pub struct AssignRoleDto {
    pub user_id: i64,
    pub role_id: i64,
}

#[derive(serde::Serialize, serde::Deserialize)]
pub struct LoginResponseDto {
    pub token: String,
    pub user: UserResponseDto,
}
