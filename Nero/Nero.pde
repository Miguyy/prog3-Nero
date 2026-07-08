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
  HUD_PURPLE  = color(82, 64, 122);
  HUD_RED  = color(215, 30, 70);
  HUD_BLUE  = color(94, 209, 228);
  HUD_BLACK  = color(40, 28, 51);

  loadFonts();
  loadBackground();
  loadMenuAssets();
  loadScores();
  loadOptionsAssets();
  loadAudio();
  loadKinect();

  skyImg.resize((int)width, (int)(height - 100));
  floorImg.resize((int)width, (int)(height - 100));

  changeState(MENU);
}


void draw() {
  // Must run before any screen draws its buttons -- this is what scopes the
  // hand-cursor's "hovering something" check to ONLY the buttons that are
  // actually live on the current screen this frame (see isAnyDwellActive()
  // in Menu.pde and DwellTarget.update() in Kinect.pde). Without this reset,
  // buttons from whatever screen you visited previously kept influencing the
  // cursor sprite on every screen after that.
  clearDwellFrameState();

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
  if (newState == GAME) {
    resetKinectCalibration();
  }
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

// Vários assets ainda não foram entregues -- loadImage() retorna null nesses
// casos ao invés de lançar exceção, então o código de desenho passa por estes
// helpers em vez de image() diretamente para evitar um NullPointerException
// em todo frame até os PNGs reais serem colocados em data/.
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

//--------------------------------//
//         🔧   UTILS             //
//--------------------------------//

// Calcula o alpha (0-255) de um fade in baseado no tempo decorrido.
// t = tempo atual (ex: millis() - stateEnterMillis)
// start = momento em que o fade deve começar
// dur = duração do fade em ms
float fadeAlpha(float t, float start, float dur) {
  return constrain(map(t, start, start + dur, 0, 255), 0, 255);
}

// Scans an image's alpha channel for the first/last row containing a
// non-transparent pixel. Usado pra encontrar a extensão vertical real de um
// sprite quando o canvas tem padding transparente.
int[] opaqueVerticalBounds(PImage img) {
  img.loadPixels();
  int top = -1;
  int bottom = -1;
  for (int y = 0; y < img.height; y++) {
    int rowStart = y * img.width;
    for (int x = 0; x < img.width; x++) {
      if (alpha(img.pixels[rowStart + x]) > 10) {
        if (top == -1) top = y;
        bottom = y;
        break;
      }
    }
  }
  if (top == -1) {
    top = 0;
    bottom = img.height - 1;
  }
  return new int[]{ top, bottom };
}

// Calcula o deslocamento (delta) a aplicar num translate() para uma
// transição de posição de start -> target, dado o progresso p (0-1).
float lerpDelta(float start, float target, float p) {
  float current = lerp(start, target, p);
  return start - current;
}

// Calcula as métricas verticais reais de um sprite (ignorando padding
// transparente do canvas): topo visível, altura visível, e espaço vazio
// abaixo dos pés. Devolve {visTop, visHeight, bottomPad}.
float[] spriteVerticalMetrics(PImage img) {
  int[] b = opaqueVerticalBounds(img);
  float visTop = b[0];
  float visHeight = b[1] - b[0] + 1;
  float bottomPad = img.height - (b[1] + 1);
  return new float[]{ visTop, visHeight, bottomPad };
}

void drawGroundFill(float topY) {
  noStroke();
  fill(#3D2C4D);
  rect(0, topY, width, height - topY);
}