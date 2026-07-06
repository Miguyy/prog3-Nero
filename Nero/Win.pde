PImage catImg;
int catFrameW;

void loadWinAssets() {
  catImg  = loadImage("cat-1.png");
}

void drawWin() {
  player.forceIdle = true;
  player.forcedImg = player.defaultImg;
  int t = millis() - stateEnterMillis;
  
  if (t < 1500) {
    drawSceneBackdrop();
    drawTreeAndCatWin(width / 2, height - 80);
    player.display();
  } else if (t < 3000) {
    float p = constrain((t - 1500) / 1500.0, 0, 1);
    float pSky = constrain((t - 1500) / 1500.0, 0, 1);
    drawWinTransition(p, pSky);
  } else if (t < 5500) {
    drawWinFinalScene();
  } else if (t < 6000) {
    drawWinFinalScene();

    float fadeStart = 5500;
    float fadeDur   = 500;
    float textAlpha = constrain(map(t, fadeStart, fadeStart + fadeDur, 0, 255), 0, 255);

    fill(HUD_CREAM, textAlpha);
    textAlign(CENTER, CENTER);
    textFont(titleFont);
    textSize(64);
    text("YOU WON!", width / 2, height * 0.75);

    textFont(uiFont);
    textSize(24);
    text("YOU FOUND NERO, TIME TO GO HOME", width / 2, height * 0.82);
  } else {
    startNextLevel();
    changeState(GAME);
  }
}

void drawTreeAndCatWin(float centerX, float floorLineY) {
  float treeW = (treeImg != null) ? treeImg.width * treeScale : 0;
  float treeH = (treeImg != null) ? treeImg.height * treeScale : 0;
  float treeX = centerX - treeW / 2;

  if (treeImg != null) {
    image(treeImg, treeX, floorLineY - treeH + treeYOffset, treeW, treeH);
  }

  if (frameCount % catFrameInterval == 0) {
    catFrameIndex = (catFrameIndex + 1) % 5;
  }
  PImage currentCatFrame = catFrames[catFrameIndex];

  if (currentCatFrame != null) {
    float catW = currentCatFrame.width * catScale;
    float catH = currentCatFrame.height * catScale;
    float catX = treeX + treeW * 0.7;
    float catY = floorLineY - catH + catYOffset;

    pushMatrix();
    translate(catX + catW, catY);
    scale(-1, 1);
    image(currentCatFrame, 0, 0, catW, catH);
    popMatrix();
  }
}

void drawWinFinalScene() {
  background(HUD_CREAM);

  noStroke();
  fill(#3D2C4D);
  rect(0, height / 2, width, height - height / 2);

  float floorStartY = 100;
  float floorTargetY = height / 2 - floorImg.height + 100 ;
  image(floorImg, 0, floorTargetY);



  float dy = floorStartY - floorTargetY;
  pushMatrix();
  translate(0, -dy);
  drawTreeAndCatWin(width / 2, height - 80);
  player.display();
  popMatrix();
}

void drawWinTransition(float p, float pSky) {
  background(HUD_CREAM);

  float skyDy = lerp(0, height + skyImg.height, pSky);
  pushMatrix();
  translate(0, -skyDy);
  image(skyImg, 0, 0);
  clouds.update();
  clouds.display();
  popMatrix();

  float floorStartY = 100;
  float floorTargetY = height / 2 - floorImg.height + 100;
  float floorY = lerp(floorStartY, floorTargetY, p);
  float groundDy = floorStartY - floorY;

  pushMatrix();
  translate(0, -groundDy);
  image(floorImg, 0, floorStartY);
  drawTreeAndCatWin(width / 2, height - 80);
  player.display();
  popMatrix();

  noStroke();
  fill(#3D2C4D);
  rect(0, floorY + floorImg.height, width, height - (floorY + floorImg.height));
}