use crate::entities::qr_token;
use crate::interfaces::repositories::i_qr_repository::IQrRepository;
use sea_orm::*;

#[derive(Clone)]
pub struct QrRepository {
    pub db: DatabaseConnection,
}

impl IQrRepository for QrRepository {
    async fn create_token(&self, id_user: i64, id_vehicle: Option<i64>, token: String, expires_at: chrono::NaiveDateTime) -> Result<qr_token::Model, DbErr> {
        let qr = qr_token::ActiveModel {
            id_user: Set(id_user),
            id_vehicle: Set(id_vehicle),
            token: Set(token),
            expires_at: Set(expires_at),
            used: Set(false),
            ..Default::default()
        };
        qr.insert(&self.db).await
    }

    async fn find_by_token(&self, token: String) -> Result<Option<qr_token::Model>, DbErr> {
        qr_token::Entity::find()
            .filter(qr_token::Column::Token.eq(token))
            .one(&self.db)
            .await
    }

    async fn mark_used(&self, id: i64) -> Result<(), DbErr> {
        let qr: Option<qr_token::Model> = qr_token::Entity::find_by_id(id).one(&self.db).await?;
        let mut qr: qr_token::ActiveModel = qr.ok_or(DbErr::RecordNotFound("QR not found".to_string()))?.into();
        qr.used = Set(true);
        qr.update(&self.db).await?;
        Ok(())
    }

    async fn delete_expired(&self) -> Result<(), DbErr> {
        qr_token::Entity::delete_many()
            .filter(qr_token::Column::ExpiresAt.lt(chrono::Utc::now().naive_utc()))
            .exec(&self.db)
            .await?;
        Ok(())
    }
}
