use crate::dtos::user_dtos;
use crate::entities::user::Model;
use sea_orm::DbErr;

pub trait IUserRepository {
    // Crear usuario
    async fn register(&self, user_register_dto: user_dtos::UserRegisterDto)
    -> Result<Model, DbErr>;

    // Buscar usuario por correo
    async fn find_by_email(&self, email: String) -> Result<Option<Model>, DbErr>;

    // Buscar usuario por ID
    async fn find_by_id(&self, id_user: i64) -> Result<Option<Model>, DbErr>;

    // Obtener todos los usuarios
    async fn find_all(&self) -> Result<Vec<Model>, DbErr>;

    // Actualizar usuario
    async fn update(&self, id_user: i64, name: String, email: String) -> Result<Model, DbErr>;

    // Actualizar rol
    async fn update_role(&self, id_user: i64, id_role: i64) -> Result<Model, DbErr>;

    // Eliminar usuario
    async fn delete(&self, id_user: i64) -> Result<(), DbErr>;

    async fn update_password(&self, id_user: i64, new_hash: String) -> Result<(), DbErr>;
}
