// Shared UI assets, also used by Score.pde / Options.pde / Win.pde
PImage treeImg, catImg, pillButtonImg, panelImg, cursorImg, clickImg;

DwellTarget[] menuButtons = new DwellTarget[4];
String[] menuLabels = {"START", "SCORE", "OPTIONS", "EXIT"};

void loadMenuAssets() {
  // treeImg = loadImage("tree.png"); // TODO: uncomment once tree.png is added to data/
  // catImg = loadImage("cat.png"); // TODO: uncomment once cat.png is added to data/
  // pillButtonImg = loadImage("pill_button.png"); // TODO: uncomment once pill_button.png is added to data/
  // panelImg = loadImage("panel.png"); // TODO: uncomment once panel.png is added to data/
  cursorImg = loadImage("cursor.png");
  clickImg = loadImage("click.png");

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
    drawPillButton(menuButtons[i], menuLabels[i]);
    if (selected) onMenuButtonSelected(i);
  }
}

void drawTreesAndCat() {
  float floorLineY = height - 80;
  float treeW = (treeImg != null) ? treeImg.width : 0;
  float treeH = (treeImg != null) ? treeImg.height : 0;

  if (treeImg != null) {
    image(treeImg, width * 0.06, floorLineY - treeH);

    pushMatrix();
    translate(width * 0.94 + treeW, floorLineY - treeH);
    scale(-1, 1);
    image(treeImg, 0, 0);
    popMatrix();
  }

  if (catImg != null) {
    image(catImg, width * 0.06 + treeW * 0.7, floorLineY - catImg.height);
  }
}

void drawPillButton(DwellTarget b, String label) {
  if (pillButtonImg != null) {
    image(pillButtonImg, b.x, b.y, b.w, b.h);
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

  if (b.progress > 0) {
    noStroke();
    fill(red(HUD_PINK), green(HUD_PINK), blue(HUD_PINK), 140);
    rect(b.x, b.y, b.w * b.progress, b.h);
  }

  fill(40, 28, 51);
  textAlign(CENTER, CENTER);
  textFont(uiFont);
  text(label, b.x + b.w / 2, b.y + b.h / 2);
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
  playSFX("sfx_select.wav");
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
  for (DwellTarget t : allDwellTargets) {
    if (t.progress > 0) return true;
  }
  return false;
}
