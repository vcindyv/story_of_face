

class bubble {
  PVector location;
  PVector acceleration;
  PVector velocity;
  PVector wind;
  PVector gravity;

  float bubbleHeight, bubbleWidth;
  float mass;

  boolean death = false;

  bubble() {
    bubbleHeight = random(5, 20);
    bubbleWidth  = bubbleHeight;

    location = new PVector(random(width), height);
    velocity   = new PVector(0, 0);
    acceleration = new PVector(0, 0);

    wind = new PVector(random(0, 0.004), 0);
    //if(right){
    // wind = new PVector(random(0, 0.004), 0);
    //}
    //else if (left){
    // wind = new PVector(random(-0.004,0), 0);
    //}
    mass = 10/bubbleWidth;                             //** fast if hear!!!
    gravity = new PVector(0, -0.05);
  }

  void display() {
    drawbubble();
    movebubble();
    applyForce(gravity);
    applyForce(wind);
  }

  void drawbubble() {
    noStroke();
    fill(255, 100);
    ellipse(location.x, location.y, bubbleWidth, bubbleHeight);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void movebubble() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    // wind.add(wind);

    if (location.y > height+bubbleHeight) {
      death = true;
    }
  }

  void movewind(int num) {
    switch(num) {
    case 1:
      wind=new PVector(random(-0.6, 0), 0);
      break;

    case 2:
      wind=new PVector(random(-0.3, 0), 0);
      break;

    case 3:
      wind=new PVector(random(0, 0.3), 0);
      break;


    case 4:
      wind=new PVector(random(0, 0.6), 0);
 
    }
  }
}
