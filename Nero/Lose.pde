void drawLose() {
  player.forceIdle = true;
  player.forcedImg = player.gameOverImg;
  int t = millis() - stateEnterMillis;

  if (t < 1500) {
    drawSceneBackdrop();
    player.display();
  } else if (t < 3000) {
    float p = constrain((t - 1500) / 1500.0, 0, 1);
    drawLoseTransition(p);
  } else if (t < 5500) {
    drawLoseTransition(1);

    float textAlpha = fadeAlpha(t, 3000, 600);

    fill(220, 40, 60, textAlpha);
    textAlign(CENTER, CENTER);
    textFont(titleFont);
    textSize(64);
    text("GAME OVER", width / 2, height * 0.8);
  } else {
    resetGameFull();
    changeState(MENU);
  }
}

void drawLoseTransition(float p) {
  background(HUD_BLACK);

  float floorY = lerp(loseFloorStartY, loseFloorTargetY, p);
  float dy = lerpDelta(loseFloorStartY, loseFloorTargetY, p);

  pushMatrix();
  translate(0, -dy);
  image(floorImg, 0, loseFloorStartY);
  popMatrix();

  float px = lerp(losePlayerStartX, losePlayerTargetX, p);
  pushMatrix();
  translate(px - losePlayerStartX, -dy);
  player.display();
  popMatrix();

  drawGroundFill(floorY + floorImg.height);
}