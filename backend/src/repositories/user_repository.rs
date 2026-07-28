use crate::entities::user;
use crate::interfaces::repositories::i_user_repository::IUserRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct UserRepository {
    pub db: DatabaseConnection,
}

impl UserRepository {
    pub async fn get_all(&self) -> Result<Vec<user::Model>, DbErr> {
        user::Entity::find().all(&self.db).await
    }
}

impl IUserRepository for UserRepository {
    async fn register(
        &self,
        user_register_dto: crate::dtos::user_dtos::UserRegisterDto,
    ) -> Result<user::Model, DbErr> {
        let user = user::ActiveModel {
            name: Set(user_register_dto.name),
            email: Set(user_register_dto.email),
            hash_password: Set(user_register_dto.password),
            id_role: Set(user_register_dto.id_role.unwrap_or(3)),
            ..Default::default()
        };

        user.insert(&self.db).await
    }

    async fn find_by_email(&self, email: String) -> Result<Option<user::Model>, DbErr> {
        user::Entity::find()
            .filter(user::Column::Email.eq(email))
            .one(&self.db)
            .await
    }

    async fn find_by_id(&self, id_user: i64) -> Result<Option<user::Model>, DbErr> {
        user::Entity::find_by_id(id_user).one(&self.db).await
    }

    async fn find_all(&self) -> Result<Vec<user::Model>, DbErr> {
        user::Entity::find().all(&self.db).await
    }

    async fn update(
        &self,
        id_user: i64,
        name: String,
        email: String,
    ) -> Result<user::Model, DbErr> {
        let user: Option<user::Model> = user::Entity::find_by_id(id_user).one(&self.db).await?;

        let mut user: user::ActiveModel = user
            .ok_or(DbErr::RecordNotFound("User not found".to_string()))?
            .into();

        user.name = Set(name);
        user.email = Set(email);

        user.update(&self.db).await
    }

    async fn update_role(&self, id_user: i64, id_role: i64) -> Result<user::Model, DbErr> {
        let user: Option<user::Model> = user::Entity::find_by_id(id_user).one(&self.db).await?;
        let mut user: user::ActiveModel = user
            .ok_or(DbErr::RecordNotFound("User not found".to_string()))?
            .into();
        user.id_role = Set(id_role);
        user.update(&self.db).await
    }

    async fn delete(&self, id_user: i64) -> Result<(), DbErr> {
        user::Entity::delete_by_id(id_user).exec(&self.db).await?;
        Ok(())
    }
}
