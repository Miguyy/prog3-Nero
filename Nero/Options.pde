DwellTarget musicMinusBtn, musicPlusBtn, sfxMinusBtn, sfxPlusBtn, cancelBtn, saveBtn;
final float VOLUME_STEP = 0.1;

void loadOptionsAssets() {
  float panelW = width * 0.32;
  float panelX = width / 2 - panelW / 2;
  float sliderY1 = height * 0.32;
  float sliderY2 = height * 0.44;
  float btnSize = height * 0.04;

  musicMinusBtn = new DwellTarget(panelX + 20, sliderY1, btnSize, btnSize);
  musicPlusBtn = new DwellTarget(panelX + panelW - 20 - btnSize, sliderY1, btnSize, btnSize);
  sfxMinusBtn = new DwellTarget(panelX + 20, sliderY2, btnSize, btnSize);
  sfxPlusBtn = new DwellTarget(panelX + panelW - 20 - btnSize, sliderY2, btnSize, btnSize);

  float btnW = width * 0.14;
  float btnH = height * 0.06;
  cancelBtn = new DwellTarget(width / 2 - btnW - 10, height * 0.66, btnW, btnH);
  saveBtn = new DwellTarget(width / 2 + 10, height * 0.66, btnW, btnH);
}

void drawOptions() {
  drawSceneBackdrop();
  drawTreesAndCat();

  float panelW = width * 0.32;
  float panelX = width / 2 - panelW / 2;
  float panelY = height * 0.2;
  float panelH = height * 0.35;

  drawPanel(panelX, panelY, panelW, panelH, panelH * 0.15);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("OPTIONS", panelX + panelW / 2, panelY + panelH * 0.1);

  drawVolumeSlider("MUSIC VOLUME", musicMinusBtn, musicPlusBtn, getMusicVolume());
  drawVolumeSlider("SFX VOLUME", sfxMinusBtn, sfxPlusBtn, getSFXVolume());

  drawPillButton(cancelBtn, "CANCEL");
  drawPillButton(saveBtn, "SAVE");

  PVector p = getHandScreenPos();
  boolean pointing = isHandPointing();

  if (musicMinusBtn.update(p, pointing)) setMusicVolume(getMusicVolume() - VOLUME_STEP);
  if (musicPlusBtn.update(p, pointing)) setMusicVolume(getMusicVolume() + VOLUME_STEP);
  if (sfxMinusBtn.update(p, pointing)) setSFXVolume(getSFXVolume() - VOLUME_STEP);
  if (sfxPlusBtn.update(p, pointing)) setSFXVolume(getSFXVolume() + VOLUME_STEP);
  if (cancelBtn.update(p, pointing)) {
    loadSettings();
    changeState(MENU);
  }
  if (saveBtn.update(p, pointing)) {
    saveSettings();
    changeState(MENU);
  }
}

void drawVolumeSlider(String label, DwellTarget minusBtn, DwellTarget plusBtn, float value) {
  fill(40, 28, 51);
  textAlign(LEFT, BOTTOM);
  textFont(uiFont);
  text(label, minusBtn.x, minusBtn.y - 6);

  float trackX = minusBtn.x + minusBtn.w + 10;
  float trackW = plusBtn.x - trackX - 10;
  float trackY = minusBtn.y;
  float trackH = minusBtn.h;

  noStroke();
  fill(HUD_PINK);
  rect(trackX, trackY, trackW, trackH, trackH / 2);
  fill(200, 40, 70);
  rect(trackX, trackY, trackW * value, trackH, trackH / 2);

  drawSquareButton(minusBtn, "-");
  drawSquareButton(plusBtn, "+");
}

void drawSquareButton(DwellTarget b, String label) {
  noStroke();
  fill(255, 228, 206);
  rect(b.x, b.y, b.w, b.h);

  noFill();
  stroke(HUD_PINK);
  strokeWeight(2);
  rect(b.x, b.y, b.w, b.h);

  if (b.progress > 0) {
    noStroke();
    fill(red(HUD_PINK), green(HUD_PINK), blue(HUD_PINK), 140);
    rect(b.x, b.y, b.w * b.progress, b.h);
  }

  noStroke();
  fill(40, 28, 51);
  textAlign(CENTER, CENTER);
  text(label, b.x + b.w / 2, b.y + b.h / 2);
}

void optionsMousePressed() {
  PVector p = new PVector(mouseX, mouseY);
  if (musicMinusBtn.contains(p)) setMusicVolume(getMusicVolume() - VOLUME_STEP);
  else if (musicPlusBtn.contains(p)) setMusicVolume(getMusicVolume() + VOLUME_STEP);
  else if (sfxMinusBtn.contains(p)) setSFXVolume(getSFXVolume() - VOLUME_STEP);
  else if (sfxPlusBtn.contains(p)) setSFXVolume(getSFXVolume() + VOLUME_STEP);
  else if (cancelBtn.contains(p)) {
    loadSettings();
    changeState(MENU);
  } else if (saveBtn.contains(p)) {
    saveSettings();
    changeState(MENU);
  }
}

void optionsMouseDragged() {
  // No drag interaction -- volume is adjusted exclusively via +/- steps (dwell or click),
  // consistent with the Kinect-dwell-everywhere input model.
}

void optionsMouseReleased() {
}
