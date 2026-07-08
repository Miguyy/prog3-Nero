// Shared UI assets, also used by Score.pde / Options.pde / Win.pde
PImage treeImg, pillButtonImg, panelImg, cursorImg, clickImg;
PImage startBtnImg, scoreBtnImg, optionsBtnImg, exitBtnImg;

PImage[] catFrames = new PImage[5];
int catFrameIndex = 0;
int catFrameInterval = 16;

DwellTarget[] menuButtons = new DwellTarget[4];
String[] menuLabels = {"START", "SCORE", "OPTIONS", "EXIT"};
PImage[] menuBtnImgs = new PImage[4];

void loadMenuAssets() {

  cursorImg = loadImage("cursor.png");
  cursorImg.resize(100, 100); 

  clickImg = loadImage("click.png");
  clickImg.resize(100, 100);

  treeImg = loadImage("tree.png");

  for (int i = 1; i <= 5; i++) {
    catFrames[i - 1] = loadImage("cat-" + i + ".png");
  }

  startBtnImg = loadImage("start.png");
  scoreBtnImg = loadImage("score.png");
  optionsBtnImg = loadImage("options.png");
  exitBtnImg = loadImage("exit.png");

  menuBtnImgs[0] = startBtnImg;
  menuBtnImgs[1] = scoreBtnImg;
  menuBtnImgs[2] = optionsBtnImg;
  menuBtnImgs[3] = exitBtnImg;

  float btnW = width * 0.22;
  float btnH = height * 0.07;
  float gap = height * 0.02;
  float stackTop = height * 0.30;
  float bx = width / 2 - btnW / 2;

  for (int i = 0; i < 4; i++) {
    menuButtons[i] = new DwellTarget(bx, stackTop + i * (btnH + gap), btnW, btnH);
  }
}

void drawMenu() {
  drawSceneBackdrop();
  drawTreesAndCat();

  PVector p = getHandScreenPos();
  boolean pointing = isHandPointing();

  for (int i = 0; i < 4; i++) {
    boolean selected = menuButtons[i].update(p, pointing);
    drawMenuButton(menuButtons[i], menuBtnImgs[i]);
    if (selected) onMenuButtonSelected(i);
  }
}

float treeScale = 0.25;
float catScale = 0.2;
float treeYOffset = -20;
float catYOffset = 15;
float treeMarginPct = 0.10;

void drawTreesAndCat() {
  float floorLineY = height - 80;
  float treeW = (treeImg != null) ? treeImg.width * treeScale : 0;
  float treeH = (treeImg != null) ? treeImg.height * treeScale : 0;

  float leftX = width * treeMarginPct;

  if (treeImg != null) {

    image(treeImg, leftX, floorLineY - treeH + treeYOffset, treeW, treeH);

    float rightX = width * (1 - treeMarginPct) - treeW;
    image(treeImg, rightX, floorLineY - treeH + treeYOffset, treeW, treeH);
  }

  if (frameCount % catFrameInterval == 0) {
    catFrameIndex = (catFrameIndex + 1) % 5;
  }
  PImage currentCatFrame = catFrames[catFrameIndex];

  if (currentCatFrame != null) {
    float catW = currentCatFrame.width * catScale;
    float catH = currentCatFrame.height * catScale;
    float catX = leftX + treeW * 0.7;
    float catY = floorLineY - catH + catYOffset;

    pushMatrix();
    translate(catX + catW, catY);
    scale(-1, 1);
    image(currentCatFrame, 0, 0, catW, catH);
    popMatrix();
  }
}

void drawMenuButton(DwellTarget b, PImage img) {
  if (img != null) {
    float ix = b.x + b.w / 2 - img.width / 2;
    float iy = b.y + b.h / 2 - img.height / 2;
    image(img, ix, iy);
  } else {
    // Placeholder until pill_button.png is delivered, so buttons stay visible/clickable.
    noStroke();
    fill(255, 228, 206);
    rect(b.x, b.y, b.w, b.h, b.h / 2);
    noFill();
    stroke(HUD_PINK);
    strokeWeight(3);
    rect(b.x, b.y, b.w, b.h, b.h / 2);
  }

  // if (b.progress > 0) {
  //   noStroke();
  //   fill(red(HUD_PINK), green(HUD_PINK), blue(HUD_PINK), 140);
  //   rect(b.x, b.y, b.w * b.progress, b.h);
  // }
}

// Shared by Score.pde/Options.pde -- draws panel.png if available, else a
// pink-header/beige-body placeholder so both screens stay usable in the meantime.
void drawPanel(float x, float y, float w, float h, float headerH) {
  if (panelImg != null) {
    image(panelImg, x, y, w, h);
  } else {
    noStroke();
    fill(255, 228, 206);
    rect(x, y, w, h);
    fill(HUD_PINK);
    rect(x, y, w, headerH);
    noFill();
    stroke(HUD_PINK);
    strokeWeight(3);
    rect(x, y, w, h);
  }
}

void onMenuButtonSelected(int i) {
  playSFX("botoes.mp3");
  switch (i) {
    case 0: // START
      resetGameFull();
      changeState(GAME);
      break;
    case 1: // SCORE
      changeState(SCORE);
      break;
    case 2: // OPTIONS
      changeState(OPTIONS);
      break;
    case 3: // EXIT
      exit();
      break;
  }
}

void menuMousePressed() {
  PVector p = new PVector(mouseX, mouseY);
  for (int i = 0; i < 4; i++) {
    if (menuButtons[i].contains(p)) {
      onMenuButtonSelected(i);
      return;
    }
  }
}

void drawHandCursor() {
  if (currentState != MENU && currentState != SCORE && currentState != OPTIONS) return;
  PVector p = getHandScreenPos();
  PImage cur = isAnyDwellActive() ? clickImg : cursorImg;
  if (cur != null) image(cur, p.x - cur.width / 2, p.y - cur.height / 2);
}

boolean isAnyDwellActive() {
  // Only look at buttons that were actually checked THIS frame (i.e. the
  // ones on the screen you're currently viewing) -- not every DwellTarget
  // that has ever existed. See dwellTargetsUpdatedThisFrame in Kinect.pde.
  for (DwellTarget t : dwellTargetsUpdatedThisFrame) {
    if (t.progress > 0) return true;
  }
  return false;
}