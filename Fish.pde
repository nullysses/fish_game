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
    //dir = new PVector(-1, 0);
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
    noStroke();
    int c = prin?color(255, 140, 130):color(130, 255, 140);
    fill(c);

    float alpha = PVector.angleBetween(href, dir);
    if (dir.y < 0) {
      alpha = -alpha;
    }
    arc(pos.x+dir.x*tam*0.9, pos.y+dir.y*tam*0.9, tam*2, tam*2, alpha, alpha+TWO_PI-QUARTER_PI);

    float f = 0.7;
    t2.x = t1.x = -dir.y;
    t2.y = t1.y = dir.x;
    


    t1.add(dir);
    t1.mult(-1*tam*0.9);
    t1.add(pos);

    t2.sub(dir);
    t2.mult(tam*0.9);
    t2.add(pos);
    
    t3 = turn(dir, -QUARTER_PI+QUARTER_PI/2);
    t3.mult(tam*1.2);
    t3.add(pos);
    
    triangle(pos.x, pos.y, 
    t1.x, t1.y, 
    t2.x, t2.y);
    noStroke();
    fill(255);
    
    ellipse(t3.x,t3.y, tam/2, tam/2);
    stroke(0);
    strokeWeight(2);
    point(t3.x,t3.y);


  }

  public void move(float x, float y, int t, float acc) { 


    //if (abs(mouseX - pos.x) > tam && abs(mouseY - pos.y) > tam) {
    if (prin) {
      dir.x = pos.x;
      dir.y = pos.y;

      dir = new PVector(mouseX, mouseY);


      dir.sub(pos);

      float n = dir.mag();
      dir.normalize();

      dir.mult(n/6);
      pos.add(dir);

      //pos.mult(n/6);

      //dir.sub(pos);
      //dir.mult(-1);
      dir.normalize();
    }
    else {
      //dir.x = pos.x;
      //dir.y = pos.y;

      if (t <= tam) {
        dir = new PVector(x, y);
      }
      else {
        dir = new PVector(2*pos.x-x, 2*pos.y-y);
      }

      dir.sub(pos);

      float n = dir.mag();
      dir.normalize();

      dir.mult((acc));
      //pos.add(dir);
      pos.x = (pos.x+dir.x)%width;
      if (pos.x <= 0) {
        pos.x = width-tam*2;
      }
      pos.y = (pos.y+dir.y)%height;
      if (pos.y <= 0) {
        pos.y = height-tam*2;
      }

      //pos.mult(n/6);

      //dir.sub(pos);
      //dir.mult(-1);
      dir.normalize();
    }
    //}

    //    println("mx:"+mouseX+" "+"dx:"+dir.x+" px:"+pos.x);
    //    println("my:"+mouseY+" "+"dy:"+dir.y+" px:"+pos.y);
  }
}