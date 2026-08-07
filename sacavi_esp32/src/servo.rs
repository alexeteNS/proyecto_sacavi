use esp_hal::ledc::{
    channel::{Channel, ChannelHW},
    LowSpeed,
};

pub struct ServoMotor<'a> {
    channel: Channel<'a, LowSpeed>,
}

impl<'a> ServoMotor<'a> {
    pub fn new(channel: Channel<'a, LowSpeed>) -> Self {
        Self { channel }
    }

    pub fn set_angle(&mut self, angle: u32) {
        // Aseguramos que el ángulo esté entre 0 y 180
        let clamped_angle = angle.clamp(0, 180);
        
        // Mapeo: 0 grados -> 102 (~0.5ms), 180 grados -> 512 (~2.5ms)
        let duty = 102 + (clamped_angle * (512 - 102) / 180);
        self.channel.set_duty_hw(duty);
    }
}
