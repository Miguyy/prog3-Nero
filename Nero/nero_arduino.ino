/*
  NERO -- Arduino Uno R3 controller for Player 2
  =================================================

  Wiring:
    Joystick module:
      GND  -> GND
      +5V  -> 5V
      VRy  -> A1
      SW   -> Pin 2   (digital, uses the internal pull-up resistor)

    Active buzzer:
      +    -> Pin 8
      -    -> GND

  Behaviour:
    - Tilt the joystick UP    -> sends "U" -> Processing makes P2 jump.
    - Tilt the joystick DOWN  -> sends "D" -> Processing makes P2 crouch.
    - Release to center       -> sends "N" -> P2 goes back to idle/running.
    - Press the SW button     -> sends "B" -> toggles multiplayer mode in
                                   the game (same as pressing "M" on the
                                   keyboard). Only takes effect on the
                                   Menu/Score/Options/Win/Lose screens.
    - When a player dies in multiplayer, Processing sends the byte 'L'
      back to the Arduino, which sounds the active buzzer for ~300ms.

  IMPORTANT -- active vs passive buzzer:
    An ACTIVE buzzer has its own internal oscillator: it just needs power
    (HIGH/LOW), so this sketch uses plain digitalWrite(), NOT tone().
    If you swap in a PASSIVE buzzer later, you'd need tone()/noTone()
    instead, since a passive buzzer has no built-in tone generator.
*/

const int JOY_Y_PIN   = A1;
const int JOY_SW_PIN  = 2;
const int BUZZER_PIN  = 8;

// Adjust these two if your joystick's resting value isn't exactly centered,
// or if "U"/"D" trigger too easily/too late. Read the raw value in the
// Serial Monitor (uncomment the debug line in loop()) to help calibrate.
const int CENTER   = 512;
const int DEADZONE = 150;

// Debounce for the SW button so one physical press = one "B", not dozens.
const unsigned long BUTTON_DEBOUNCE_MS = 250;
unsigned long lastButtonMillis = 0;
int lastButtonState = HIGH; // HIGH = not pressed (INPUT_PULLUP)

int lastJoyState = 0; // 0 = neutral, 1 = up, 2 = down

void setup() {
  Serial.begin(9600);
  pinMode(JOY_SW_PIN, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  readJoystick();
  readButton();
  readFromProcessing();

  delay(20); // ~50 messages/sec is plenty and keeps Serial from flooding
}

void readJoystick() {
  int yVal = analogRead(JOY_Y_PIN);
  // Uncomment to calibrate CENTER/DEADZONE above:
  // Serial.print("raw: "); Serial.println(yVal);

  int state;
  if (yVal < CENTER - DEADZONE) {
    state = 1; // tilted one way -> jump
  } else if (yVal > CENTER + DEADZONE) {
    state = 2; // tilted the other way -> crouch
  } else {
    state = 0; // centered
  }

  if (state != lastJoyState) {
    if (state == 1) Serial.println("U");
    else if (state == 2) Serial.println("D");
    else Serial.println("N");
    lastJoyState = state;
  }
}

void readButton() {
  int reading = digitalRead(JOY_SW_PIN);
  if (reading == LOW && lastButtonState == HIGH &&
      (millis() - lastButtonMillis) > BUTTON_DEBOUNCE_MS) {
    Serial.println("B");
    lastButtonMillis = millis();
  }
  lastButtonState = reading;
}

void readFromProcessing() {
  if (Serial.available() > 0) {
    char c = Serial.read();
    if (c == 'L') {
      digitalWrite(BUZZER_PIN, HIGH);
      delay(300);
      digitalWrite(BUZZER_PIN, LOW);
    }
  }
}
