// Controls a FC motor via a L293D Hbridge and a potentiometer input.
//
// Hardwre:
//   Potentiometer (POT)
//   ATtiny85
//   L293D + DC motor 
// 
// Pin hookups:
//
//  N/C -+------+- VCC (5V)
//  N/C -|Tiny85|- REV
// ADC2 -|      |- FWD
//  GND -+------+- OC0A
//
//     ADC2
//       |
// VCC /\/\/ GND
//
// OC0A -+-----+- VCC (5V)
//  FWD -|L293D|- GND (Input)
// MOT1 -|     |- N/C (Output)
//  GND -|     |- GND
//  GND -|     |- GND
// MOT2 -|     |- N/C (Output)
//  REV -|     |- GND (Input)
//  12V -+-----+- GND (Enable 2)
//
// OC0A - PWM output
// FWD, REV: Motor enable and direction
// ADC2 - ADC Input

// How fast to loop
#define LOOP_DELAY_MS 50
// Deadband around the center
#define DEADBAND 12
// Minimum and maximum PWM output values (0-255)
#define MINIMUM_PWM 70
#define MAXIMUM_PWM 255
// Velocity says how it takes to go from zero to pull power (and visa versa).
// It's used to slow down the change rate.  This makes the system run more
// smoothly and is easier on the components.
#define RAIL_VELOCITY_MS 256

#include <adc/adc.h>
#include <util/delay.h>
#include <avr/io.h>

#define OC0A_PIN 0
#define FWD_PIN 1
#define REV_PIN 2
#define ADC_PIN 2  // ADC2, not comparable with other _PIN values

// We calculate the rail velocity period
// pwm_range = MAXIMUM_PWM - MINIMUM_PWM
// number_of_steps = RAIL_VELOCITY_MS / LOOP_DELAY_MS
//
// period = pwm_range / number_of_steps
//        = (MAXIMUM_PWM - MINIMUM_PWM) * LOOP_DELAY_MS / RAIL_VELOCITY_MS
//
// Example with: MINIMUM_PWM = 100, MAXIMUM_PWM = 200, LOOP_DELAY_MS = 50, RAIL_VELOCITY_MS = 500
//        = 100 * 50 / 500
//        = 5000 / 500
//        = 10 steps per period
//   at 10 steps per period, it will take 10 periods to cover 100.  10 periods happen in 500 ms.
//
// Same example with RAIL_VELOCITY_MS = 1000
//        = 100 * 50 / 1000
//        = 5000 / 1000
//        = 5 steps per period
#define RAIL_VELOCITY_PERIOD ((MAXIMUM_PWM - MINIMUM_PWM) * LOOP_DELAY_MS / RAIL_VELOCITY_MS)

static inline void disable_pwm() {
  // Turn off CS00, CS01, CS02.  Other bits can also be zero.
  TCCR0B = 0x00;
}

static inline void enable_pwm() {
  TCCR0B = 0x01; // Turns on clock with no prescaler
}

static inline void set_pwm_period(uint8_t period) {
  OCR0A = period;
}

static inline uint8_t pwm_period() {
  return OCR0A;
}

static inline uint8_t read_adc() {
  return adc_read8(ADC_PIN, ADC_REF_VCC, ADC_PRESCALER_128);
}

static void init() {
  // Set Inputs and Outputs
  DDRB = (1 << REV_PIN) | (1 << FWD_PIN) | (1 << OC0A_PIN);
  disable_pwm();

  // COM0A1 | COM0A0 == 0x80 => Clear on match, set on bottom
  // WGM00 | WGM01 == 0x03 => Fast PWM Mode
  TCCR0A = 0x83;
}

static inline uint8_t motor_is_running_forward() {
  return (PORTB & (1 << FWD_PIN)) != 0;
}

static inline uint8_t motor_is_running() {
  return (PORTB & ((1 << FWD_PIN) | (1 << REV_PIN))) != 0;
}

static void slow_down_or_stop_motor() {
  if (!motor_is_running()) {
    return;
  }

  const uint8_t current_pwm = pwm_period();
  if (current_pwm <= RAIL_VELOCITY_PERIOD) {
    // stop the motor
    PORTB &= ~((1 << FWD_PIN) | (1 << REV_PIN));
    disable_pwm();
    return;
  }

  // else, slow down the motor
  set_pwm_period(current_pwm - RAIL_VELOCITY_PERIOD);
}

static void start_motor(uint8_t is_forward_direction) {
  set_pwm_period(RAIL_VELOCITY_PERIOD);
  enable_pwm();
  if (is_forward_direction) {
    PORTB |= 1 << FWD_PIN;
  } else {
    PORTB |= 1 << REV_PIN;
  }
}

static void speed_up_motor(uint8_t target_pwm) {
  uint16_t new_pwm = (uint16_t)pwm_period() + RAIL_VELOCITY_PERIOD;
  if (new_pwm > (uint16_t)target_pwm) {
    // overshot the mark
    new_pwm = target_pwm;
  }
  set_pwm_period((uint8_t)new_pwm);
}

static void maybe_update_motor(uint8_t is_forward_direction, uint8_t target_pwm) {
  const uint8_t current_pwm = pwm_period();
  if (motor_is_running() &&
      (current_pwm > target_pwm || motor_is_running_forward() != is_forward_direction)) {
    slow_down_or_stop_motor();
    return;
  }

  if (target_pwm > 0 && !motor_is_running()) {
    start_motor(is_forward_direction);
    return;
  }

  if (current_pwm < target_pwm) {
    speed_up_motor(target_pwm);
  }

  // else current_pwn == target_pwm and the direction is correct so do nothing.
}

static void loop() {
  const uint8_t raw_adc_value = 255 - read_adc(); // reversed

  // determine forward or reverse
  const uint8_t is_forward_direction = (raw_adc_value >= 128);

  const uint8_t raw_magnitude = is_forward_direction ?
    raw_adc_value - 128 :  // forward
    128 - raw_adc_value;   // reverse

  uint8_t target_pwm = 0;
  if (raw_magnitude > DEADBAND) {
    const uint16_t magnitude = raw_magnitude - DEADBAND;

    // Convert magnitude to a target_pwm.
    // Some examples (DEADBAND=10, MINIMUM_PWM=100, MAXIMUM_PWM=200)
    // Lowest value:
    //   0 * 100 / 245 + 100 => 100
    // Highest Value:
    //   245 * 100 / 245 + 100 => 200
    // Halfway between:
    //   123 * 100 / 245 + 100 => 150 
    target_pwm = (uint8_t)(
        magnitude * (MAXIMUM_PWM - MINIMUM_PWM) /
        (128 - DEADBAND) + MINIMUM_PWM);
  }
  // else we are in the DEADBAND we we target zero (stop the motor)

  maybe_update_motor(is_forward_direction, target_pwm);
}

void main(void) {
  init();
  while (1) {
    loop();
    _delay_ms(LOOP_DELAY_MS);
  }
}
