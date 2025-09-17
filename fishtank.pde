//import apwidgets.*;

//APMediaPlayer player;
Fish p;
Rest r;
int scount;

void setup() {
  size(1300, 600);
  //noCursor();
  //player = new APMediaPlayer(this);
  //player.setMediaFile("130bpm.mp3");
  //player.start(); //start play back
  //player.setLooping(false); 
  //player.setVolume(1.0, 1.0); 
  background(140, 180, 255);
  p = new Fish(true);
  r = new Rest(p, 500);
  smooth();
  mouseX = 399;
  mouseY = 300;
  scount = 300;
  frameRate(30);
}

void draw() {
  background(140, 180, 255);
  if (!r.gameover) {

    p.draw();
    p.move(0, 0, 0, 1);

    r.draw();

    if (!r.smallerav) {
      fill(250, 100, 100);
      textSize(48);
      if(scount%30 < 15){
      text("¡SOBREVIVE! "+int(scount/30), 290, 100);
      }
      scount--;
      
      if (scount <= 0) {
       r.gameover = true;
       r.dots = new ArrayList(); 
      }
    }
  }
  else {
    fill(250, 100, 100);
    textSize(48);
    if (r.dots.size() == 0) {
      text("¡GANASTE!", 290, 300);
    }
    else {
      text("PERDISTE :(", 290, 300);
    }

    if (mousePressed) {
      setup();
    }
  }
}

void mouseClicked() {
  if (r.gameover) {
    setup();
  }
}

/*public void onDestroy() {
 
 super.onDestroy(); //call onDestroy on super class
 if (player!=null) { //must be checked because or else crash when return from landscape mode
 player.release(); //release the player
 }
 }*/