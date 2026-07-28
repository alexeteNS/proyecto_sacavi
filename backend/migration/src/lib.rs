pub use sea_orm_migration::prelude::*;

mod m20260727_020727_create_roles;
mod m20260727_020839_create_permissions;
mod m20260727_020844_create_users;
mod m20260727_020855_create_role_permissions;
mod m20260727_020900_seed_data;
mod m20260727_020910_create_vehicles;
mod m20260727_020920_create_access_records;
mod m20260727_020930_create_vehicle_requests;
mod m20260727_020940_add_created_at_to_users;
mod m20260727_020950_create_qr_tokens;
mod m20260727_020960_create_devices;
mod m20260727_020970_add_device_id_to_access_records;
mod m20260727_020980_create_system_logs;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(m20260727_020727_create_roles::Migration),
            Box::new(m20260727_020839_create_permissions::Migration),
            Box::new(m20260727_020844_create_users::Migration),
            Box::new(m20260727_020855_create_role_permissions::Migration),
            Box::new(m20260727_020900_seed_data::Migration),
            Box::new(m20260727_020910_create_vehicles::Migration),
            Box::new(m20260727_020920_create_access_records::Migration),
            Box::new(m20260727_020930_create_vehicle_requests::Migration),
            Box::new(m20260727_020940_add_created_at_to_users::Migration),
            Box::new(m20260727_020950_create_qr_tokens::Migration),
            Box::new(m20260727_020960_create_devices::Migration),
            Box::new(m20260727_020970_add_device_id_to_access_records::Migration),
            Box::new(m20260727_020980_create_system_logs::Migration),
        ]
    }
}
