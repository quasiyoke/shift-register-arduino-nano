#include <avr/io.h>
#include <util/delay.h>

#define BYTE_LENGTH (8)
#define LED_PIN (PB5)
#define SERIAL_OUTPUT_PIN (LED_PIN)
#define SHIFT_REGISTER_CLK_PIN (PB4)
#define REGISTER_CLK_PIN (PB3)

const char MESSAGE[] = {
  0b00000000,
  0b10101010,
  0b11111111,
  0b00110011,
};

int main(void) {
  DDRB = _BV(SERIAL_OUTPUT_PIN)
    | _BV(SHIFT_REGISTER_CLK_PIN)
    | _BV(REGISTER_CLK_PIN);

  for (int i = 0; ; i = (i + 1) % sizeof(MESSAGE)) {
    char valueByte = MESSAGE[i];
    // Make a falling edge of storage register clock signal
    PORTB &= ~(_BV(REGISTER_CLK_PIN));

    for (char j = BYTE_LENGTH - 1; j >= 0; --j) {
      char valueBit = (valueByte >> j) & 1;
      /*
       * Send current bit value to serial output and
       * make rising edge of shift register clock signal
       * with only one I/O operation
       */
      PORTB = valueBit << SERIAL_OUTPUT_PIN
        | _BV(SHIFT_REGISTER_CLK_PIN);
      // Make a falling edge of shift register clock signal
      PORTB &= ~(_BV(SHIFT_REGISTER_CLK_PIN));
    }

    // Make a rising edge of storage register clock signal
    PORTB |= _BV(REGISTER_CLK_PIN);
    _delay_ms(250);
  }
}
