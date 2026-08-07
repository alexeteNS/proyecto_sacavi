use crate::dtos::admin_dtos::{AdminCreateUserDto, AdminUpdateUserDto, AdminUserResponseDto};
use crate::dtos::user_dtos;

pub trait IUserService {
    // Registrar usuario (público - mantener para seed)
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

    // Actualizar perfil (NO disponible para usuarios normales en el frontend)
    async fn update_user(
        &self,
        id_user: i64,
        name: String,
        email: String,
    ) -> Result<user_dtos::UserResponseDto, String>;

    // Cambiar rol (solo ADMIN)
    async fn change_role(
        &self,
        id_user: i64,
        id_role: i64,
    ) -> Result<user_dtos::UserResponseDto, String>;

    // Eliminar usuario
    async fn delete_user(&self, id_user: i64) -> Result<(), String>;

    // ─── Admin CRUD ───────────────────────────────────────────────────────────

    /// Crea un usuario con rol específico (solo ADMIN)
    async fn create_user(&self, dto: AdminCreateUserDto) -> Result<AdminUserResponseDto, String>;

    /// Actualiza nombre, email y rol de cualquier usuario (solo ADMIN)
    async fn update_user_admin(
        &self,
        id_user: i64,
        dto: AdminUpdateUserDto,
    ) -> Result<AdminUserResponseDto, String>;

    /// Obtiene todos los usuarios con vehicle_count calculado
    async fn get_all_users_admin(&self) -> Result<Vec<AdminUserResponseDto>, String>;

    /// Obtiene un usuario con vehicle_count calculado
    async fn get_user_admin(&self, id_user: i64) -> Result<AdminUserResponseDto, String>;

    /// Restablece la contraseña de un usuario (solo ADMIN)
    async fn reset_password_admin(
        &self,
        id_user: i64,
        dto: crate::dtos::admin_dtos::AdminResetPasswordDto,
    ) -> Result<(), String>;
}
