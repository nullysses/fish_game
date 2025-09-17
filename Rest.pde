class Rest {
  ArrayList<Fish> dots;
  ArrayList<Integer> tams;
  Fish p;
  boolean gameover;
  boolean smallerav; 
  float max_cohere_angle;
  float max_away_angle;

  Rest(Fish f, int ars) {
    p = f;
    dots = new ArrayList();
    gameover = false;
    boolean smallerav = true;
     max_cohere_angle = (PI/120);

    for (int i = 0; i < ars; i++) {
      //dots.add( new PVector(random(width), random(height)));
      dots.add( new Fish(false));
    }
  }

  public void draw() {
    strokeWeight(5);
    stroke(250, 250, 100);
    int nearest = -1;
    float nearestd = 10;
    PVector cohere_dir = new PVector(0, 0);

    for (int i = 0; i < dots.size(); i++) {
      nearest = -1;
      nearestd = dots.get(i).tam*8;
      cohere_dir = new PVector(0, 0);


      if (p.pos.dist(dots.get(i).pos) < p.tam*2) {
        if (p.tam > dots.get(i).tam) {
          dots.get(i).alive = false;
          p.vr++;
        }
        else {
          gameover = true;
        }
      }
      else {
        for (int j = 0; j < dots.size()-1; j++) {
          //println(i+":"+j);

          if (dots.get(i).pos.dist(dots.get(j).pos) < dots.get(i).tam*2) {
            if (dots.get(i).tam > dots.get(j).tam) {
              dots.get(i).vr++;
              dots.get(j).alive = false;
            }
          }
          else {        
            if (dots.get(i).pos.dist(dots.get(j).pos) < nearestd && i != j) {
              nearest = j;
              nearestd = dots.get(i).pos.dist(dots.get(j).pos);
            }
          }
        }
        dots.get(i).draw();
        if (p.pos.dist(dots.get(i).pos) < p.tam*8) {
          dots.get(i).move(p.pos.x, p.pos.y, p.tam, 1);
          if (!smallerav) {
            dots.get(i).move(p.pos.x, p.pos.y, p.tam, 3);
          }
        }
        else {

          if (!smallerav) {
            cohere_dir.x = (p.pos.x-dots.get(i).pos.x);
            cohere_dir.y = (p.pos.y-dots.get(i).pos.y);
            float coh_angle = PVector.angleBetween(dots.get(i).dir, cohere_dir);
            int orient = (dots.get(i).dir.x > cohere_dir.x)?1:-1;

            if (coh_angle <max_cohere_angle) {
              dots.get(i).dir = dots.get(i).turn(dots.get(i).dir, coh_angle*orient);
            }
            else {
              dots.get(i).dir = dots.get(i).turn(dots.get(i).dir, max_cohere_angle*orient);
            }      

            //dots.get(i).dir = dots.get(i).turn(dots.get(i).dir, orient*(PI/120));
            if (nearest != -1) {
              //dots.get(i).dir = dots.get(i).turn(dots.get(i).dir, PVector.angleBetween(dots.get(i).dir, dots.get(nearest).pos)/20);
            }
          }
          else {
          }
          dots.get(i).move(dots.get(i).pos.x+dots.get(i).dir.x*dots.get(i).tam*2, dots.get(i).pos.y+dots.get(i).dir.y*dots.get(i).tam*2, 0, 1);
        }

        //point(dots.get(i).pos.x, dots.get(i).pos.y);
        //println(dots.get(i).x + " " +  dots.get(i).y);
      }
    }

    smallerav= false;
    for (int j = 0; j < dots.size(); j++) {
      if (!dots.get(j).alive) {
        dots.remove(j);
        if (dots.size() == 0) {
          gameover = true;
        }
      }
      else {        
        if (dots.get(j).tam < p.tam) {
          smallerav = true;
        }
      }
    }
  }
}