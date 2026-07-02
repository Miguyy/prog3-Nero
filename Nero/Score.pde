JSONArray scoresArr;
DwellTarget scoreMenuButton;

void loadScores() {
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

  float panelW = width * 0.3;
  float panelHeaderH = height * 0.06;
  float rowH = height * 0.05;
  int rowCount = min(scoresArr.size(), 10);
  float panelX = width / 2 - panelW / 2;
  float panelY = height * 0.16;
  float panelH = panelHeaderH + rowH * max(rowCount, 1);

  drawPanel(panelX, panelY, panelW, panelH, panelHeaderH);

  fill(255);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("SCORES", panelX + panelW / 2, panelY + panelHeaderH / 2);

  textFont(uiFont);
  for (int i = 0; i < rowCount; i++) {
    float ry = panelY + panelHeaderH + i * rowH;
    color rowColor = (i % 2 == 0) ? color(94, 195, 219) : color(107, 122, 173);
    noStroke();
    fill(rowColor);
    rect(panelX, ry, panelW, rowH);

    fill(30, 20, 40);
    textAlign(LEFT, CENTER);
    int s = scoresArr.getJSONObject(i).getInt("score");
    text(nf(s, 1), panelX + 20, ry + rowH / 2);
  }

  PVector p = getHandScreenPos();
  boolean selected = scoreMenuButton.update(p, isHandPointing());
  drawPillButton(scoreMenuButton, "MENU");
  if (selected) changeState(MENU);
}

void scoreMousePressed() {
  if (scoreMenuButton.contains(new PVector(mouseX, mouseY))) {
    changeState(MENU);
  }
}
