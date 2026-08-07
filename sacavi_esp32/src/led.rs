use esp_hal::gpio::Output;

pub struct BoardLed<'d> {
    pin: Output<'d>,
}

impl<'d> BoardLed<'d> {
    pub fn new(pin: Output<'d>) -> Self {
        Self { pin }
    }

    pub fn turn_on(&mut self) {
        self.pin.set_high();
    }

    pub fn turn_off(&mut self) {
        self.pin.set_low();
    }
}
