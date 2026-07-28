use crate::dtos::user_dtos;
pub trait IUserService {
    // Registrar usuario
    async fn register(
        &self,
        dto: user_dtos::UserRegisterDto,
    ) -> Result<user_dtos::UserResponseDto, String>;

    // Login
    async fn login(
        &self,
        dto: user_dtos::UserLoginDto,
    ) -> Result<user_dtos::LoginResponseDto, String>;

    // Obtener usuario por ID
    async fn get_user(&self, id_user: i64) -> Result<user_dtos::UserResponseDto, String>;

    // Actualizar perfil
    async fn update_user(
        &self,
        id_user: i64,
        name: String,
        email: String,
    ) -> Result<user_dtos::UserResponseDto, String>;

    // Cambiar rol (solo ADMIN)
    async fn change_role(&self, id_user: i64, id_role: i64) -> Result<user_dtos::UserResponseDto, String>;

    // Eliminar usuario
    async fn delete_user(&self, id_user: i64) -> Result<(), String>;
}
