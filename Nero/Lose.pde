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

    float fadeStart = 3000;
    float fadeDur   = 600;
    float textAlpha = constrain(map(t, fadeStart, fadeStart + fadeDur, 0, 255), 0, 255);

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
  background(#0A0A14);

  float floorY = lerp(loseFloorStartY, loseFloorTargetY, p);
  float dy = loseFloorStartY - floorY;

  pushMatrix();
  translate(0, -dy);
  image(floorImg, 0, loseFloorStartY);
  popMatrix();

  float px = lerp(losePlayerStartX, losePlayerTargetX, p);
  pushMatrix();
  translate(px - losePlayerStartX, -dy);
  player.display();
  popMatrix();

  noStroke();
  fill(#3D2C4D);
  rect(0, floorY + floorImg.height, width, height - (floorY + floorImg.height));
}