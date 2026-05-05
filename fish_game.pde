import processing.sound.*;

Fish p;
Rest r;
int scount;
ArrayList<Bubble> bubbles;
int bubbleTimer;
SoundEffects sounds;
float fish_top_speed_size_factor = 0.2;
float fish_boost_regeneration_size_factor = 10;

void setup() {
  size(1280, 720);
  background(140, 180, 255);
  p = new Fish(true);
  r = new Rest(p, 90);
  bubbles = new ArrayList<Bubble>();
  bubbleTimer = 1 * 30;
  sounds = new SoundEffects(this);
  smooth();
  scount = 300;
  frameRate(30);
}

void draw() {
  background(140, 180, 255);
  switch (r.gamestate) {
  case 0:
    fill(250, 100, 100);
    textSize(48);
    textAlign(CENTER, CENTER);
    text("Click here to start!", width/2, height/2);
    textAlign(LEFT, BASELINE);
    if (mousePressed) {
      r.gamestate = 1;
    }
    break;
  case 1:
    drawBubbles();
    p.draw();
    p.move(0, 0, 0, 1);

    r.draw();

    if (!r.smallerav) {
      fill(250, 100, 100);
      textSize(48);
      if (scount%30 < 15) {
        text("Survive! "+int(scount/30), 290, 100);
      }
      scount--;

      if (scount <= 0) {
        r.gamestate = 2;
        r.dots = new ArrayList();
      }
    }
    break;
  case 2:
    fill(250, 100, 100);
    textSize(48);
    textAlign(CENTER, CENTER);
    if (r.dots.size() == 0) {
      text("You won!", width/2, height/2);
    }
    else {
      text("You lost :(", width/2, height/2);
    }
    textAlign(LEFT, BASELINE);

    if (mousePressed) {
      setup();
    }
    break;
  }
}

void drawBubbles() {
  bubbleTimer--;
  if (bubbleTimer <= 0) {
    bubbleTimer = 1 * 30;
    if (random(1) < 0.5) {
      addBubbleGroup();
    }
  }

  for (int i = bubbles.size() - 1; i >= 0; i--) {
    Bubble bubble = bubbles.get(i);
    bubble.move();
    bubble.draw();
    if (bubble.offScreen()) {
      bubbles.remove(i);
    }
  }
}

void addBubbleGroup() {
  int amount = int(random(1, 6));
  float startX = random(35, width - 35);
  for (int i = 0; i < amount; i++) {
    bubbles.add(new Bubble(startX + random(-16, 16), height + random(6, 38)));
  }
  sounds.bloop();
}

void mouseClicked() {
  if (r.gamestate == 0 || r.gamestate == 2) {
    setup();
  }
}
