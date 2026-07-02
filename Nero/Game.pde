color bgColor = color(40, 28, 51);

PImage skyImg, floorImg, cloudsImg;
ScrollingImage clouds;

PImage[] bubbleImgs = new PImage[4];
int nextBubbleIndex = 0;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

float obstacleSpeed = 3;
float spawnInterval = 150;
float spawnTimer = 0;

float topRowY = 750;
float bottomRowY = 900;

void loadBackground() {
    skyImg = loadImage("sky.png");
    floorImg = loadImage("floor.png");
    cloudsImg = loadImage("clouds.png");

    clouds = new ScrollingImage(cloudsImg, 50, 0.8);
    
    bubbleImgs[0] = loadImage("bolhas-1.png");
    bubbleImgs[1] = loadImage("bolhas-2.png");
    bubbleImgs[2] = loadImage("bolhas-3.png");
    bubbleImgs[3] = loadImage("bolhas-4.png");
}

void drawBackground() {
    background(bgColor);
}

void drawGame() {
    drawBackground();

    image(skyImg, 0, 0);

    clouds.update();
    clouds.display();

    updateObstacles();
    drawObstacles();

    image(floorImg, 0, 100);
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
}