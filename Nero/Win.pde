PImage catImg;
int catFrameW;

void loadWinAssets() {
  catImg  = loadImage("cat-1.png");
}

// Text timeline: fades in (5500-6000), then HOLDS fully visible until
// T_HOLD_END, then fades back out before the next level starts. Previously
// the text finished fading in at 6000 and the very next frame kicked off
// startNextLevel()/changeState(GAME), so it was only ever visible mid-fade
// and never actually held on screen -- hence it looked like it vanished
// almost instantly.
final int T_INTRO_END      = 1500;
final int T_TRANSITION_END = 3000;
final int T_FADE_IN_START  = 5500;
final int T_FADE_IN_END    = 6000;
final int T_HOLD_END       = 8500;
final int T_FADE_OUT_END   = 9000;

void drawWin() {
  player.forceIdle = true;
  player.forcedImg = player.defaultImg;
  int t = millis() - stateEnterMillis;

  if (t < T_INTRO_END) {
    drawSceneBackdrop();
    drawTreeAndCatWin(width / 2, height - 80);
    player.display();
  } else if (t < T_TRANSITION_END) {
    float p = constrain((t - T_INTRO_END) / float(T_TRANSITION_END - T_INTRO_END), 0, 1);
    drawWinTransition(p, p);
  } else if (t < T_FADE_IN_START) {
    drawWinFinalScene();
  } else if (t < T_FADE_OUT_END) {
    drawWinFinalScene();

    float textAlpha;
    if (t < T_FADE_IN_END) {
      textAlpha = map(t, T_FADE_IN_START, T_FADE_IN_END, 0, 255);
    } else if (t < T_HOLD_END) {
      textAlpha = 255;
    } else {
      textAlpha = map(t, T_HOLD_END, T_FADE_OUT_END, 255, 0);
    }
    textAlpha = constrain(textAlpha, 0, 255);

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