import java.awt.Rectangle;

color bgColor = color(40, 28, 51);

PImage skyImg, floorImg, cloudsImg;
ScrollingImage clouds;

PImage[] bubbleImgs = new PImage[4];
int nextBubbleIndex = 0;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

float obstacleSpeed = 3;
float spawnInterval = 150;
float spawnTimer = 0;

<<<<<<< Updated upstream
float topRowY = 750;
=======
float topRowY;
>>>>>>> Stashed changes
float bottomRowY = 900;

// Player + level state
PImage playerIdleImg, playerJumpImg, playerCrouchImg;
Player player;
float groundY;

final float JUMP_VELOCITY = -18;
final float GRAVITY = 0.9;

int levelTimer = 0;
final int LEVEL_DURATION_FRAMES = 60 * 45; // 45s survival to win -- placeholder, tune via playtest
final float SPEED_GROWTH = 1.15;
final float INTERVAL_SHRINK = 0.9;
final float MAX_SPEED = 12;
final float MIN_INTERVAL = 45;

// Kinect preview HUD box (top-left)
final color HUD_BODY = #FFE4CE;
final color HUD_PINK = #EC80B4;
float hudX = 20, hudY = 20, hudW = 260, hudH = 200, hudHeaderH = 34;

void loadBackground() {
  skyImg = loadImage("sky.png");
  floorImg = loadImage("floor.png");
  cloudsImg = loadImage("clouds.png");

  clouds = new ScrollingImage(cloudsImg, 50, 0.8);

  bubbleImgs[0] = loadImage("bolhas-1.png");
  bubbleImgs[1] = loadImage("bolhas-2.png");
  bubbleImgs[2] = loadImage("bolhas-3.png");
  bubbleImgs[3] = loadImage("bolhas-4.png");

<<<<<<< Updated upstream
  playerIdleImg = loadImage("default.png");
  playerCrouchImg = loadImage("crouch.png");
  // playerJumpImg = loadImage("player_jump.png"); // TODO: uncomment once player_jump.png is added to data/

  groundY = bottomRowY + 90;
  player = new Player(width * 0.15);
=======
  groundY = bottomRowY + 90;
  player = new Player(width * 0.08);
  player.load();
>>>>>>> Stashed changes
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
  obstacleSpeed = 3;
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
<<<<<<< Updated upstream
  PImage chosenImg = bubbleImgs[nextBubbleIndex];
  float y = (nextBubbleIndex % 2 == 0) ? bottomRowY : topRowY;
=======
  int imgIndex = int(random(bubbleImgs.length));
  PImage chosenImg = bubbleImgs[imgIndex];
  
  float y;
  if (random(1) < 0.5) {
    y = bottomRowY;
  } else {
    float crouchHeadTopY = player.crouchHeadWorldY();

    // Clearance kept between the obstacle's bottom edge and the crouching
    // head, so a duck reliably clears it while a standing player still
    // gets hit (the gap between the two head heights is only ~17px at
    // this sprite scale, so this margin has little room to grow).
    float dodgeMargin = 8;

    y = crouchHeadTopY - chosenImg.height - dodgeMargin;
  }
>>>>>>> Stashed changes

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
  noStroke();
  fill(HUD_BODY);
  rect(hudX, hudY + hudHeaderH, hudW, hudH - hudHeaderH);

  fill(HUD_PINK);
  rect(hudX, hudY, hudW, hudHeaderH);

  noFill();
  stroke(HUD_PINK);
  strokeWeight(3);
  rect(hudX, hudY, hudW, hudH);

  noStroke();
  fill(0);
  textFont(uiFont);
  textAlign(CENTER, CENTER);
  text("IT'S YOU!", hudX + hudW / 2, hudY + hudHeaderH / 2);

  drawSkeletonSilhouette(hudX, hudY + hudHeaderH, hudW, hudH - hudHeaderH);
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
  fill(255);
  textAlign(RIGHT, TOP);
  text("LEVEL " + level + "   " + score + " PTS", width - 20, 20);
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
  float x;
  float y;
  float velY = 0;
  boolean jumping = false;
  boolean crouching = false;

  // default.png and crouch.png are both 928x928 canvases -- the crouch pose
  // is baked in as extra transparent padding at the top, not a shorter
  // image. These are the topmost opaque pixel row (in source-image
  // coordinates) for each sprite, measured directly from the art, so the
  // hitbox and top-obstacle spawn math track where the head actually is
  // instead of assuming crouchImg is literally shorter than defaultImg.
  final float STANDING_HEAD_OFFSET = 87;
  final float CROUCHING_HEAD_OFFSET = 174;

  Player(float x) {
    this.x = x;
    this.y = groundY;
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
    // player_jump.png hasn't been delivered yet -- fall back to the idle pose
    // rather than NPE-ing every frame while jumping.
    if (jumping) return (playerJumpImg != null) ? playerJumpImg : playerIdleImg;
    if (crouching) return playerCrouchImg;
    return playerIdleImg;
  }

  void display() {
    PImage s = currentSprite();
    image(s, x, y - s.height);
  }

  float headOffset() {
    return crouching ? CROUCHING_HEAD_OFFSET : STANDING_HEAD_OFFSET;
  }

  // World-space y of this player's head top while crouching, as if standing
  // on the ground (not jumping). Used by spawnObstacle() to place top-row
  // obstacles relative to where a duck actually clears.
  float crouchHeadWorldY() {
    float h = crouchImg.height * scale;
    return (groundY - h) + CROUCHING_HEAD_OFFSET * scale;
  }

  Rectangle getHitbox() {
    PImage s = currentSprite();
<<<<<<< Updated upstream
    float inset = s.width * 0.2;
    return new Rectangle(
      (int)(x + inset),
      (int)(y - s.height + inset),
      (int)(s.width - 2 * inset),
      (int)(s.height - 2 * inset)
      );
=======
    float w = s.width * scale;
    float h = s.height * scale;
    float insetX = w * 0.2;
    float insetBottom = h * 0.2;
    float top = (y - h) + headOffset() * scale;
    float bottom = y - insetBottom;
    return new Rectangle(
      (int)(x + insetX),
      (int)top,
      (int)(w - 2 * insetX),
      (int)(bottom - top)
    );
>>>>>>> Stashed changes
  }
}
