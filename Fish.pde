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

  Fish(boolean p) {
    vr = 0;
    prin = p;
    pos = prin?new PVector(width/2, height/2):new PVector(random(width), random(height));
    tam = prin?4:int(random(1, 10));
    float s = random(0, TWO_PI);
    dir = new PVector(cos(s), sin(s));
    t1 = new PVector(-1, 1);
    t2 = new PVector(-1, -1);
    t3 = new PVector(1, -1);
    href = new PVector(1, 0);
    alive = true;
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

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir.heading());

    noStroke();
    fill(fin, 190);
    triangle(-tam*1.1, 0, -tam*2.3, -tam*1.0, -tam*2.0, tam*0.1);
    triangle(-tam*1.1, 0, -tam*2.3, tam*1.0, -tam*2.0, -tam*0.1);

    fill(body);
    ellipse(0, 0, tam*3.1, tam*1.55);

    fill(belly, 170);
    ellipse(tam*0.25, tam*0.3, tam*2.0, tam*0.65);

    fill(fin, 180);
    triangle(-tam*0.35, -tam*0.62, tam*0.3, -tam*1.25, tam*0.75, -tam*0.45);
    triangle(-tam*0.2, tam*0.45, tam*0.65, tam*1.0, tam*0.45, tam*0.15);

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
      if (t <= tam) {
        dir = new PVector(x, y);
      }
      else {
        dir = new PVector(2*pos.x-x, 2*pos.y-y);
      }

      dir.sub(pos);

      dir.normalize();

      dir.mult((acc));
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
}
