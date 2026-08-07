use crate::dtos::admin_dtos::DashboardDto;

pub trait IDashboardService {
    /// Ejecuta todas las queries en paralelo con tokio::join!
    async fn get_dashboard(&self) -> Result<DashboardDto, String>;
}
