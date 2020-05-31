class Particle_Fish {

  PVector pos;
  PVector vel;
  PVector acc;
  PVector target;

  ArrayList<PVector> history;

  float baseHue;
  float variation;
  float speed;
  float maxSpeed;
    float colorG = random(150,255);
    float colorB = random(100,255);

  Particle_Fish() {
    this.pos = new PVector(width/2, height+50);
    this.vel = PVector.random2D();
    this.vel.mult(10);
    this.acc = new PVector(0, 0);
    this.target = new PVector(0, 0);
    this.history = new ArrayList<PVector>();

    this.baseHue = 200;

    this.variation = random(0.75, 1);
    this.speed = random(0.25, 0.75);
    this.maxSpeed = random(5, 10);
  }

  void move() {
    this.target.x = gazeTrack.getGazeX(); //filteredCoord.x;
    this.target.y = gazeTrack.getGazeY(); //filteredCoord.y;
    // Steer towards target.
    PVector steer = new PVector(this.target.x, this.target.y);
    steer.sub(this.pos);
    steer.sub(this.vel); // Makes it come to a stop.
    steer.normalize();
    steer.mult(this.speed*this.variation);
    this.acc.add(steer);

    float d = dist(this.pos.x, this.pos.y, gazeTrack.getGazeX(), gazeTrack.getGazeY());

    // Attract/repulse with mouse controls.
    if (mousePressed && mouseButton != CENTER && d < 200) {
      PVector source = new PVector(gazeTrack.getGazeX(), gazeTrack.getGazeY());
      PVector push = new PVector(this.pos.x, this.pos.y);
      push.sub(source);
      push.normalize();
      push.mult(force);

      if (mouseButton == LEFT) {
        push.mult(-1);
      }

      this.acc.add(push);
    }
    /*
    // Apply air drag if it's near the target.
     float thresh = 100;
     if (d < thresh) {
     float airDrag = map(d, 0, thresh, 1, 0.95);
     this.vel.mult(airDrag);
     }
     */
    // Move it.
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);

    this.history.add(0, new PVector(this.pos.x, this.pos.y));

    if (this.history.size() > maxHistoryCount) {
      this.history.remove(maxHistoryCount);
    }
  }

  void display(int ScaleNum) {
    float hueDif =-50;
    
    int historySize = this.history.size();
    float t = map(gazeTrack.getGazeY(), 0, height, 0, 255);
    for (int i = historySize-1; i > 0; i--) {
      float w = map(i, 0, historySize, maxSize, 0);

      strokeWeight(w*(1800-ScaleNum)/6); //10 is size 
      float h = constrain(map(i, 0, historySize, this.baseHue, this.baseHue+hueDif), 0, 255);
      float h2 = constrain(map(i, 0, historySize/2, 1, 0), 0, 255);

      stroke(h, colorG, colorB, t);  //** COLOR 
      // Using points performs faster, but lines give a more 'crisp' look.
      if (i>1)
       // line(this.history.get(i).x, this.history.get(i).y, this.history.get(i-1).x, this.history.get(i-1).y);
      point(this.history.get(i).x, this.history.get(i).y);

      if (i<historySize/2) {
        stroke(t, colorG, colorB, h2*t);
        if (i>1) 
         // line(this.history.get(i).x, this.history.get(i).y, this.history.get(i-1).x, this.history.get(i-1).y);
        point(this.history.get(i).x, this.history.get(i).y);
      }


      noFill();
    }
    strokeWeight(1);
    // Increase hue if it's below threshold.
    if (dist(this.pos.x, this.pos.y, this.target.x, this.target.y) < 100) {
      this.baseHue += 1;
      if (this.baseHue > 255-hueDif) {
        this.baseHue = -hueDif;
      }
    }
  }
}
