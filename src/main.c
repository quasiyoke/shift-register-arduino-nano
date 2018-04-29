#include <avr/io.h>
#include <util/delay.h>

#define LED_PIN PB5

int main(void) {
  DDRB = _BV(LED_PIN);

  for (;;) {
    PORTB |= _BV(LED_PIN);
    _delay_ms(50);
    PORTB &= ~(_BV(LED_PIN));
    _delay_ms(950);
  }
}
