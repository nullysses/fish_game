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
  float boost_cooldown_frames;
  int boost_duration_frames;
  int boost_recharge_frames;
  float[] boost_policy_genome;
  float[] last_boost_policy_inputs;
  float last_boost_policy_output;
  boolean last_boost_policy_decision;
  boolean last_boost_policy_available;
  int last_turn_sign;
  int nodding_flips;
  int nodding_frames;
  ArrayList<TailRipple> tail_ripples;
  int initial_tam;
  int prey_eaten;
  int boost_uses;
  int survival_frames;
  float fitness;

  Fish(boolean p) {
    vr = 0;
    prin = p;
    pos = prin?new PVector(width/2, height/2):new PVector(random(width), random(height));
    tam = prin?8:int(random(5, 12));
    initial_tam = tam;
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
    boost_duration_frames = 30;
    boost_recharge_frames = 150;
    boost_cooldown_frames = boost_recharge_frames;
    boost_policy_genome = new float[9];
    last_boost_policy_inputs = new float[8];
    randomizeBoostPolicyGenome();
    last_boost_policy_output = 0;
    last_boost_policy_decision = false;
    last_boost_policy_available = false;
    last_turn_sign = 0;
    nodding_flips = 0;
    nodding_frames = 0;
    tail_ripples = new ArrayList();
    prey_eaten = 0;
    boost_uses = 0;
    survival_frames = 0;
    fitness = 0;
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
    updateTailRipples();

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

    drawTailRipples();
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
      float speed = acc*tam*fish_top_speed_size_factor;
      if (boost_frames > 0) {
        speed *= 2;
      }
      if (nodding_frames > 0) {
        speed *= 1.5;
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
        updateNodding(turn_angle);
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

  void updateNodding(float turn_angle) {
    int turn_sign = turn_angle > 0 ? 1 : turn_angle < 0 ? -1 : 0;
    boolean small_correction = abs(turn_angle) < PI/4;

    if (turn_sign != 0 && last_turn_sign != 0 && turn_sign != last_turn_sign && small_correction) {
      nodding_flips++;
    }
    else if (!small_correction || turn_sign == last_turn_sign) {
      nodding_flips = max(0, nodding_flips-1);
    }

    if (turn_sign != 0) {
      last_turn_sign = turn_sign;
    }

    if (nodding_flips >= 4) {
      nodding_frames = 20;
      nodding_flips = 2;
    }
    else if (nodding_frames > 0) {
      nodding_frames--;
    }
  }

  void updateTailRipples() {
    if (!prin && (nodding_frames > 0 || boost_frames > 0) && frameCount%3 == 0) {
      PVector tail = PVector.sub(pos, PVector.mult(dir, tam*1.8));
      tail_ripples.add(new TailRipple(tail.x, tail.y, tam));
    }

    for (int i = tail_ripples.size()-1; i >= 0; i--) {
      TailRipple ripple = tail_ripples.get(i);
      ripple.update();
      if (ripple.done()) {
        tail_ripples.remove(i);
      }
    }
  }

  void drawTailRipples() {
    for (int i = 0; i < tail_ripples.size(); i++) {
      tail_ripples.get(i).draw();
    }
  }

  void tryBoost() {
    if (!prin && boost_frames == 0 && boost_cooldown_frames == 0 && shouldUseBoost()) {
      boost_frames = boost_duration_frames;
      boost_cooldown_frames = boost_recharge_frames;
      boost_uses++;
    }
  }

  void updateBoost() {
    if (boost_frames > 0) {
      boost_frames--;
    }
    else if (boost_cooldown_frames > 0) {
      boost_cooldown_frames -= fish_boost_regeneration_size_factor/tam;
      if (boost_cooldown_frames < 0) {
        boost_cooldown_frames = 0;
      }
    }
  }

  boolean shouldUseBoost() {
    evaluateBoostPolicy();
    return last_boost_policy_decision;
  }

  void evaluateBoostPolicy() {
    last_boost_policy_available = boost_frames == 0 && boost_cooldown_frames == 0;
    updateBoostPolicyInputs();

    float z = boost_policy_genome[8];
    for (int i = 0; i < last_boost_policy_inputs.length; i++) {
      z += last_boost_policy_inputs[i]*boost_policy_genome[i];
    }

    last_boost_policy_output = 1/(1+exp(-z));
    last_boost_policy_decision = last_boost_policy_available && last_boost_policy_output > fish_boost_policy_threshold;
  }

  void updateBoostPolicyInputs() {
    // Inputs: prey dx/dy, predator dx/dy, self size, prey size ratio, predator size ratio, cooldown ratio.
    setTargetInputs(chase_target, 0);
    setTargetInputs(flee_target, 2);

    last_boost_policy_inputs[4] = constrain(tam/20.0, 0, 1);
    last_boost_policy_inputs[5] = chase_target == null ? 0 : constrain(chase_target.tam/(float)tam, 0, 3);
    last_boost_policy_inputs[6] = flee_target == null ? 0 : constrain(flee_target.tam/(float)tam, 0, 3);
    last_boost_policy_inputs[7] = constrain(boost_cooldown_frames/(float)boost_recharge_frames, 0, 1);
  }

  void setTargetInputs(Fish target, int index) {
    if (target == null || !target.alive) {
      last_boost_policy_inputs[index] = 0;
      last_boost_policy_inputs[index+1] = 0;
      return;
    }

    float norm = max(width, height);
    last_boost_policy_inputs[index] = constrain((target.pos.x-pos.x)/norm, -1, 1);
    last_boost_policy_inputs[index+1] = constrain((target.pos.y-pos.y)/norm, -1, 1);
  }

  void randomizeBoostPolicyGenome() {
    for (int i = 0; i < boost_policy_genome.length; i++) {
      boost_policy_genome[i] = random(-0.5, 0.5);
    }
  }

  void mutateBoostPolicyGenome() {
    for (int i = 0; i < boost_policy_genome.length; i++) {
      if (random(1) < fish_boost_policy_mutation_rate) {
        boost_policy_genome[i] += random(-fish_boost_policy_mutation_amount, fish_boost_policy_mutation_amount);
      }
    }
  }

  void eatPrey() {
    vr++;
    prey_eaten++;
  }

  void copyBoostPolicyGenomeFrom(Fish parent) {
    for (int i = 0; i < boost_policy_genome.length; i++) {
      boost_policy_genome[i] = parent.boost_policy_genome[i];
    }
  }

  String boostPolicyGenomeCsv() {
    String genome = "";
    for (int i = 0; i < boost_policy_genome.length; i++) {
      if (i > 0) {
        genome += ",";
      }
      genome += boost_policy_genome[i];
    }
    return genome;
  }

  void loadBoostPolicyGenomeCsv(String genome) {
    String[] weights = split(trim(genome), ',');
    for (int i = 0; i < min(weights.length, boost_policy_genome.length); i++) {
      boost_policy_genome[i] = float(weights[i]);
    }
  }

  void updateFitness() {
    fitness = survival_frames*fish_training_survival_weight;
    fitness += max(0, tam-initial_tam)*fish_training_growth_weight;
    fitness += prey_eaten*fish_training_prey_weight;
    fitness -= boost_uses*fish_training_boost_penalty;
  }
}
