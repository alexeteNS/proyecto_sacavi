#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_bootloader_esp_idf::esp_app_desc;
use esp_hal::{
    delay::Delay,
    gpio::{Level, Output, OutputConfig},
    interrupt::software::SoftwareInterruptControl,
    ledc::{
        LSGlobalClkSource, Ledc, LowSpeed,
        channel::{ChannelIFace, Number as ChanNum, config::Config as ChanCfg},
        timer::{Number as TimNum, TimerIFace, config::Config as TimCfg},
    },
    timer::timg::TimerGroup,
};

mod led;
mod servo;
mod wifi;
use led::BoardLed;
use servo::ServoMotor;

esp_app_desc!();

#[esp_rtos::main]
async fn main(_spawner: embassy_executor::Spawner) -> ! {
    esp_alloc::heap_allocator!(size: 100 * 1024);
    esp_println::logger::init_logger_from_env();

    let peripherals = esp_hal::init(esp_hal::Config::default());
    let _delay = Delay::new();

    let timg0 = TimerGroup::new(peripherals.TIMG0);
    let sw_interrupt = SoftwareInterruptControl::new(peripherals.SW_INTERRUPT);
    esp_rtos::start(timg0.timer0, sw_interrupt.software_interrupt0);

    // Configurar tu LED en el GPIO 3 tal como lo tenías
    let led_pin_amarillo = Output::new(peripherals.GPIO3, Level::Low, OutputConfig::default());
    let mut led_amarillo = BoardLed::new(led_pin_amarillo);
    let led_pin_rojo = Output::new(peripherals.GPIO2, Level::High, OutputConfig::default());
    let mut led_rojo = BoardLed::new(led_pin_rojo);
    let led_pin_verde = Output::new(peripherals.GPIO1, Level::Low, OutputConfig::default());
    let mut led_verde = BoardLed::new(led_pin_verde);

    // Inicializar el periférico LEDC
    let mut ledc = Ledc::new(peripherals.LEDC);
    ledc.set_global_slow_clock(LSGlobalClkSource::APBClk);

    // Conectar a Wifi
    let (_wifi_controller, interfaces) = wifi::connect_wifi(peripherals.WIFI).await;

    // Configurar red con embassy-net
    let rng = esp_hal::rng::Rng::new();
    let seed = (rng.random() as u64) | ((rng.random() as u64) << 32);

    let config = embassy_net::Config::dhcpv4(Default::default());
    static STACK_RESOURCES: static_cell::StaticCell<embassy_net::StackResources<3>> =
        static_cell::StaticCell::new();
    let static_resources = STACK_RESOURCES.init(embassy_net::StackResources::new());
    let (stack, runner) = embassy_net::new(interfaces.station, config, static_resources, seed);

    // Iniciar tarea del stack
    _spawner.spawn(net_task(runner).unwrap());

    log::info!("Esperando a que la interfaz de red suba...");
    stack.wait_config_up().await;
    log::info!("¡Interfaz arriba!");

    const WS_PORT: u16 = 3000;
    // Configurar el temporizador PWM
    let mut timer = ledc.timer::<LowSpeed>(TimNum::Timer0);
    timer
        .configure(TimCfg {
            duty: esp_hal::ledc::timer::config::Duty::Duty12Bit,
            clock_source: esp_hal::ledc::timer::LSClockSource::APBClk,
            frequency: esp_hal::time::Rate::from_hz(50),
        })
        .unwrap();

    let mut servo_channel = ledc.channel(ChanNum::Channel0, peripherals.GPIO4);
    servo_channel
        .configure(ChanCfg {
            timer: &timer,
            duty_pct: 0,
            drive_mode: esp_hal::gpio::DriveMode::PushPull,
        })
        .unwrap();
    let mut servo = ServoMotor::new(servo_channel);

    use embedded_websocket::{
        WebSocketClient, WebSocketOptions, WebSocketReceiveMessageType, WebSocketSendMessageType,
    };

    let mut rx_buffer = [0; 4096];
    let mut tx_buffer = [0; 4096];
    let mut ws_read_buf = [0; 1024];
    let mut ws_write_buf = [0; 1024];
    let mut frame_buf = [0; 1024];

    loop {
        let remote_ip = embassy_net::IpAddress::Ipv4(embassy_net::Ipv4Address::new(172, 20, 10, 7));

        let mut socket = embassy_net::tcp::TcpSocket::new(stack, &mut rx_buffer, &mut tx_buffer);
        let remote_endpoint = embassy_net::IpEndpoint::new(remote_ip, WS_PORT);
        log::info!("Conectando TCP a {}:{}", remote_ip, WS_PORT);

        if let Err(e) = socket.connect(remote_endpoint).await {
            log::warn!("Error conectando TCP: {:?}", e);
            socket.close();
            embassy_time::Timer::after(embassy_time::Duration::from_secs(3)).await;
            continue;
        }
        log::info!("TCP conectado");

        let mut ws = WebSocketClient::new_client(esp_hal::rng::Rng::new());
        let ws_options = WebSocketOptions {
            path: "/ws?device_id=1&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsInJvbGUiOiJERVZJQ0UiLCJleHAiOjE4MTcxODQ5NTd9.03zbwmvsXh6kagB5eXIHgsTR6SiwL9SDB-sN_-gWIXI",
            host: "172.20.10.7:3000",
            origin: "http://172.20.10.7:3000",
            sub_protocols: None,
            additional_headers: None,
        };

        let (len, web_socket_key) = match ws.client_connect(&ws_options, &mut ws_write_buf) {
            Ok(res) => res,
            Err(e) => {
                log::warn!("Error generando handshake: {:?}", e);
                socket.close();
                embassy_time::Timer::after(embassy_time::Duration::from_secs(3)).await;
                continue;
            }
        };

        let mut written = 0;
        let mut write_err = false;
        while written < len {
            match socket.write(&ws_write_buf[written..len]).await {
                Ok(n) => written += n,
                Err(e) => {
                    log::warn!("Error escribiendo handshake TCP: {:?}", e);
                    write_err = true;
                    break;
                }
            }
        }
        if write_err {
            socket.close();
            embassy_time::Timer::after(embassy_time::Duration::from_secs(3)).await;
            continue;
        }

        let mut read_cursor = 0;
        let mut handshake_ok = false;
        loop {
            match socket.read(&mut ws_read_buf[read_cursor..]).await {
                Ok(0) => {
                    log::warn!("Conexión TCP cerrada por el servidor durante el handshake");
                    break;
                }
                Ok(n) => {
                    read_cursor += n;
                    match ws.client_accept(&web_socket_key, &ws_read_buf[..read_cursor]) {
                        Ok((header_len, _)) => {
                            log::info!("WS Handshake exitoso");
                            let pending = read_cursor - header_len;
                            ws_read_buf.copy_within(header_len..read_cursor, 0);
                            read_cursor = pending;
                            handshake_ok = true;
                            break;
                        }
                        Err(embedded_websocket::Error::HttpHeaderIncomplete) => continue,
                        Err(e) => {
                            log::warn!("Error en WS handshake: {:?}", e);
                            break;
                        }
                    }
                }
                Err(e) => {
                    log::warn!("Error de lectura TCP durante handshake: {:?}", e);
                    break;
                }
            }
        }

        if !handshake_ok {
            socket.close();
            embassy_time::Timer::after(embassy_time::Duration::from_secs(3)).await;
            continue;
        }

        let mut frame_cursor = 0;
        log::info!("Esperando comandos WebSocket...");
        // Ya está conectado a internet
        led_amarillo.turn_on();
        loop {
            let mut consumed = 0;

            if read_cursor > 0 {
                match ws.read(&ws_read_buf[..read_cursor], &mut frame_buf[frame_cursor..]) {
                    Ok(ws_result) => {
                        consumed = ws_result.len_from;
                        frame_cursor += ws_result.len_to;

                        if ws_result.end_of_message {
                            match ws_result.message_type {
                                WebSocketReceiveMessageType::Text => {
                                    let text = core::str::from_utf8(&frame_buf[..frame_cursor])
                                        .unwrap_or("");
                                    log::info!("Comando recibido: {}", text);
                                    if text.contains("\"gate_open\"") {
                                        servo.set_angle(90);
                                        log::info!("Abriendo pluma...");
                                        led_verde.turn_on();
                                        led_rojo.turn_off();
                                    } else if text.contains("\"gate_close\"") {
                                        servo.set_angle(0);
                                        log::info!("Cerrando pluma...");
                                        led_verde.turn_off();
                                        led_rojo.turn_on();
                                    }
                                    frame_cursor = 0;
                                }
                                WebSocketReceiveMessageType::Ping => {
                                    if let Ok(len) = ws.write(
                                        WebSocketSendMessageType::Pong,
                                        true,
                                        &frame_buf[..frame_cursor],
                                        &mut ws_write_buf,
                                    ) {
                                        let mut w = 0;
                                        while w < len {
                                            if let Ok(n) = socket.write(&ws_write_buf[w..len]).await
                                            {
                                                w += n;
                                            } else {
                                                break;
                                            }
                                        }
                                    }
                                    frame_cursor = 0;
                                }
                                WebSocketReceiveMessageType::CloseMustReply => {
                                    log::info!("Servidor cerró la conexión");
                                    break;
                                }
                                _ => {
                                    frame_cursor = 0;
                                }
                            }
                        }
                    }
                    Err(e) => {
                        log::warn!("WS Read Error: {:?}", e);
                        break;
                    }
                }
            }

            let remaining = read_cursor - consumed;
            ws_read_buf.copy_within(consumed..read_cursor, 0);
            read_cursor = remaining;

            if consumed == 0 {
                match socket.read(&mut ws_read_buf[read_cursor..]).await {
                    Ok(0) => {
                        log::warn!("Conexión TCP cerrada por el servidor");
                        break;
                    }
                    Ok(n) => {
                        read_cursor += n;
                    }
                    Err(e) => {
                        log::warn!("Error de lectura TCP: {:?}", e);
                        break;
                    }
                }
            }
        }

        socket.close();
        embassy_time::Timer::after(embassy_time::Duration::from_secs(3)).await;
    }
}

#[embassy_executor::task]
async fn net_task(mut runner: embassy_net::Runner<'static, esp_radio::wifi::Interface<'static>>) {
    runner.run().await
}
