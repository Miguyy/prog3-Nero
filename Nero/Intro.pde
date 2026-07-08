final int T_HOLD_START     = 200;
final int T_SKY_SLIDE_END  = T_HOLD_START + 3500;
final int T_LOGO_FADE_IN   = 1000;
final int T_LOGO_HOLD      = 1500;
final int T_INTRO_SCREEN_END = T_SKY_SLIDE_END + T_LOGO_FADE_IN + T_LOGO_HOLD;

PImage introLogoImg;

void loadIntroAssets() {
  introLogoImg = loadImage("logo.png");
}

void drawIntro() {
  int t = millis() - stateEnterMillis;

  if (t < T_HOLD_START) {
    background(HUD_BLACK);
    image(skyImg, 0, 0);
    drawCloudsSplitting(0, 50, 0, width, 0);

  } else if (t < T_SKY_SLIDE_END) {
    background(HUD_BLACK);

    int tSlide = t - T_HOLD_START;
    float p = constrain(tSlide / float(T_SKY_SLIDE_END - T_HOLD_START), 0, 1);
    float skyDy = lerp(0, height + skyImg.height, p);

    int cloudDelay = 200;
    float pClouds = constrain((tSlide - cloudDelay) / float(T_SKY_SLIDE_END - T_HOLD_START - cloudDelay), 0, 1);
    float cloudsDy = lerp(0, height + skyImg.height, pClouds);

    image(skyImg, 0, skyDy);
    drawCloudsSplitting(0, 50, pClouds, width, cloudsDy);

  } else if (t < T_INTRO_SCREEN_END) {
    background(HUD_BLACK);

    int tPhase2 = t - T_SKY_SLIDE_END;
    float logoAlpha = (tPhase2 < T_LOGO_FADE_IN)
      ? map(tPhase2, 0, T_LOGO_FADE_IN, 0, 255)
      : 255;
    logoAlpha = constrain(logoAlpha, 0, 255);

    if (introLogoImg != null) {
      tint(255, logoAlpha);
      image(introLogoImg, width / 2 - introLogoImg.width / 2, height / 2 - introLogoImg.height / 2);
      noTint();
    }

  } else {
    changeState(MENU);
  }
}