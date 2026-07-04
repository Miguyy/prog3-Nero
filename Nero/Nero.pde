// paleta de cores
color HUD_CREAM, 
      HUD_LIGHTPINK, 
      HUD_PINK,
      HUD_YELLOW,
      HUD_STEELBLUE,
      HUD_PURPLE,
      HUD_RED,
      HUD_BLUE,
      HUD_BLACK;

final int MENU = 0;
final int GAME = 1;
final int SCORE = 2;
final int OPTIONS = 3;
final int WIN = 4;
final int LOSE = 5;

int currentState = MENU;
int previousState = MENU;
int stateEnterMillis = 0;

int score = 0;
int level = 1;

PFont uiFont;
PFont titleFont;

boolean fallbackUpHeld = false;
boolean fallbackDownHeld = false;


void setup() {
  fullScreen(P2D);
  frameRate(60);
  noCursor();

  HUD_CREAM  = color(255, 228, 206);
  HUD_LIGHTPINK  = color(236, 128, 180);
  HUD_PINK  = color(217, 74, 145);
  HUD_YELLOW  = color(242, 208, 160);
  HUD_STEELBLUE = color(129, 153, 201);
  HUD_PURPLE  = color(40, 28, 51);
  HUD_RED  = color(215, 30, 70);
  HUD_BLUE  = color(94, 209, 228);
  HUD_BLACK  = color(40, 28, 51);

  loadFonts();
  loadBackground();
  loadMenuAssets();
  loadScores();
  loadOptionsAssets();
  loadWinAssets();
  loadAudio();
  loadKinect();

  skyImg.resize((int)width, (int)(height - 100));
  floorImg.resize((int)width, (int)(height - 100));

  changeState(MENU);
}


void draw() {
  updateKinectInput();

  switch (currentState) {
    case MENU:
      drawMenu();
      break;
    case GAME:
      drawGame();
      break;
    case SCORE:
      drawScore();
      break;
    case OPTIONS:
      drawOptions();
      break;
    case WIN:
      drawWin();
      break;
    case LOSE:
      drawLose();
      break;
  }

  drawHandCursor();
}

float loseFloorStartY = 100;
float loseFloorTargetY;
float losePlayerStartX, losePlayerTargetX;

void changeState(int newState) {
  previousState = currentState;
  currentState = newState;
  stateEnterMillis = millis();
  resetDwellState();
  playMusicForState(newState);
  if (newState == LOSE) {
    player.jumping = false;
    player.crouching = false;
    player.velY = 0;
    player.y = groundY;

    losePlayerStartX = player.x;
    losePlayerTargetX = width / 2 - (player.defaultImg.width * player.scale) / 2;
    loseFloorTargetY = height / 2 - floorImg.height + 100;

    submitScore(score, level);
  }
}

void loadFonts() {
  uiFont = createFont("Silkscreen-Regular.ttf", 24);
  titleFont = createFont("Silkscreen-Regular.ttf", 48);
  textFont(uiFont);
}

// Several art assets haven't been delivered yet (see the plan's asset table) --
// loadImage() returns null for those instead of throwing, so drawing code calls
// through these helpers rather than image() directly to avoid a NullPointerException
// on every frame until the real PNGs are dropped into data/.
void safeImage(PImage img, float x, float y) {
  if (img != null) image(img, x, y);
}

void safeImage(PImage img, float x, float y, float w, float h) {
  if (img != null) image(img, x, y, w, h);
}

void mousePressed() {
  switch (currentState) {
    case MENU:
      menuMousePressed();
      break;
    case SCORE:
      scoreMousePressed();
      break;
    case OPTIONS:
      optionsMousePressed();
      break;
  }
}

void mouseDragged() {
  if (currentState == OPTIONS) optionsMouseDragged();
}

void mouseReleased() {
  if (currentState == OPTIONS) optionsMouseReleased();
}

void keyPressed() {
  if (keyCode == UP) fallbackUpHeld = true;
  if (keyCode == DOWN) fallbackDownHeld = true;

  if (key == 'w' || key == 'W') changeState(WIN); // atalho de debug -- tirar antes de entregar
}

void keyReleased() {
  if (keyCode == UP) fallbackUpHeld = false;
  if (keyCode == DOWN) fallbackDownHeld = false;
}
