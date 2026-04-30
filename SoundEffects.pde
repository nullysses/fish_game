class SoundEffects {
  SinOsc bloopTone;
  SinOsc bloopPop;
  Env bloopEnvelope;
  Env popEnvelope;

  SoundEffects(PApplet parent) {
    bloopTone = new SinOsc(parent);
    bloopPop = new SinOsc(parent);
    bloopEnvelope = new Env(parent);
    popEnvelope = new Env(parent);

    bloopTone.amp(0.18);
    bloopPop.amp(0.07);
  }

  void bloop() {
    float baseFreq = 360;

    bloopTone.freq(baseFreq);
    bloopTone.pan(random(-0.35, 0.35));
    bloopTone.play();
    bloopEnvelope.play(bloopTone, 0.004, 0.035, 0.65, 0.16);

    bloopPop.freq(baseFreq * random(1.55, 1.9));
    bloopPop.pan(random(-0.35, 0.35));
    bloopPop.play();
    popEnvelope.play(bloopPop, 0.001, 0.015, 0.35, 0.07);
  }
}
