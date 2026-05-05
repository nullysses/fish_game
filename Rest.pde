class Rest {
  ArrayList<Fish> dots;
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

  Rest(Fish f, int ars) {
    p = f;
    dots = new ArrayList();
    gamestate = 0;
    smallerav = true;
    max_cohere_angle = (PI/120);
    fish_neighborhood_scale = 12;
    danger_retarget_frames = 60;
    expected_chase_speed = 1;
    similar_size_avoidance_scale = 4;

    for (int i = 0; i < ars; i++) {
      dots.add( new Fish(false));
    }
  }

  public void draw() {
    strokeWeight(5);
    stroke(250, 250, 100);

    for (int i = 0; i < dots.size(); i++) {
      Fish fish = dots.get(i);

      if (!fish.alive) {
        continue;
      }

      if (p.pos.dist(fish.pos) < p.tam*2) {
        if (p.tam > fish.tam) {
          fish.alive = false;
          p.vr++;
        }
        else {
          gamestate = 2;
        }
      }
      else {
        for (int j = 0; j < dots.size(); j++) {
          Fish other = dots.get(j);

          if (fish != other && other.alive && fish.pos.dist(other.pos) < fish.tam*2) {
            if (fish.tam > other.tam) {
              fish.vr++;
              other.alive = false;
            }
          }
        }

        if (!fish.alive) {
          continue;
        }

        updateTargets(fish);
        fish.draw();

        if (fish.flee_target != null && isImmediateThreat(fish, fish.flee_target)) {
          moveWithAvoidance(fish, fish.flee_target, 2);
        }
        else if (fish.chase_target != null) {
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
        dots.remove(j);
        if (dots.size() == 0) {
          gamestate = 2;
        }
      }
      else {
        if (dots.get(j).tam < p.tam) {
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

    if (larger && p.tam > fish.tam) {
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

    if (p.tam > fish.tam && isImmediateThreat(fish, p)) {
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

    if (p.tam < fish.tam && fish.pos.dist(p.pos) < sight_d) {
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
}
