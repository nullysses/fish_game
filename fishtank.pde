//import apwidgets.*;

//APMediaPlayer player;
Fish p;
Rest r;
int scount;

void setup() {
  size(800, 600);
  //noCursor();
  //player = new APMediaPlayer(this);
  //player.setMediaFile("130bpm.mp3");
  //player.start(); //start play back
  //player.setLooping(false); 
  //player.setVolume(1.0, 1.0); 
  background(140, 180, 255);
  p = new Fish(true);
  r = new Rest(p, 120);
  //r.gamestate = 0;
  smooth();
  //mouseX = 399;
  //mouseY = 300;
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

void mouseClicked() {
  if (r.gamestate == 0 || r.gamestate ==2) {
    setup();
  }
}
