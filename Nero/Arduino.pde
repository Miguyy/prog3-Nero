import processing.serial.*;

// ---------------------------------------------------------------------------
// Arduino Uno R3 link -- joystick controls P2 (jump/crouch), active buzzer
// beeps whenever a player dies in multiplayer. See the wiring + sketch notes
// sent alongside this file.
//
// Protocol (Arduino -> Processing, one line at a time over Serial):
//   "U\n"  joystick tilted up    -> P2 jump
//   "D\n"  joystick tilted down  -> P2 crouch
//   "N\n"  joystick neutral      -> P2 idle
//   "B\n"  SW button pressed     -> toggle multiplayer (same as pressing M),
//                                   only outside of GAME
//
// Protocol (Processing -> Arduino, single byte):
//   'L'    a player just died in multiplayer -> sound the buzzer
// ---------------------------------------------------------------------------

Serial arduinoPort;
boolean arduinoConnected = false;

boolean arduinoUpHeld = false;
boolean arduinoDownHeld = false;

// >>> CHANGE THIS to match your Arduino's port. Run the sketch once, check
// the console -- it prints every port Processing can see (Serial.list()) --
// and copy the exact name/number that corresponds to your Arduino. <<<
// Examples: "COM3" on Windows, "/dev/cu.usbmodem14101" on macOS,
// "/dev/ttyACM0" on Linux.
String ARDUINO_PORT_NAME = "COM3";
final int ARDUINO_BAUD_RATE = 9600;

void loadArduino() {
  println("Available serial ports:");
  printArray(Serial.list());

  try {
    arduinoPort = new Serial(this, ARDUINO_PORT_NAME, ARDUINO_BAUD_RATE);
    arduinoPort.bufferUntil('\n');
    arduinoConnected = true;
    println("Arduino connected on " + ARDUINO_PORT_NAME);
  }
  catch (Exception e) {
    println("Arduino not found on '" + ARDUINO_PORT_NAME + "' -- P2 will use the W/S keyboard fallback instead. (" + e.getMessage() + ")");
    arduinoPort = null;
    arduinoConnected = false;
  }
}

// Processing calls this automatically whenever a full line arrives, thanks
// to bufferUntil('\n') above.
void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  line = trim(line);

  if (line.equals("U")) {
    arduinoUpHeld = true;
    arduinoDownHeld = false;
  } else if (line.equals("D")) {
    arduinoDownHeld = true;
    arduinoUpHeld = false;
  } else if (line.equals("N")) {
    arduinoUpHeld = false;
    arduinoDownHeld = false;
  } else if (line.equals("B")) {
    if (currentState != GAME) {
      multiplayerMode = !multiplayerMode;
      playSFX("botoes.mp3");
    }
  }
}

// Called once from Game.pde the instant a player dies in multiplayer.
void buzzArduino() {
  if (arduinoConnected && arduinoPort != null) {
    arduinoPort.write('L');
  }
}

// P2's actual input source -- Arduino joystick if connected, otherwise W/S
// on the keyboard. Player.update() calls these two directly.
boolean isP2JumpHeld() {
  if (arduinoConnected) return arduinoUpHeld;
  return p2KeyUpHeld;
}

boolean isP2CrouchHeld() {
  if (arduinoConnected) return arduinoDownHeld;
  return p2KeyDownHeld;
}
