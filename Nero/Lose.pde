void drawLose() {
  int t = millis() - stateEnterMillis;

  if (t < 1500) {
    // Stage 1: in-level backdrop, player alone on the floor.
    drawSceneBackdrop();
    image(playerIdleImg, player.x, groundY - playerIdleImg.height);
  } else if (t < 2500) {
    // Stage 2: cut to a plain dark background.
    background(#0A0A14);
    image(playerIdleImg, width * 0.4, height * 0.6);
  } else if (t < 5000) {
    // Stage 3: same frame, red text overlay.
    background(#0A0A14);
    image(playerIdleImg, width * 0.4, height * 0.6);

    fill(220, 40, 60);
    textAlign(CENTER, CENTER);
    textFont(titleFont);
    text("GAME OVER", width / 2, height * 0.8);
  } else {
    resetGameFull();
    changeState(MENU);
  }
}
