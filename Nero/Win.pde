PImage winBgImg;

void loadWinAssets() {
  // winBgImg = loadImage("win_bg.png"); // TODO: uncomment once win_bg.png is added to data/
}

void drawWin() {
  int t = millis() - stateEnterMillis;

  if (t < 1000) {
    // Stage 1: still on the in-level backdrop, player standing near the tree/cat.
    drawSceneBackdrop();
    drawTreesAndCat();
    player.display();
  } else if (t < 2000) {
    // Stage 2: cut to the light "found" background.
    drawWinBackground();
    drawWinComposition();
  } else if (t < 5000) {
    // Stage 3: same frame, text overlay.
    drawWinBackground();
    drawWinComposition();

    fill(40, 28, 51);
    textAlign(CENTER, CENTER);
    textFont(titleFont);
    text("YOU WON!", width / 2, height * 0.75);
    textFont(uiFont);
    text("YOU FOUND NERO, TIME TO GO HOME", width / 2, height * 0.82);
  } else {
    startNextLevel();
    changeState(GAME);
  }
}

void drawWinBackground() {
  if (winBgImg != null) {
    image(winBgImg, 0, 0, width, height);
  } else {
    background(255, 228, 206); // placeholder cream/peach fill until win_bg.png is delivered
  }
}

void drawWinComposition() {
  float floorLineY = height - 80;
  float treeW = (treeImg != null) ? treeImg.width : 0;
  float treeH = (treeImg != null) ? treeImg.height : 0;

  safeImage(playerIdleImg, width * 0.1, floorLineY - (playerIdleImg != null ? playerIdleImg.height : 0));
  safeImage(treeImg, width * 0.55, floorLineY - treeH);
  safeImage(catImg, width * 0.55 + treeW * 0.7, floorLineY - (catImg != null ? catImg.height : 0));
}
