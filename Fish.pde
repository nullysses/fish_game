class Fish {
  int vr;
  PVector pos;
  PVector dir;
  PVector t1;
  PVector t2;
  PVector t3;
  int tam;
  boolean prin;
  boolean alive;
  PVector href;
  float finPhase;
  Fish chase_target;
  Fish flee_target;
  int boost_frames;
  int boost_cooldown_frames;
  int boost_duration_frames;
  int boost_recharge_frames;

  Fish(boolean p) {
    vr = 0;
    prin = p;
    pos = prin?new PVector(width/2, height/2):new PVector(random(width), random(height));
    tam = prin?8:int(random(5, 12));
    float s = random(0, TWO_PI);
    dir = new PVector(cos(s), sin(s));
    t1 = new PVector(-1, 1);
    t2 = new PVector(-1, -1);
    t3 = new PVector(1, -1);
    href = new PVector(1, 0);
    alive = true;
    finPhase = random(TWO_PI);
    chase_target = null;
    flee_target = null;
    boost_frames = 0;
    boost_cooldown_frames = 0;
    boost_duration_frames = 30;
    boost_recharge_frames = 150;
  }

  PVector turn(PVector or, float angle) {
    PVector nd = new PVector(0, 0);
    nd.x = or.x*cos(angle)+or.y*sin(angle);
    nd.y = or.x*(-sin(angle))+or.y*cos(angle);
    return nd;
  }

  public void draw() {
    if (vr >= 8) {
      tam = tam + 4;
      vr = 0;
    }
    int body = prin ? color(255, 135, 105) : color(105, 220, 135);
    int belly = prin ? color(255, 205, 175) : color(190, 255, 185);
    int fin = prin ? color(230, 90, 80) : color(65, 175, 105);
    float flap = sin(frameCount * 0.24 + finPhase);
    float tailFlap = flap * tam * 0.38;
    float topFinFlap = flap * tam * 0.28;
    float bottomFinFlap = -flap * tam * 0.24;

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir.heading());

    noStroke();
    fill(fin, 190);
    triangle(-tam*1.1, 0, -tam*2.3, -tam*1.0 + tailFlap, -tam*2.0, tam*0.1);
    triangle(-tam*1.1, 0, -tam*2.3, tam*1.0 + tailFlap, -tam*2.0, -tam*0.1);

    fill(body);
    ellipse(0, 0, tam*3.1, tam*1.55);

    fill(belly, 170);
    ellipse(tam*0.25, tam*0.3, tam*2.0, tam*0.65);

    fill(fin, 180);
    triangle(-tam*0.82, -tam*0.54, -tam*0.18 + topFinFlap, -tam*1.18, tam*0.28, -tam*0.38);
    triangle(-tam*0.18, tam*0.45, tam*0.82 + bottomFinFlap, tam*1.18, tam*0.55, tam*0.08);

    stroke(255, 255, 255, 75);
    strokeWeight(max(1, tam*0.08));
    line(-tam*0.7, -tam*0.35, tam*0.55, -tam*0.42);
    line(-tam*0.85, -tam*0.1, tam*0.75, -tam*0.12);

    stroke(80, 60, 55, 120);
    strokeWeight(max(1, tam*0.07));
    noFill();
    arc(tam*0.75, 0, tam*0.45, tam*0.95, -HALF_PI, HALF_PI);

    noStroke();
    fill(255);
    ellipse(tam*1.0, -tam*0.28, tam*0.42, tam*0.42);
    fill(25);
    ellipse(tam*1.08, -tam*0.28, tam*0.18, tam*0.18);

    popMatrix();
  }

  public void move(float x, float y, int t, float acc) {


    if (prin) {
      dir.x = pos.x;
      dir.y = pos.y;

      dir = new PVector(mouseX, mouseY);


      dir.sub(pos);

      float n = dir.mag();
      dir.normalize();

      dir.mult(n/6);
      pos.add(dir);

      dir.normalize();
    }
    else {
      updateBoost();
      float speed = acc;
      if (boost_frames > 0) {
        speed *= 2;
      }

      PVector target = new PVector(x, y);
      PVector desired;

      if (t <= tam) {
        desired = target.sub(pos);
      }
      else {
        desired = PVector.sub(pos, target);
      }

      if (desired.mag() > 0) {
        desired.normalize();
        desired.mult(0.35);

        PVector forward = dir.copy();
        forward.mult(0.65);
        desired.add(forward);
        desired.normalize();

        float turn_angle = atan2(dir.x*desired.y-dir.y*desired.x, dir.x*desired.x+dir.y*desired.y);
        if (abs(turn_angle) > PI/90) {
          float max_turn = min(PI/8, PI/36*speed);
          turn_angle = constrain(turn_angle, -max_turn, max_turn);
          float new_heading = dir.heading()+turn_angle;
          dir = new PVector(cos(new_heading), sin(new_heading));
        }
      }

      dir.mult(speed);
      pos.x = (pos.x+dir.x)%width;
      if (pos.x <= 0) {
        pos.x = width-tam*2;
      }
      pos.y = (pos.y+dir.y)%height;
      if (pos.y <= 0) {
        pos.y = height-tam*2;
      }

      dir.normalize();
    }
  }

  void tryBoost() {
    if (!prin && boost_frames == 0 && boost_cooldown_frames == 0) {
      boost_frames = boost_duration_frames;
      boost_cooldown_frames = boost_recharge_frames;
    }
  }

  void updateBoost() {
    if (boost_frames > 0) {
      boost_frames--;
    }
    else if (boost_cooldown_frames > 0) {
      boost_cooldown_frames--;
    }
  }
}
