DwellTarget musicMinusBtn, musicPlusBtn, sfxMinusBtn, sfxPlusBtn, cancelBtn, saveBtn;
final float VOLUME_STEP = 0.1;

PImage optionsPanelImg, cancelImg, saveImg, minusImg, plusImg, scaleImg;

// Layout is computed once here (screen size never changes mid-run) instead
// of every frame, which is also what let the DwellTargets below be created
// only once instead of being rebuilt (and having their hover timers reset)
// on every single frame.
float optPanelX, optPanelY, optPanelW, optPanelH;
float optMusicLabelY, optSfxLabelY, optLabelH;

void loadOptionsAssets() {
  optionsPanelImg = loadImage("options-wrapper.png");
  cancelImg = loadImage("cancel.png");
  saveImg = loadImage("save.png");
  minusImg = loadImage("minus.png");
  plusImg = loadImage("plus.png");
  scaleImg = loadImage("scale.png");

  if (optionsPanelImg == null) return;

  float maxW = width * 0.3;
  float maxH = height * 0.5;

  float imgRatio = optionsPanelImg.width / (float) optionsPanelImg.height;

  float panelW = maxW;
  float panelH = panelW / imgRatio;

  if (panelH > maxH) {
    panelH = maxH;
    panelW = panelH * imgRatio;
  }

  optPanelX = width / 2 - panelW / 2;
  optPanelY = height * 0.16;
  optPanelW = panelW;
  optPanelH = panelH;

  float headerRatio = 0.14;
  float bodyTopPad = 0.06;
  float bodyBottomPad = 0.06;

  float bodyTop = optPanelY + panelH * (headerRatio + bodyTopPad);
  float bodyBottom = optPanelY + panelH * (1 - bodyBottomPad);
  float bodyH = bodyBottom - bodyTop;

  float rowH = bodyH / 2;
  optLabelH = rowH * 0.35;

  optMusicLabelY = bodyTop;
  float musicSliderY = optMusicLabelY + optLabelH;

  optSfxLabelY = bodyTop + rowH;
  float sfxSliderY = optSfxLabelY + optLabelH;

  float sidePad = panelW * 0.06;
  float btnH = height * 0.07;
  float minusW = (minusImg != null) ? btnH * (minusImg.width / (float) minusImg.height) : btnH;
  float plusW  = (plusImg  != null) ? btnH * (plusImg.width  / (float) plusImg.height)  : btnH;

  musicMinusBtn = new DwellTarget(optPanelX + sidePad, musicSliderY, minusW, btnH);
  musicPlusBtn  = new DwellTarget(optPanelX + panelW - sidePad - plusW, musicSliderY, plusW, btnH);
  sfxMinusBtn   = new DwellTarget(optPanelX + sidePad, sfxSliderY, minusW, btnH);
  sfxPlusBtn    = new DwellTarget(optPanelX + panelW - sidePad - plusW, sfxSliderY, plusW, btnH);

  float rectBtnH = height * 0.07;
  float cancelW = (cancelImg != null) ? rectBtnH * (cancelImg.width / (float) cancelImg.height) : width * 0.16;
  float saveW   = (saveImg   != null) ? rectBtnH * (saveImg.width   / (float) saveImg.height)   : width * 0.16;

  float btnY = optPanelY + panelH + panelH * 0.08;

  cancelBtn = new DwellTarget(optPanelX, btnY, cancelW, rectBtnH);
  saveBtn = new DwellTarget(optPanelX + panelW - saveW, btnY, saveW, rectBtnH);
}

void drawOptions() {
  drawSceneBackdrop();
  drawTreesAndCat();

  if (optionsPanelImg == null) return;

  image(optionsPanelImg, optPanelX, optPanelY, optPanelW, optPanelH);

  fill(HUD_BLACK);
  textFont(uiFont);
  textAlign(LEFT, TOP);
  textSize(optLabelH * 0.7);
  text("MUSIC VOLUME", optPanelX + optPanelW * 0.06, optMusicLabelY);
  text("SFX VOLUME", optPanelX + optPanelW * 0.06, optSfxLabelY);

  drawVolumeSlider(musicMinusBtn, musicPlusBtn, getMusicVolume());
  drawVolumeSlider(sfxMinusBtn, sfxPlusBtn, getSFXVolume());

  if (cancelImg != null) image(cancelImg, cancelBtn.x, cancelBtn.y, cancelBtn.w, cancelBtn.h);
  if (saveImg != null) image(saveImg, saveBtn.x, saveBtn.y, saveBtn.w, saveBtn.h);

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

void drawVolumeSlider(DwellTarget minusBtn, DwellTarget plusBtn, float value) {
  float trackX = minusBtn.x + minusBtn.w + 10;
  float trackW = plusBtn.x - trackX - 10;
  float trackY = minusBtn.y;
  float trackH = minusBtn.h;

  if (scaleImg != null) {
    image(scaleImg, trackX, trackY, trackW, trackH);
  }

  float fillInsetX = trackW * 0.05;
  float fillInsetY = trackH * 0.18;

  float fillX = trackX + fillInsetX;
  float fillY = trackY + fillInsetY;
  float fillMaxW = trackW - fillInsetX * 2;
  float fillH = trackH - fillInsetY * 2;

  noStroke();
  fill(200, 40, 70);
  rect(fillX, fillY, fillMaxW * value, fillH);

  if (minusImg != null) image(minusImg, minusBtn.x, minusBtn.y, minusBtn.w, minusBtn.h);
  if (plusImg != null) image(plusImg, plusBtn.x, plusBtn.y, plusBtn.w, plusBtn.h);
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
}

void optionsMouseReleased() {
}