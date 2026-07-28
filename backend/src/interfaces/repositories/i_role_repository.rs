use sea_orm::DbErr;

pub trait IRoleRepository {
    async fn get_permissions_by_role(&self, id_role: i64) -> Result<Vec<String>, DbErr>;
}
