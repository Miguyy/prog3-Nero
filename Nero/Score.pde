JSONArray scoresArr;
DwellTarget scoreMenuButton;
PImage scorePanelImg, menuBtnImg;

void loadScores() {
  scorePanelImg = loadImage("scores.png");
  menuBtnImg = loadImage("menu.png");

  scoresArr = loadJSONArray("scores.json");
  if (scoresArr == null) scoresArr = new JSONArray();

  float btnW = width * 0.18;
  float btnH = height * 0.06;
  scoreMenuButton = new DwellTarget(width / 2 - btnW / 2, height * 0.82, btnW, btnH);
}

// Called once from Nero.pde's changeState() when entering LOSE -- the only
// point a run definitively ends (Win continues on to the next level).
void submitScore(int finalScore, int finalLevel) {
  JSONObject entry = new JSONObject();
  entry.setInt("score", finalScore);
  entry.setInt("level", finalLevel);
  scoresArr.append(entry);

  sortScoresDescending();
  while (scoresArr.size() > 10) {
    scoresArr.remove(scoresArr.size() - 1);
  }

  saveJSONArray(scoresArr, dataPath("scores.json"));
}

void sortScoresDescending() {
  for (int i = 0; i < scoresArr.size() - 1; i++) {
    for (int j = 0; j < scoresArr.size() - 1 - i; j++) {
      if (scoresArr.getJSONObject(j).getInt("score") < scoresArr.getJSONObject(j + 1).getInt("score")) {
        JSONObject tmp = scoresArr.getJSONObject(j);
        scoresArr.setJSONObject(j, scoresArr.getJSONObject(j + 1));
        scoresArr.setJSONObject(j + 1, tmp);
      }
    }
  }
}

void drawScore() {
  drawSceneBackdrop();
  drawTreesAndCat();

  if (scorePanelImg == null) return;

  float maxW = width * 0.3;
  float maxH = height * 0.5;

  float imgRatio = scorePanelImg.width / (float) scorePanelImg.height;

  float panelW = maxW;
  float panelH = panelW / imgRatio;

  if (panelH > maxH) {
    panelH = maxH;
    panelW = panelH * imgRatio;
  }

  float panelX = width / 2 - panelW / 2;
  float panelY = height * 0.16;

  image(scorePanelImg, panelX, panelY, panelW, panelH);

  float headerRatio = 0.13;
  float bodyTopPad  = 0.02;
  float bodyBottomPad = 0.03;

  float bodyTop = panelY + panelH * (headerRatio + bodyTopPad);
  float bodyBottom = panelY + panelH * (1 - bodyBottomPad);
  float bodyH = bodyBottom - bodyTop;

  int rowCount = min(scoresArr.size(), 5);
  float rowH = (rowCount > 0) ? bodyH / rowCount : bodyH;

  float sidePad = panelW * 0.035;

  textFont(uiFont);
  textSize(panelH * 0.07);

  for (int i = 0; i < rowCount; i++) {
    float ry = bodyTop + i * rowH;

    color rowColor = (i % 2 == 0) ? color(94, 195, 219) : color(107, 122, 173);
    noStroke();
    fill(rowColor);
    rect(panelX + sidePad, ry, panelW - sidePad * 2, rowH);

    fill(30, 20, 40);
    textAlign(LEFT, CENTER);
    int s = scoresArr.getJSONObject(i).getInt("score");
    text(nf(s, 1), panelX + sidePad + panelW * 0.05, ry + rowH * 0.45);
  }

  float menuBtnDrawnW = (menuBtnImg != null) ? menuBtnImg.width : scoreMenuButton.w;
  scoreMenuButton.x = panelX - (scoreMenuButton.w - menuBtnDrawnW) / 2;
  scoreMenuButton.y = panelY + panelH + panelH * 0.06;

  drawMenuButton(scoreMenuButton, menuBtnImg);

  PVector p = getHandScreenPos();
  boolean selected = scoreMenuButton.update(p, isHandPointing());
  if (selected) onScoreMenuButtonSelected();
}

void onScoreMenuButtonSelected() {
  playSFX("botoes.mp3");
  changeState(MENU);
}

void scoreMousePressed() {
  if (scoreMenuButton.contains(new PVector(mouseX, mouseY))) {
    onScoreMenuButtonSelected();
  }
}
