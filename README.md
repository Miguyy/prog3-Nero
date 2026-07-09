<p align="center">
  <img src="./Nero/data/logo.png" alt="NERO Logo" width="220">
</p>

<p align="center">
A motion-controlled endless runner built with <b>Processing</b>, powered by a <b>Kinect</b> sensor and an optional <b>Arduino</b> controller for local multiplayer.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Processing-006699?style=for-the-badge&logo=processingfoundation&logoColor=white">
  <img src="https://img.shields.io/badge/Kinect-107C10?style=for-the-badge&logo=xbox&logoColor=white">
  <img src="https://img.shields.io/badge/Arduino-00979D?style=for-the-badge&logo=arduino&logoColor=white">
</p>

---

## 📖 Overview

NERO is a fullscreen endless runner where the player controls their character using body movement captured by a **Kinect v1** sensor.

- ⬆️ **Jump** by standing taller
- ⬇️ **Crouch** by lowering your hips
- 👥 Play solo or in **2-player local multiplayer**
- 🕹️ Player 2 uses a custom **Arduino joystick controller**
- ⌨️ Keyboard controls are available whenever the Kinect or Arduino are unavailable

Menus are completely hands-free, using a **dwell-selection interface**—simply point at a button with your right hand and hold for two seconds.

---

## ✨ Features

- 🎮 Motion-controlled gameplay
- 👥 Local 2-player mode
- 🕹️ Arduino joystick controller support
- ⌨️ Keyboard fallback controls
- 📈 Progressive difficulty
- 💾 Persistent leaderboard & settings
- 🎯 Kinect-powered hands-free menus
- 🔊 Adaptive audio system

---

## 🎮 Controls

| Action             | Kinect            | Keyboard (P1) | Arduino (P2)    | Keyboard (P2) |
| ------------------ | ----------------- | ------------- | --------------- | ------------- |
| Jump               | Stand taller      | ↑             | Joystick Up     | W             |
| Crouch             | Lower hips        | ↓             | Joystick Down   | S             |
| Toggle Multiplayer | —                 | M             | Joystick Button | M             |
| Menu Navigation    | Point & Hold (2s) | Mouse         | —               | —             |

---

## 🧩 Game Flow

| State       | Description             |
| ----------- | ----------------------- |
| **Intro**   | Animated intro sequence |
| **Menu**    | Main menu               |
| **Game**    | Core gameplay           |
| **Score**   | Local leaderboard       |
| **Options** | Audio settings          |
| **Win**     | Victory screen          |
| **Lose**    | Game over screen        |

---

# 🔌 Hardware

## Kinect (Player 1)

- Kinect for Windows v1
- `kinect4WinSDK` Processing library
- Automatic player calibration
- Skeleton tracking
- Hand cursor for UI navigation

If the Kinect isn't connected, the game automatically switches to keyboard controls.

---

## Arduino (Player 2)

Optional for multiplayer.

If disconnected, Player 2 automatically uses the keyboard (`W` / `S`).

### Wiring

| Component       | Pin   |
| --------------- | ----- |
| GND             | GND   |
| 5V              | 5V    |
| VRy             | A1    |
| SW              | Pin 2 |
| Active Buzzer + | Pin 8 |
| Active Buzzer - | GND   |

---

# 💻 Requirements

## Software

- Processing 3.x / 4.x
- Kinect4WinSDK
- Processing Sound
- Processing Serial
- Arduino IDE (optional)

---

# 📁 Project Structure

```text
Nero/
│
├── Nero.pde              # Main application
├── Game.pde              # Gameplay
├── Kinect.pde            # Kinect tracking
├── Arduino.pde           # Arduino communication
├── Audio.pde             # Audio manager
├── Intro.pde
├── Menu.pde
├── Options.pde
├── Score.pde
├── Win.pde
├── Lose.pde
├── nero_arduino.ino
└── data/
```

---

# ⚙️ Installation

### 1. Install Processing

Install Processing 3.x or newer.

Install the required libraries:

- kinect4WinSDK
- processing.sound
- processing.serial

---

### 2. Connect the Kinect

Connect the Kinect before launching the sketch.

---

### 3. (Optional) Configure Arduino

Upload `nero_arduino.ino` to your Arduino Uno.

Edit the serial port inside `Arduino.pde`:

```java
String ARDUINO_PORT_NAME = "COM3";
```

Examples:

```text
Windows : COM3
macOS   : /dev/cu.usbmodem14101
Linux   : /dev/ttyACM0
```

The Processing console prints every available serial port (`Serial.list()`), making it easy to identify the correct one.

---

### 4. Assets

Place all project assets inside the `data/` folder.

Required assets include:

- Fonts
- Backgrounds
- Character sprites
- Bubble sprites
- UI images
- HUD icons
- Audio

Runtime-generated files:

```
scores.json
settings.json
```

---

# ⚙️ Implementation Highlights

### Adaptive Calibration

Movement thresholds are calculated relative to each player's body proportions, making gameplay consistent across different heights.

### Joint Smoothing

Head and hip positions are filtered to reduce Kinect tracking noise.

### Dwell-Based UI

Menus use a shared dwell-selection system instead of mouse clicks.

### Progressive Difficulty

Obstacle speed increases while spawn intervals decrease over time.

### Accurate Collision Detection

Sprite hitboxes are generated from opaque pixels instead of image dimensions.

---

# 🚧 Limitations

- Kinect v1 only
- Windows Kinect SDK required
- Arduino serial port must be configured manually
- Some assets are placeholders until final artwork is added

---

# 👥 Contributors

| Name           | GitHub                         |
| -------------- | ------------------------------ |
| Miguel Machado | https://github.com/Miguyy      |
| Petúnia Dias   | https://github.com/petuniadias |
| Henrique Silva | https://github.com/HenReis     |
