#include <avr/io.h>
#include <util/delay.h>

#define BYTE_LENGTH (8)
#define LED_PIN (PB5)
#define SERIAL_OUTPUT_PIN (LED_PIN)
#define CLK_PIN (PB4)

const char MESSAGE[] = {
  0b00000000,
  0b10101010,
  0b11111111,
  0b00110011,
};

int main(void) {
  DDRB = _BV(SERIAL_OUTPUT_PIN)
    | _BV(CLK_PIN);

  for (int i = 0; ; i = (i + 1) % sizeof(MESSAGE)) {
    char valueByte = MESSAGE[i];

    for (char j = BYTE_LENGTH - 1; j >= 0; --j) {
      char valueBit = (valueByte >> j) & 1;
      // Set serial output to `0`
      PORTB &= ~(_BV(SERIAL_OUTPUT_PIN));
      // Send current bit value to serial output
      PORTB |= valueBit << SERIAL_OUTPUT_PIN;
      // Make a rising edge of clock signal
      PORTB |= _BV(CLK_PIN);
      // Make a falling edge of clock signal
      PORTB &= ~(_BV(CLK_PIN));
      _delay_ms(250);
    }
  }
}
