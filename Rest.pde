class Rest {
  ArrayList<Fish> dots;
  ArrayList<Fish> training_pool;
  ArrayList<Integer> tams;
  Fish p;
  int gamestate;
  boolean smallerav;
  float max_cohere_angle;
  float max_away_angle;
  float fish_neighborhood_scale;
  int danger_retarget_frames;
  float expected_chase_speed;
  float similar_size_avoidance_scale;
  int training_generation;
  int training_frame;
  int training_population_size;

  Rest(Fish f, int ars) {
    p = f;
    dots = new ArrayList();
    training_pool = new ArrayList();
    gamestate = 0;
    smallerav = true;
    max_cohere_angle = (PI/120);
    fish_neighborhood_scale = 12;
    danger_retarget_frames = 60;
    expected_chase_speed = 1;
    similar_size_avoidance_scale = 4;
    training_generation = 1;
    training_frame = 0;
    training_population_size = ars;

    for (int i = 0; i < ars; i++) {
      Fish fish = new Fish(false);
      dots.add(fish);
      training_pool.add(fish);
    }
  }

  public void draw() {
    draw(true);
  }

  public void draw(boolean render) {
    strokeWeight(5);
    stroke(250, 250, 100);

    for (int i = 0; i < dots.size(); i++) {
      Fish fish = dots.get(i);

      if (!fish.alive) {
        continue;
      }
      if (fish_training_mode) {
        fish.survival_frames++;
      }

      if (hasPrincipal() && p.pos.dist(fish.pos) < p.tam*2) {
        if (p.tam > fish.tam) {
          fish.alive = false;
          p.vr++;
        }
        else {
          if (!fish_training_mode) {
            gamestate = 2;
          }
        }
      }
      else {
        for (int j = 0; j < dots.size(); j++) {
          Fish other = dots.get(j);

          if (fish != other && other.alive && fish.pos.dist(other.pos) < fish.tam*2) {
            if (fish.tam > other.tam) {
              fish.eatPrey();
              other.alive = false;
            }
          }
        }

        if (!fish.alive) {
          continue;
        }

        updateTargets(fish);
        if (render) {
          fish.draw();
          drawBoostPolicyDebug(fish);
        }

        if (fish.flee_target != null && isImmediateThreat(fish, fish.flee_target)) {
          moveWithAvoidance(fish, fish.flee_target, 2);
        }
        else if (fish.chase_target != null) {
          if (isMaxSizeFish(fish)) {
            fish.tryBoost();
          }
          moveWithAvoidance(fish, fish.chase_target, 1);
        }
        else {
          PVector forward = new PVector(fish.pos.x+fish.dir.x*fish.tam*2, fish.pos.y+fish.dir.y*fish.tam*2);
          moveWithAvoidance(fish, forward, 0, 1);
        }

      }
    }

    smallerav = false;
    for (int j = dots.size()-1; j >= 0; j--) {
      if (!dots.get(j).alive) {
        if (!fish_training_mode) {
          dots.remove(j);
          if (dots.size() == 0) {
            gamestate = 2;
          }
        }
      }
      else {
        if (hasPrincipal() && dots.get(j).tam < p.tam) {
          smallerav = true;
        }
      }
    }
  }

  void updateTargets(Fish fish) {
    if (fish.chase_target == null || !fish.chase_target.alive || fish.chase_target.tam >= fish.tam) {
      setChaseTarget(fish, findTarget(fish, false));
    }
    if (fish.flee_target == null || !fish.flee_target.alive || fish.flee_target.tam <= fish.tam) {
      setFleeTarget(fish, findTarget(fish, true));
    }

    Fish close_threat = findCloseThreat(fish);
    if (close_threat != null) {
      setFleeTarget(fish, close_threat);
    }

    Fish visible_prey = findVisiblePrey(fish);
    if (visible_prey != null) {
      setChaseTarget(fish, visible_prey);
    }
  }

  void setChaseTarget(Fish fish, Fish target) {
    if (isLockedOnPrincipalInSurvival(fish) && target != p) {
      return;
    }

    if (fish.chase_target != target) {
      fish.chase_target = target;
      if (target != null) {
        fish.tryBoost();
      }
    }
  }

  void setFleeTarget(Fish fish, Fish target) {
    if (fish.flee_target != target) {
      fish.flee_target = target;
      if (target != null) {
        fish.tryBoost();
      }
    }
  }

  Fish findTarget(Fish fish, boolean larger) {
    Fish target = null;
    float target_d = 0;

    if (larger && hasPrincipal() && p.tam > fish.tam) {
      target = p;
      target_d = fish.pos.dist(p.pos);
    }

    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (fish == other || !other.alive) {
        continue;
      }

      if ((larger && other.tam > fish.tam) || (!larger && other.tam < fish.tam)) {
        float other_d = fish.pos.dist(other.pos);
        if (target == null || other_d < target_d) {
          target = other;
          target_d = other_d;
        }
      }
    }

    return target;
  }

  Fish findCloseThreat(Fish fish) {
    Fish target = null;
    float target_d = 0;

    if (hasPrincipal() && p.tam > fish.tam && isImmediateThreat(fish, p)) {
      target = p;
      target_d = fish.pos.dist(p.pos);
    }

    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (fish == other || !other.alive || other.tam <= fish.tam || !isImmediateThreat(fish, other)) {
        continue;
      }

      float other_d = fish.pos.dist(other.pos);
      if (target == null || other_d < target_d) {
        target = other;
        target_d = other_d;
      }
    }

    return target;
  }

  Fish findVisiblePrey(Fish fish) {
    Fish target = null;
    float target_d = 0;
    float sight_d = fish.tam*fish_neighborhood_scale;

    if (hasPrincipal() && p.tam < fish.tam && fish.pos.dist(p.pos) < sight_d) {
      target = p;
      target_d = fish.pos.dist(p.pos);
    }

    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (fish == other || !other.alive || other.tam >= fish.tam) {
        continue;
      }

      float other_d = fish.pos.dist(other.pos);
      if (other_d < sight_d && (target == null || other_d < target_d)) {
        target = other;
        target_d = other_d;
      }
    }

    return target;
  }

  boolean isImmediateThreat(Fish fish, Fish threat) {
    float eat_d = max(fish.tam, threat.tam)*2;
    float danger_d = eat_d+danger_retarget_frames*expected_chase_speed;
    return fish.pos.dist(threat.pos) < danger_d;
  }

  boolean isLockedOnPrincipalInSurvival(Fish fish) {
    return hasPrincipal() && fish.chase_target == p && fish.tam > p.tam && noPrincipalPreyAvailable();
  }

  boolean noPrincipalPreyAvailable() {
    if (!hasPrincipal()) {
      return false;
    }

    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (other.alive && other.tam < p.tam) {
        return false;
      }
    }

    return true;
  }

  boolean hasPrincipal() {
    return !fish_training_mode && p != null;
  }

  boolean isMaxSizeFish(Fish fish) {
    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (other.alive && other.tam > fish.tam) {
        return false;
      }
    }

    return true;
  }

  void moveWithAvoidance(Fish fish, Fish target, float acc) {
    moveWithAvoidance(fish, target.pos, target.tam, acc);
  }

  void moveWithAvoidance(Fish fish, PVector target_pos, int target_size, float acc) {
    PVector desired = PVector.sub(target_pos, fish.pos);
    if (target_size > fish.tam) {
      desired.mult(-1);
    }

    PVector avoidance = similarSizeAvoidance(fish);
    if (avoidance.mag() > 0) {
      desired.normalize();
      desired.mult(fish.tam*2);
      avoidance.normalize();
      avoidance.mult(fish.tam*3);
      desired.add(avoidance);
    }

    if (desired.mag() > 0) {
      PVector adjusted_target = PVector.add(fish.pos, desired);
      fish.move(adjusted_target.x, adjusted_target.y, 0, acc);
    }
    else {
      fish.move(target_pos.x, target_pos.y, target_size, acc);
    }
  }

  PVector similarSizeAvoidance(Fish fish) {
    PVector avoidance = new PVector(0, 0);
    float avoid_d = fish.tam*similar_size_avoidance_scale;

    for (int i = 0; i < dots.size(); i++) {
      Fish other = dots.get(i);

      if (fish == other || !other.alive || abs(fish.tam-other.tam) > 1) {
        continue;
      }

      float other_d = fish.pos.dist(other.pos);
      if (other_d > 0 && other_d < avoid_d) {
        PVector away = PVector.sub(fish.pos, other.pos);
        away.normalize();
        away.mult((avoid_d-other_d)/avoid_d);
        avoidance.add(away);
      }
    }

    return avoidance;
  }

  void startTraining() {
    gamestate = 1;
    training_generation = 1;
    training_frame = 0;
    training_population_size = dots.size();
    training_pool = new ArrayList();

    for (int i = 0; i < dots.size(); i++) {
      training_pool.add(dots.get(i));
    }
  }

  void advanceTraining() {
    training_frame++;
    if (training_frame >= fish_training_generation_frames) {
      nextTrainingGeneration();
    }
  }

  void nextTrainingGeneration() {
    ArrayList<Fish> ranked = rankedTrainingPool();
    int top_count = min(fish_training_top_k, ranked.size());

    if (top_count == 0) {
      resetTrainingGeneration(null);
      return;
    }

    ArrayList<Fish> next = new ArrayList();
    for (int i = 0; i < training_population_size; i++) {
      Fish parent = ranked.get(i%top_count);
      Fish child = new Fish(false);
      child.copyBoostPolicyGenomeFrom(parent);
      child.mutateBoostPolicyGenome();
      next.add(child);
    }

    saveTrainingGeneration(next, ranked);
    resetTrainingGeneration(next);
  }

  ArrayList<Fish> rankedTrainingPool() {
    ArrayList<Fish> ranked = new ArrayList();
    for (int i = 0; i < training_pool.size(); i++) {
      Fish fish = training_pool.get(i);
      fish.updateFitness();
      ranked.add(fish);
    }

    for (int i = 0; i < ranked.size()-1; i++) {
      int best = i;
      for (int j = i+1; j < ranked.size(); j++) {
        if (ranked.get(j).fitness > ranked.get(best).fitness) {
          best = j;
        }
      }

      Fish temp = ranked.get(i);
      ranked.set(i, ranked.get(best));
      ranked.set(best, temp);
    }

    return ranked;
  }

  void resetTrainingGeneration(ArrayList<Fish> next) {
    dots = new ArrayList();
    training_pool = new ArrayList();

    if (next == null) {
      next = new ArrayList();
    }

    if (next != null) {
      for (int i = 0; i < next.size(); i++) {
        Fish fish = next.get(i);
        dots.add(fish);
        training_pool.add(fish);
      }
    }

    while (dots.size() < training_population_size) {
      Fish fish = new Fish(false);
      dots.add(fish);
      training_pool.add(fish);
    }

    p = null;
    training_generation++;
    training_frame = 0;
  }

  void drawTrainingOverlay() {
    pushStyle();
    fill(255);
    textSize(16);
    textAlign(LEFT, TOP);
    text("Training gen "+training_generation+" frame "+training_frame+"/"+fish_training_generation_frames, 20, 20);

    ArrayList<Fish> ranked = rankedTrainingPool();
    if (ranked.size() > 0) {
      Fish best = ranked.get(0);
      text("Best fitness "+nf(best.fitness, 1, 2)+" size "+best.tam+" prey "+best.prey_eaten+" boosts "+best.boost_uses, 20, 42);
    }
    popStyle();
  }

  void saveTrainingGeneration(ArrayList<Fish> generation, ArrayList<Fish> ranked) {
    File dir = new File(sketchPath(fish_training_save_dir));
    dir.mkdirs();

    String[] lines = new String[generation.size()+2];
    lines[0] = "# generation,"+training_generation;
    lines[1] = "# best_fitness,"+(ranked.size() > 0 ? ranked.get(0).fitness : 0);
    for (int i = 0; i < generation.size(); i++) {
      lines[i+2] = generation.get(i).boostPolicyGenomeCsv();
    }

    saveStrings(fish_training_save_dir+"/generation_"+nf(training_generation, 4)+".csv", lines);
  }

  void loadLatestTrainingGeneration() {
    File dir = new File(sketchPath(fish_training_save_dir));
    if (!dir.exists()) {
      return;
    }

    File[] files = dir.listFiles();
    if (files == null) {
      return;
    }

    String latest = null;
    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName();
      if (name.startsWith("generation_") && name.endsWith(".csv") && (latest == null || name.compareTo(latest) > 0)) {
        latest = name;
      }
    }

    if (latest == null) {
      return;
    }

    String[] lines = loadStrings(fish_training_save_dir+"/"+latest);
    if (lines == null) {
      return;
    }

    ArrayList<String> genomes = new ArrayList();
    for (int i = 0; i < lines.length; i++) {
      String line = trim(lines[i]);
      if (line.length() > 0 && !line.startsWith("#")) {
        genomes.add(line);
      }
    }

    if (genomes.size() == 0) {
      return;
    }

    for (int i = 0; i < dots.size(); i++) {
      dots.get(i).loadBoostPolicyGenomeCsv(genomes.get(i%genomes.size()));
    }
  }

  void drawBoostPolicyDebug(Fish fish) {
    if (!fish_boost_policy_debug) {
      return;
    }

    if (fish.boost_frames == 0) {
      fish.evaluateBoostPolicy();
    }

    pushStyle();
    textSize(10);
    textAlign(CENTER, CENTER);
    fill(fish.boost_frames > 0 ? color(70, 210, 255) : fish.last_boost_policy_decision ? color(40, 220, 90) : color(255, 255, 255));
    text(nf(fish.last_boost_policy_output, 1, 2), fish.pos.x, fish.pos.y-fish.tam*2.3);

    noFill();
    stroke(fish.last_boost_policy_available ? color(40, 220, 90, 180) : color(255, 220, 80, 140));
    ellipse(fish.pos.x, fish.pos.y, fish.tam*4.2, fish.tam*2.2);
    popStyle();
  }
}
