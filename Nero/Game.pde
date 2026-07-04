import java.awt.Rectangle;

color bgColor = color(40, 28, 51);

PImage skyImg, floorImg, cloudsImg, kinectPreviewImg;
ScrollingImage clouds;

PImage[] bubbleImgs = new PImage[4];
int nextBubbleIndex = 0;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

float obstacleSpeed = 20;
float spawnInterval = 2;
float spawnTimer = 0;

float topRowY = 750;
float bottomRowY = 900;

Player player;
float groundY;

final float JUMP_VELOCITY = -18;
final float GRAVITY = 0.9;

int levelTimer = 0;
final int LEVEL_DURATION_FRAMES = 60 * 45;
final float SPEED_GROWTH = 1.15;
final float INTERVAL_SHRINK = 0.9;
final float MAX_SPEED = 12;
final float MIN_INTERVAL = 45;

// Kinect preview HUD box (top-left)
float hudX, hudY, hudW, hudH, hudHeaderH = 34;
float hudMarginX, hudMarginY;

void loadBackground() {
  hudMarginX = width * 0.04;
  hudMarginY = height * 0.035;

  hudX = hudMarginX;
  hudY = hudMarginY;
  hudW = width * 0.30;
  hudH = height * 0.42;

  skyImg = loadImage("sky.png");
  floorImg = loadImage("floor.png");
  cloudsImg = loadImage("clouds.png");
  kinectPreviewImg = loadImage("kinect.png");

  clouds = new ScrollingImage(cloudsImg, 50, 0.8);

  bubbleImgs[0] = loadImage("bolhas-1.png");
  bubbleImgs[1] = loadImage("bolhas-2.png");
  bubbleImgs[2] = loadImage("bolhas-3.png");
  bubbleImgs[3] = loadImage("bolhas-4.png");

  groundY = bottomRowY + 90;
  player = new Player(width * 0.08);
  player.load();
}

void drawBackground() {
  background(bgColor);
}

// Sky + parallax clouds only -- shared atomic piece, reused directly by drawGame()
// and via drawSceneBackdrop() by Menu/Score/Options/Win/Lose.
void drawSkyAndClouds() {
  drawBackground();
  image(skyImg, 0, 0);
  clouds.update();
  clouds.display();
}

void drawFloor() {
  image(floorImg, 0, 100);
}

// Full static backdrop (no obstacles) used by every non-gameplay screen.
void drawSceneBackdrop() {
  drawSkyAndClouds();
  drawFloor();
}

void drawGame() {
  drawSkyAndClouds();

  updateObstacles();
  drawObstacles();

  drawFloor();

  player.update();
  player.display();

  if (checkCollisions(player)) {
    changeState(LOSE);
    return;
  }

  updateGameProgress();

  drawKinectPreview();
  drawGameHUD();
}

void updateGameProgress() {
  levelTimer++;
  score += 5 * level;
  if (levelTimer >= LEVEL_DURATION_FRAMES) {
    changeState(WIN);
  }
}

void startNextLevel() {
  level++;
  obstacleSpeed = min(obstacleSpeed * SPEED_GROWTH, MAX_SPEED);
  spawnInterval = max(spawnInterval * INTERVAL_SHRINK, MIN_INTERVAL);
  obstacles.clear();
  spawnTimer = 0;
  levelTimer = 0;
}

void resetGameFull() {
  level = 1;
  score = 0;
  obstacleSpeed = 20;
  spawnInterval = 150;
  obstacles.clear();
  spawnTimer = 0;
  levelTimer = 0;
  if (player != null) {
    player.y = groundY;
    player.jumping = false;
    player.crouching = false;
    player.velY = 0;
  }
}

void updateObstacles() {
  spawnTimer++;
  if (spawnTimer >= spawnInterval) {
    spawnObstacle();
    spawnTimer = 0;
  }

  for (int i = obstacles.size() - 1; i >= 0; i--) {
    Obstacle o = obstacles.get(i);
    o.update();
    if (o.offScreen()) {
      obstacles.remove(i);
    }
  }
}

void drawObstacles() {
  for (Obstacle o : obstacles) {
    o.display();
  }
}

void spawnObstacle() {
  PImage chosenImg = bubbleImgs[nextBubbleIndex];
  float y = (nextBubbleIndex % 2 == 0) ? bottomRowY : topRowY;

  obstacles.add(new Obstacle(chosenImg, width, y, obstacleSpeed));
  nextBubbleIndex = (nextBubbleIndex + 1) % 4;
}

boolean checkCollisions(Player p) {
  Rectangle pBox = p.getHitbox();
  for (Obstacle o : obstacles) {
    if (pBox.intersects(o.getHitbox())) return true;
  }
  return false;
}

void drawKinectPreview() {
  if (kinectPreviewImg == null) return;

  float maxW = hudW;
  float maxH = hudH;

  float imgRatio = kinectPreviewImg.width / (float) kinectPreviewImg.height;

  float boxW = maxW;
  float boxH = boxW / imgRatio;

  if (boxH > maxH) {
    boxH = maxH;
    boxW = boxH * imgRatio;
  }

  image(kinectPreviewImg, hudX, hudY, boxW, boxH);

  float headerRatio = 0.13;
  float bodyBottomPad = 0.03;

  float bodyX = hudX;
  float bodyY = hudY + boxH * headerRatio;
  float bodyW = boxW;
  float bodyH = boxH * (1 - headerRatio - bodyBottomPad);

  drawSkeletonSilhouette(bodyX, bodyY, bodyW, bodyH);
}

void drawSkeletonSilhouette(float bx, float by, float bw, float bh) {
  PVector[] joints = getSkeletonJointsNormalized();
  fill(HUD_PINK);
  noStroke();
  drawJointBlob(joints, JOINT_HEAD, bx, by, bw, bh, 14);
  drawJointBlob(joints, JOINT_SHOULDER_CENTER, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_HAND_LEFT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_HAND_RIGHT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_HIP_CENTER, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_KNEE_LEFT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_KNEE_RIGHT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_FOOT_LEFT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_FOOT_RIGHT, bx, by, bw, bh, 8);
}

void drawJointBlob(PVector[] joints, int idx, float bx, float by, float bw, float bh, float size) {
  if (joints[idx] == null) return;
  float px = bx + joints[idx].x * bw;
  float py = by + joints[idx].y * bh;
  ellipse(px, py, size, size);
}

void drawGameHUD() {
  textFont(uiFont);
  textSize(height * 0.035);
  fill(HUD_CREAM);
  textAlign(RIGHT, TOP);
  text("LEVEL " + level + "   " + score + " PTS", width - hudMarginX, hudMarginY);
}

class Scrollable {
  PImage img;
  float x, y, speed;

  Scrollable(PImage img, float x, float y, float speed) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.speed = speed;
  }

  void update() {
    x -= speed;
  }
}

class ScrollingImage extends Scrollable {
  ScrollingImage(PImage img, float y, float speed) {
    super(img, 0, y, speed);
  }

  void update() {
    super.update();
    if (x <= -img.width) x = 0;
  }

  void display() {
    image(img, x, y);
    image(img, x + img.width, y);
  }
}

class Obstacle extends Scrollable {
  Obstacle(PImage img, float x, float y, float speed) {
    super(img, x, y, speed);
  }

  void display() {
    image(img, x, y);
  }

  boolean offScreen() {
    return x < -img.width;
  }

  Rectangle getHitbox() {
    float inset = img.width * 0.15;
    return new Rectangle(
      (int)(x + inset),
      (int)(y + inset),
      (int)(img.width - 2 * inset),
      (int)(img.height - 2 * inset)
      );
  }
}

class Player {
  PImage defaultImg, crouchImg;
  float x;
  float y;
  float velY = 0;
  boolean jumping = false;
  boolean crouching = false;
  float scale = 0.2;

  Player(float x) {
    this.x = x;
    this.y = groundY;
  }

  void load() {
    defaultImg = loadImage("default.png");
    crouchImg = loadImage("crouch.png");
  }

  void update() {
    crouching = isCrouching() && !jumping;

    if (isJumping() && !jumping) {
      jumping = true;
      velY = JUMP_VELOCITY;
    }

    if (jumping) {
      velY += GRAVITY;
      y += velY;
      if (y >= groundY) {
        y = groundY;
        jumping = false;
        velY = 0;
      }
    } else {
      y = groundY;
    }
  }

  PImage currentSprite() {
    if (crouching) return crouchImg;
    return defaultImg;
  }

  void display() {
    PImage s = currentSprite();
    float w = s.width * scale;
    float h = s.height * scale;
    image(s, x, y - h, w, h);
  }

  Rectangle getHitbox() {
    PImage s = currentSprite();
    float w = s.width * scale;
    float h = s.height * scale;
    float inset = w * 0.2;
    return new Rectangle(
      (int)(x + inset),
      (int)(y - h + inset),
      (int)(w - 2 * inset),
      (int)(h - 2 * inset)
    );
  }
}
