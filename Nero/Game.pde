import java.awt.Rectangle;

color bgColor = color(40, 28, 51);

PImage skyImg, floorImg, cloudsImg, kinectPreviewImg;
ScrollingImage clouds;

PImage[] bubbleImgs = new PImage[4];
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

float obstacleSpeed = 20;
float spawnInterval = 2;
float spawnTimer = 0;

// topRowY is no longer a fixed guess -- it's computed in loadBackground()
// from the player's actual crouching height, so the top bubbles reliably
// threaten a standing player and can only be dodged by ducking.
float topRowY;
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
final float MIN_INTERVAL = 30;

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

  // Top bubble's bottom edge is placed relative to the crouching player's
  // real (alpha-scanned) head height -- see Player.crouchHeadTopY() and
  // dodgeMargin in spawnObstacle() -- so it reliably overlaps a standing
  // player's hitbox while still clearing a crouching one.
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
  spawnInterval = 70;   // was 150 -- roughly doubles bubbles per level
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

// Randomized instead of a fixed bottom/top/bottom/top alternation: each
// spawn independently rolls both the sprite and the row, so the sequence
// the player sees is unpredictable rather than a repeating pattern.
void spawnObstacle() {
  int imgIndex = int(random(bubbleImgs.length));
  PImage chosenImg = bubbleImgs[imgIndex];
  
  float y;
  if (random(1) < 0.5) {
    y = bottomRowY;
  } else {
    float crouchHeadTopY = player.crouchHeadTopY();

    // Bottom edge of the obstacle sits dodgeMargin px *below* the crouching
    // head, inside the gap left by getHitbox()'s 20% vertical inset -- deep
    // enough to overlap a standing player's hitbox but still short of a
    // crouching player's (smaller) hitbox. See getHitbox() for the inset.
    float dodgeMargin = -18;

    y = crouchHeadTopY - dodgeMargin - chosenImg.height;
  }

  obstacles.add(new Obstacle(chosenImg, width, y, obstacleSpeed));
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

// Left arm restored -- it was never actually the cause of the Menu/Score/
// Options flicker (see the fix in Kinect.pde), so no reason to hide it here.
void drawSkeletonSilhouette(float bx, float by, float bw, float bh) {
  PVector[] joints = getSkeletonJointsNormalized();
  noFill();

  stroke(HUD_LIGHTPINK, 220);
  strokeWeight(10);
  drawSkeletonBone(joints, JOINT_HEAD, JOINT_SHOULDER_CENTER, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_CENTER, JOINT_HIP_CENTER, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_CENTER, JOINT_HAND_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_CENTER, JOINT_HAND_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_HIP_CENTER, JOINT_KNEE_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_HIP_CENTER, JOINT_KNEE_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_KNEE_LEFT, JOINT_FOOT_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_KNEE_RIGHT, JOINT_FOOT_RIGHT, bx, by, bw, bh);

  stroke(HUD_PINK, 240);
  strokeWeight(4);
  drawSkeletonBone(joints, JOINT_HEAD, JOINT_SHOULDER_CENTER, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_CENTER, JOINT_HIP_CENTER, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_LEFT, JOINT_ELBOW_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_ELBOW_LEFT, JOINT_WRIST_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_WRIST_LEFT, JOINT_HAND_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_SHOULDER_RIGHT, JOINT_ELBOW_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_ELBOW_RIGHT, JOINT_WRIST_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_WRIST_RIGHT, JOINT_HAND_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_HIP_LEFT, JOINT_KNEE_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_HIP_RIGHT, JOINT_KNEE_RIGHT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_ANKLE_LEFT, JOINT_FOOT_LEFT, bx, by, bw, bh);
  drawSkeletonBone(joints, JOINT_ANKLE_RIGHT, JOINT_FOOT_RIGHT, bx, by, bw, bh);

  fill(HUD_PINK);
  noStroke();
  drawJointBlob(joints, JOINT_HEAD, bx, by, bw, bh, 18);
  drawJointBlob(joints, JOINT_SHOULDER_CENTER, bx, by, bw, bh, 14);
  drawJointBlob(joints, JOINT_SHOULDER_LEFT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_SHOULDER_RIGHT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_HAND_LEFT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_HAND_RIGHT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_HIP_CENTER, bx, by, bw, bh, 14);
  drawJointBlob(joints, JOINT_HIP_LEFT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_HIP_RIGHT, bx, by, bw, bh, 10);
  drawJointBlob(joints, JOINT_KNEE_LEFT, bx, by, bw, bh, 9);
  drawJointBlob(joints, JOINT_KNEE_RIGHT, bx, by, bw, bh, 9);
  drawJointBlob(joints, JOINT_ANKLE_LEFT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_ANKLE_RIGHT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_FOOT_LEFT, bx, by, bw, bh, 8);
  drawJointBlob(joints, JOINT_FOOT_RIGHT, bx, by, bw, bh, 8);
}

void drawSkeletonBone(PVector[] joints, int a, int b, float bx, float by, float bw, float bh) {
  if (joints[a] == null || joints[b] == null) return;
  float ax = bx + joints[a].x * bw;
  float ay = by + joints[a].y * bh;
  float bx2 = bx + joints[b].x * bw;
  float by2 = by + joints[b].y * bh;
  line(ax, ay, bx2, by2);
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
    float inset = img.width * 0.0148;
    return new Rectangle(
      (int)(x + inset),
      (int)(y + inset),
      (int)(img.width - 2 * inset),
      (int)(img.height - 2 * inset)
      );
  }
}

// Scans an image's alpha channel for the first/last row containing a
// non-transparent pixel. Used to find a sprite's real visible extent when
// its canvas has transparent padding that raw img.height can't account for.
int[] opaqueVerticalBounds(PImage img) {
  img.loadPixels();
  int top = -1;
  int bottom = -1;
  for (int y = 0; y < img.height; y++) {
    int rowStart = y * img.width;
    for (int x = 0; x < img.width; x++) {
      if (alpha(img.pixels[rowStart + x]) > 10) {
        if (top == -1) top = y;
        bottom = y;
        break;
      }
    }
  }
  if (top == -1) {
    top = 0;
    bottom = img.height - 1;
  }
  return new int[]{ top, bottom };
}

class Player {
  PImage defaultImg, crouchImg;
  float x;
  float y;
  float velY = 0;
  boolean jumping = false;
  boolean crouching = false;
  float scale = 0.2;

  // default.png and crouch.png share the same 928x928 canvas -- the crouch
  // pose is drawn smaller and lower inside it rather than on a shorter
  // canvas. Raw img.height is therefore identical for both and can't be used
  // to tell how tall the character actually looks, so we scan each sprite's
  // alpha channel once at load time for its real visible top/height instead.
  float defaultVisTop, defaultVisHeight;
  float crouchVisTop, crouchVisHeight;

  Player(float x) {
    this.x = x;
    this.y = groundY;
  }

  void load() {
    defaultImg = loadImage("default.png");
    crouchImg = loadImage("crouch.png");

    int[] db = opaqueVerticalBounds(defaultImg);
    defaultVisTop = db[0];
    defaultVisHeight = db[1] - db[0] + 1;

    int[] cb = opaqueVerticalBounds(crouchImg);
    crouchVisTop = cb[0];
    crouchVisHeight = cb[1] - cb[0] + 1;
  }

  // Real (screen-space) Y of the top of the crouching character's head --
  // used by spawnObstacle() to place top-row obstacles relative to where the
  // head actually is, not the padded canvas.
  float crouchHeadTopY() {
    float h = crouchImg.height * scale;
    return (groundY - h) + crouchVisTop * scale;
  }

  void update() {
    crouching = isCrouching() && !jumping;

    if (isJumpTriggered() && !jumping) {
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
    float visTop = (crouching ? crouchVisTop : defaultVisTop) * scale;
    float visH = (crouching ? crouchVisHeight : defaultVisHeight) * scale;
    float insetX = w * 0.2;
    float insetY = visH * 0.2;
    return new Rectangle(
      (int)(x + insetX),
      (int)(y - h + visTop + insetY),
      (int)(w - 2 * insetX),
      (int)(visH - 2 * insetY)
    );
  }
}