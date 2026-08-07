use esp_hal::peripherals::WIFI;
use esp_radio::wifi::{
    AuthenticationMethod, Config, ControllerConfig, Interfaces, WifiController, sta::StationConfig,
};

const WIFI_SSID: &str = "iPhone";
const WIFI_PASS: &str = "98765432";

pub async fn connect_wifi<'a>(wifi_peripheral: WIFI<'a>) -> (WifiController<'a>, Interfaces<'a>) {
    let station_config = Config::Station(
        StationConfig::default()
            .with_ssid(WIFI_SSID)
            .with_password(WIFI_PASS.into())
            .with_auth_method(AuthenticationMethod::Wpa2Personal),
    );
    log::info!("Iniciando wifi...");
    let (mut controller, interfaces) = esp_radio::wifi::new(
        wifi_peripheral,
        ControllerConfig::default().with_initial_config(station_config),
    )
    .unwrap();

    match controller.set_max_tx_power(30) {
        Ok(()) => log::info!("Potencia TX ajustada a 7.5 dBm"),
        Err(e) => log::warn!("No se pudo ajustar la potencia TX: {:?}", e),
    }

    let delay = esp_hal::delay::Delay::new();
    loop {
        log::info!("Esperando conexión...");
        match controller.connect_async().await {
            Ok(info) => {
                log::info!("¡Conectado a {:?}!", info);
                break;
            }
            Err(e) => log::error!("Fallo de conexión: {:?}. Reintentando...", e),
        }
        delay.delay_millis(2000);
    }

    (controller, interfaces)
}
