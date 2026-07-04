DwellTarget musicMinusBtn, musicPlusBtn, sfxMinusBtn, sfxPlusBtn, cancelBtn, saveBtn;
final float VOLUME_STEP = 0.1;

PImage optionsPanelImg, cancelImg, saveImg, minusImg, plusImg, scaleImg;

void loadOptionsAssets() {
  optionsPanelImg = loadImage("options-wrapper.png");
  cancelImg = loadImage("cancel.png");
  saveImg = loadImage("save.png");
  minusImg = loadImage("minus.png");
  plusImg = loadImage("plus.png");
  scaleImg = loadImage("scale.png");
}

void drawOptions() {
  drawSceneBackdrop();
  drawTreesAndCat();

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

  float panelX = width / 2 - panelW / 2;
  float panelY = height * 0.16;

  image(optionsPanelImg, panelX, panelY, panelW, panelH);

  float headerRatio = 0.14;
  float bodyTopPad = 0.06;
  float bodyBottomPad = 0.06;

  float bodyTop = panelY + panelH * (headerRatio + bodyTopPad);
  float bodyBottom = panelY + panelH * (1 - bodyBottomPad);
  float bodyH = bodyBottom - bodyTop;

  // cada linha (label + slider) ocupa metade do corpo
  float rowH = bodyH / 2;
  float labelH = rowH * 0.35;   // espaço reservado para "MUSIC VOLUME" / "SFX VOLUME"
  float sliderH = rowH * 0.55;  // espaço reservado para a barra + botões

  float musicLabelY = bodyTop;
  float musicSliderY = musicLabelY + labelH;

  float sfxLabelY = bodyTop + rowH;
  float sfxSliderY = sfxLabelY + labelH;

  float sidePad = panelW * 0.06;
  float btnH = height * 0.07;
  float minusW = (minusImg != null) ? btnH * (minusImg.width / (float) minusImg.height) : btnH;
  float plusW  = (plusImg  != null) ? btnH * (plusImg.width  / (float) plusImg.height)  : btnH;

  musicMinusBtn = new DwellTarget(panelX + sidePad, musicSliderY, minusW, btnH);
  musicPlusBtn  = new DwellTarget(panelX + panelW - sidePad - plusW, musicSliderY, plusW, btnH);
  sfxMinusBtn   = new DwellTarget(panelX + sidePad, sfxSliderY, minusW, btnH);
  sfxPlusBtn    = new DwellTarget(panelX + panelW - sidePad - plusW, sfxSliderY, plusW, btnH);

  fill(HUD_BLACK);
  textFont(uiFont);
  textAlign(LEFT, TOP);
  textSize(labelH * 0.7);
  text("MUSIC VOLUME", panelX + sidePad, musicLabelY);
  text("SFX VOLUME", panelX + sidePad, sfxLabelY);

  drawVolumeSlider(musicMinusBtn, musicPlusBtn, getMusicVolume());
  drawVolumeSlider(sfxMinusBtn, sfxPlusBtn, getSFXVolume());

  float rectBtnH = height * 0.07;
  float cancelW = (cancelImg != null) ? rectBtnH * (cancelImg.width / (float) cancelImg.height) : width * 0.16;
  float saveW   = (saveImg   != null) ? rectBtnH * (saveImg.width   / (float) saveImg.height)   : width * 0.16;

  float btnY = panelY + panelH + panelH * 0.08;

  cancelBtn = new DwellTarget(panelX, btnY, cancelW, rectBtnH);
  saveBtn = new DwellTarget(panelX + panelW - saveW, btnY, saveW, rectBtnH);

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