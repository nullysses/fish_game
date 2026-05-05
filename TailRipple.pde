class TailRipple {
  PVector pos;
  float radius;
  float alpha;
  float growth;

  TailRipple(float x, float y, float fish_size) {
    pos = new PVector(x, y);
    radius = fish_size*0.3;
    alpha = 150;
    growth = max(0.35, fish_size*0.06);
  }

  void update() {
    radius += growth;
    alpha -= 8;
  }

  void draw() {
    pushStyle();
    noFill();
    strokeWeight(1);
    stroke(230, 250, 255, alpha);
    ellipse(pos.x, pos.y, radius, radius*0.55);
    popStyle();
  }

  boolean done() {
    return alpha <= 0;
  }
}
