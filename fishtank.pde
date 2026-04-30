
import processing.sound.*;

Fish p;
Rest r;
int scount;
ArrayList<Bubble> bubbles;
int bubbleTimer;
SoundEffects sounds;

void setup() {
  size(800, 600);
  background(140, 180, 255);
  p = new Fish(true);
  r = new Rest(p, 120);
  bubbles = new ArrayList<Bubble>();
  bubbleTimer = 1 * 30;
  sounds = new SoundEffects(this);
  smooth();
  scount = 300;
  frameRate(30);
}

void draw() {
  background(140, 180, 255);
  switch(r.gamestate) {
    case 0:
      fill(250, 100, 100);
      textSize(48);
      text("Click here to start!", 290, 300);
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
        if(scount%30 < 15){
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
      if (r.dots.size() == 0) {
        text("You won!", 290, 300);
      }
      else {
        text("You lost :(", 290, 300);
      }

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
  if (r.gamestate == 0 || r.gamestate ==2) {
    setup();
  }
}
