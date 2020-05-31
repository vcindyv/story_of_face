class Creature {

  float fOffset;
  PVector pos;
  PVector dir;
  ArrayList<Rope> ropes;
  int ScaleNum;
  int legLength;
  int legNum;

  Creature(float _x, float _y, int _legLength, int _legNum  ) {
    pos = new PVector(_x, _y);
    dir = new PVector(1, 1);
    ropes = new ArrayList<Rope>();
    fOffset = random(50000);
    legLength=_legLength;
    legNum=_legNum;
    for (int a = 0; a < 150; a+=150/legNum) { // a는 방향, a+는 다리 갯수
      Rope newRope = new Rope(_x, _y, a, legLength); //6 == lenght
      this.ropes.add(newRope);
    }
  }

  void display() {
    fill(225);
    ellipse(pos.x, pos.y, 100, 100);
  }

  void addLength() {
    for (int i=0; i<ropes.size(); i++) {
      Rope newRope = new Rope(pos.x, pos.y, 150/legNum, legLength); //6 == lenght
      this.ropes.add(newRope);
    }
  }
}

// Uses a series of dynamic objects but displays them as a single line.
// This Code can change Color.

class Rope {

  float a;
  Spring objsHead;
  ArrayList<Pendulum> objs;
  float startX;
  float startY;
  float x, y;
  float ropeScale=1;
  int count;

  Rope(float _x, float _y, float _a, int _count) {
    this.a = _a;
    this.objs = new ArrayList<Pendulum>();
    //x = _x;
    //y = _y;
    startX = _x+cos(radians(a)); 
    startY = _y+sin(radians(a));
    startX = 0; 
    startY = 0;
    objsHead = new Spring(startX, startY, 1);
    count=_count;

    for (int i = 0; i < _count; i++) {
      if (i==0) {
        this.objs.add(new Pendulum(this.a, startX, startY+i*25, objsHead)); // 길이
      } else {
        Pendulum _parent = objs.get(objs.size()-1);
        this.objs.add(new Pendulum(this.a, startX, startY+i*25, _parent));  // 길이
      }
    }
  }

  void display() {
    //noFill();
    stroke(255, 80);
    strokeWeight(0.5);

    objsHead.move();
    //objsHead.display();

    ellipse(objsHead.pos.x, objsHead.pos.y, 10, 10);

    beginShape();
    curveVertex(objsHead.pos.x, objsHead.pos.y);


    for (int i = 0; i < this.objs.size(); i++) {
      Pendulum pn = objs.get(i);
      pn.move();

      if (debugMode) {
        pn.display();
      } else {
        curveVertex(pn.pos.x, pn.pos.y);
      }
    }

    Pendulum objsTail = objs.get(objs.size()-1);

    curveVertex(objsTail.pos.x, objsTail.pos.y);
    endShape();

  }

  void addPendulum () {
    Pendulum _parent = objs.get(objs.size()-1);
    PVector tail = objs.get(objs.size()-1).pos;
    PVector pretail = objs.get(objs.size()-2).pos;
    PVector extent = PVector.sub(tail,pretail);
    extent.normalize();
    extent.mult(10);
    this.objs.add(new Pendulum(this.a, tail.x+extent.x, tail.y+extent.y, _parent));
  }
  
  void removePendulum() {
    objs.remove(objs.size()-1);
  }
}

// Attaches to another object and acts as a bouncy pendulum.
class Pendulum {

  float a;
  float chaos;
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  Pendulum parent;
  Spring parentSp;
  boolean isParentSp;
  float restLength;

  Pendulum(float _a, float _x, float _y, Pendulum _parent) {
    this.a = _a;
    this.chaos = random(0.1, 0.5);
    this.pos = new PVector(_x, _y);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
    this.mass = 1;
    this.parent = _parent;
    this.isParentSp = false;
    this.restLength = PVector.dist(this.pos, this.parent.pos);
  }

  Pendulum(float _a, float _x, float _y, Spring _parent) {
    this.a = _a;
    this.chaos = random(0.1, 0.5);
    this.pos = new PVector(_x, _y);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
    this.mass = 1;
    this.parentSp = _parent;
    this.isParentSp = true;
    this.restLength = PVector.dist(this.pos, this.parentSp.pos);
  }


  void move() {
    //float frizz = map(frizzSlider.value(), 0, 1, 1, this.chaos);
    float frizz = 0.5;

    // Push down with gravity.
    PVector gravity = new PVector(cos(radians(this.a)), sin(radians(this.a)));
    //gravity.mult(gravitySlider.value());
    gravity.mult(0.5);

    gravity.mult(frizz);
    gravity.div(this.mass);
    this.acc.add(gravity);

    // Add air-drag.
    //this.vel.mult(1-airDragSlider.value());
    this.vel.mult(1-0.2);
    this.vel.limit(5);

    // Move it.
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);

    // Adjust its spring.
    float currentLength;
    PVector spring;

    if (isParentSp) {
      currentLength = PVector.dist(this.pos, this.parentSp.pos);
      spring = new PVector(this.pos.x, this.pos.y);
      spring.sub(this.parentSp.pos);
      spring.normalize();
    } else {
      currentLength = PVector.dist(this.pos, this.parent.pos);
      spring = new PVector(this.pos.x, this.pos.y);
      spring.sub(this.parent.pos);
      spring.normalize();
    }


    float stretchLength = currentLength-this.restLength;
    //spring.mult(-elasticitySlider.value()*stretchLength);
    spring.mult(-0.1*stretchLength);

    spring.div(this.mass);
    this.acc.add(spring);
  }

  void display() {
    if (this.parent != null) {
      strokeWeight(0.5);
      stroke(255, 0, 0);
      if (isParentSp) {
        line(this.parentSp.pos.x, this.parentSp.pos.y, this.pos.x, this.pos.y);
      } else {
        line(this.parent.pos.x, this.parent.pos.y, this.pos.x, this.pos.y);
      }
    }

    strokeWeight(3);
    stroke(0, 255, 0);
    point(this.pos.x, this.pos.y);
  }
}

class Spring {

  PVector pos;
  PVector vel;
  PVector acc;
  PVector target;
  float maxForce;

  Spring(float _x, float _y, float _maxForce) {
    this.pos = new PVector(_x, _y);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
    this.target = new PVector(_x, _y);
    this.maxForce = _maxForce;
  }



  void move () {
    float distThreshold = 200;

    // Move towards the target.
    PVector push = new PVector(this.target.x, this.target.y);
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    float force = map(min(distance, distThreshold), 0, distThreshold, 0, this.maxForce);
    push.sub(this.pos);
    push.normalize();
    push.mult(force);
    this.acc.add(push);

    // Add air-drag.
    //this.vel.mult(1-airDragSlider.value());
    this.vel.mult(1-0.8);
    //  this.vel.mult(1-0.2);

    // Move it.
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void display() {
    strokeWeight(5);
    stroke(0, 255, 0);
    point(this.pos.x, this.pos.y);
  }
}
