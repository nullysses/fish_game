class Bubble {
  PVector pos;
  float size;
  float oscillation;
  float oscillationSpeed;
  float oscillationAmount;
  float riseSpeed;

  Bubble(float x, float y) {
    pos = new PVector(x, y);
    size = random(7, 14);
    oscillation = random(TWO_PI);
    oscillationSpeed = random(0.06, 0.11);
    oscillationAmount = random(0.45, 0.9);
    riseSpeed = random(0.8, 1.6);
  }

  void move() {
    oscillation += oscillationSpeed;
    pos.x += sin(oscillation) * oscillationAmount;
    pos.y -= riseSpeed;
  }

  void draw() {
    noFill();
    strokeWeight(max(1, size * 0.12));
    stroke(0, 68, 145, 165);
    ellipse(pos.x, pos.y, size, size);

    strokeWeight(max(1, size * 0.08));
    stroke(40, 210, 245, 185);
    arc(pos.x, pos.y, size * 0.82, size * 0.82, -PI * 0.15, PI * 0.75);

    stroke(255, 255, 255, 175);
    arc(pos.x - size * 0.12, pos.y - size * 0.16, size * 0.36, size * 0.28, PI, TWO_PI * 0.92);

    noStroke();
    fill(255, 255, 255, 145);
    ellipse(pos.x - size * 0.22, pos.y - size * 0.22, size * 0.16, size * 0.16);
    fill(110, 235, 255, 85);
    ellipse(pos.x + size * 0.16, pos.y + size * 0.12, size * 0.12, size * 0.12);
  }

  boolean offScreen() {
    return pos.y + size < 0;
  }
}
