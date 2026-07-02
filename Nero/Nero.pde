final int MENU = 0;
final int GAME = 1;
final int SCORE = 2;
final int OPTIONS = 3;
final int WIN = 4;
final int LOSE = 5;

int currentState = GAME;


void setup() {
  fullScreen(P2D);
  frameRate(60);
  loadBackground();

  skyImg.resize((int)width, (int)(height - 100));
  floorImg.resize((int)width, (int)(height - 100));
}


void draw() {
  switch(currentState) {
    case GAME:
      drawGame();
      break;
  }
}

void changeState(int newState) {
  currentState = newState;
}