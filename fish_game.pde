import processing.sound.*;

Fish p;
Rest r;
int scount;
ArrayList<Bubble> bubbles;
int bubbleTimer;
SoundEffects sounds;
int fish_population_size = 90;
float fish_top_speed_size_factor = 0.2;
float fish_boost_regeneration_size_factor = 10;
float fish_boost_policy_threshold = 0.5;
float fish_boost_policy_mutation_rate = 0.08;
float fish_boost_policy_mutation_amount = 0.25;
boolean fish_boost_policy_debug = false;
boolean fish_training_mode = true;
int fish_training_generation_frames = 30 * 30;
int fish_training_top_k = 12;
float fish_training_survival_weight = 0.02;
float fish_training_growth_weight = 25;
float fish_training_prey_weight = 12;
float fish_training_boost_penalty = 3;

void setup() {
  size(1280, 720);
  background(140, 180, 255);
  p = new Fish(true);
  r = new Rest(p, fish_population_size);
  bubbles = new ArrayList<Bubble>();
  bubbleTimer = 1 * 30;
  sounds = new SoundEffects(this);
  smooth();
  scount = 300;
  frameRate(30);
}

void draw() {
  background(140, 180, 255);

  if (fish_training_mode) {
    drawTraining();
    return;
  }

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
  if (!fish_training_mode && (r.gamestate == 0 || r.gamestate == 2)) {
    setup();
  }
}

void keyPressed() {
  if (key == 'b' || key == 'B') {
    fish_boost_policy_debug = !fish_boost_policy_debug;
  }
  if (key == 't' || key == 'T') {
    fish_training_mode = !fish_training_mode;
    if (fish_training_mode) {
      p = new Fish(true);
      r = new Rest(p, fish_population_size);
      r.startTraining();
    }
    else {
      setup();
    }
  }
}

void drawTraining() {
  drawBubbles();
  p.draw();
  r.draw();
  r.drawTrainingOverlay();
  r.advanceTraining();
}
