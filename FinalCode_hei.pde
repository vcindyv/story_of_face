//ROCK + DEPTH + NOT EYETRACK +  (NEED SANHO CODE , CLASS , METHOD  + ARDUINO) 

//float heartRate = (int)random(80, 100);

      // ** RESETTING NUMBER 
      
      float heartRateMin=50;
      float heartRateMax=130;
     
      float GSRMin =200;
      float GSRMax = 550;


//seaweed
final int nb = 20;

PVector rootNoise = new PVector(random(123456), random(123456));
int mode = 0;


//coralLayer Background
float noiseScale = 0.02;
PImage img;
PImage img2;

PGraphics coralLayer; //coralLayer == others

//Bubble
import java.util.*;
ArrayList<bubble> bubbles;

//Fish
ArrayList<Particle_Fish> particles_Fish = new ArrayList<Particle_Fish>();
int particleCount = 20; //number of fishes
int maxHistoryCount = 12; //fish length
float maxSize = 1.75;
float force = 0;


import gazetrack.*;
GazeTrack gazeTrack;

import signal.library.*;
SignalFilter myFilter;
SignalFilter myFilter2;

float freq      = 120.0;
float minCutoff = 0.01; // decrease this to get rid of slow speed jitter
float beta      = 6.0;  // increase this to get rid of high speed lag
float dcutoff   = 1.0;

//jellyFish for coralLayer

ArrayList<Creature> creatures = new ArrayList<Creature>();
//var ropes = [];
int collisionSize = 100;         //** JuellyFish Sensitive default = 100 
boolean debugMode = false;

//// for generating rock face (with delaunay triangulation) 
import megamu.mesh.*;
Face face = new Face();
ArrayList<PVector> vertices  = new ArrayList<PVector>();
ArrayList<Float> depths = new ArrayList<Float>();

//Kinect => Scale + Face Rock 
int ScaleNum=800; //Scale match
import KinectPV2.*;
import KinectPV2.KJoint;
KinectPV2 kinect;


//PImage [] coralImages = new PImage[18]; //**sanho IMAGE
PImage [] growingCoral1 = new PImage[4]; //sanho with 4 images
PImage [] growingCoral2 = new PImage[4]; //sanho with 4 images
PImage [] growingCoral3 = new PImage[4]; //sanho with 4 images
PImage [] growingCoral4 = new PImage[4]; //sanho with 4 images
PImage [] growingCoral5 = new PImage[4]; //sanho with 4 images

float jellyfishScale=1;
float addStart=0;

// ARDUINO

import processing.serial.*;
Serial myPort; 
String mssg;
int raw_Data;
int heartRate;
int GSR;
int count=0;
int BPM_Sum=0; //heartRate
int GSR_Sum=0;



void setup() {
  size(1280,720, P3D);
  
  //fullScreen(P3D);

  ellipseMode(CENTER);
  noStroke();
  smooth(8);
  frameRate(30);

  //Coral
  coralLayer = createGraphics(1280, 1024);
  
  //**background png
  img =loadImage("background4-2.png");   
  img2 =loadImage("light4.png");


  //Bubble_Code
  bubbles = new ArrayList<bubble>();
  loadbubble();

  //Fish_Code
  reset();

  gazeTrack = new GazeTrack(this);




  //jellyFish 
  for (int i=1; i<8; i++) {
    creatures.add(new Creature(random(width), random(height), (int)random(3, 6), (int)random(8, 16)));
    // Creature(x, y, legLength, legNum)
  }

  //Kinect
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true);
  kinect.enableBodyTrackImg(true);
  kinect.init();

  coralLayer.beginDraw();  
  coralLayer.background(0, 0);  
  coralLayer.endDraw();

  //for (int i=0; i<coralImages.length; i++) {
  //  coralImages[i] = loadImage("sanho/sanho_"+(i+1)+".png");
  //}
  
  for (int i=0; i<4; i++) {
    growingCoral1[i] = loadImage("sanho_grow/color_sanho_10-"+(i+1)+".png");
  }
  for (int i=0; i<4; i++) {
    growingCoral2[i] = loadImage("sanho_grow/color_sanho_12-"+(i+1)+".png");
  }
  for (int i=0; i<4; i++) {
    growingCoral3[i] = loadImage("sanho_grow/color_sanho_23-"+(i+1)+".png");
  }
  for (int i=0; i<4; i++) {
    growingCoral4[i] = loadImage("sanho_grow/color_sanho_06-"+(i+1)+".png");
  }
  for (int i=0; i<4; i++) {
    growingCoral5[i] = loadImage("sanho_grow/color_sanho_03-"+(i+1)+".png");
  }
  
  //ARDUINO
  String[] portList = Serial.list();
  myPort = new Serial(this, portList[0], 9600);
}

void draw() { 
  
  //list[0] = GSR list[1] = HeartRate 
  // if ( myPort.available() > 0) {
  try {
              mssg = myPort.readStringUntil('\n');
          
              if (mssg!=null) {
          
                mssg=trim(mssg);
                String[] list = split(mssg, ',');
          
                //if (int(list[1])<30 || int(list[1])>180) 
                //{
                //  heartRate = (int)random(70, 85);
                //} 
                
                //else {
                //  heartRate = int(list[1]);
                //}
                
          
                GSR = int(list[0]);
                heartRate = int(list[1]);
          
                if (count==50) {
                  GSR_Sum=GSR_Sum/50;
                  BPM_Sum=BPM_Sum/50;
                  println("        GSR_Average "+GSR_Sum+"  BPM_Average"+BPM_Sum);
                } else {
                  GSR_Sum= GSR_Sum+GSR;
                  BPM_Sum= BPM_Sum+heartRate;
                  count++;
                }
                //Average
              }
              println("GSR"+GSR+"Heart:"+heartRate);
  }
  
  catch(Exception e) {
    //DO NOTHING AND KEEP GOING
  }
  
  layer1();


  // for rock face generation
  coralLayer.beginDraw();
  coralLayer.colorMode(HSB);
  coralLayer.smooth(8);
  face.processFaceGeneration(200, 100); // Brightest color: 200, Darkest color: 100
  face.drawFace(width*0.5, height*0.7, 10, 12);

  face.drawCorals(width*0.5, height*0.7, 10, 12);  
  face.limitNumber(5);
  

  float runningTime = 900; // 900 seconds (= 15 minutes) running time   // RESETTING NUMBER
  
  if (face.faceGenerated) {
    float addDuration = runningTime*1000/face.triangles.size();
    if (millis()-addStart>addDuration) {
      
      


      face.addCoralRegion(heartRate, heartRateMin, heartRateMax, GSR, GSRMin, GSRMax);
      //void addCoralRegion(float heartate, float heartRateMin, float heartRateMax, float GSR, float GSRMin, float GSRMax)
      addStart = millis();
    }
  }
 
 
      
      
  coralLayer.endDraw();
  tint(255);
  image(coralLayer, 0, 0);


   Light();
   Bubble();
   Fish();
   jellyfish();
   Scale();

  if (GSR <300) { // LONG   // RESETTING NUMBER
    for (int i=0; i<creatures.size(); i++ ) {
      for (int j=0; j<creatures.get(i).ropes.size(); j++ ) {
        if (creatures.get(i).ropes.get(j).objs.size()<35) {
          creatures.get(i).ropes.get(j).addPendulum();
        }
      }
    }
  }
  if ( GSR >350) { //SHORT    // RESETTING NUMBER
    for (int i=0; i<creatures.size(); i++ ) {
      for (int j=0; j<creatures.get(i).ropes.size(); j++ ) {
        if (creatures.get(i).ropes.get(j).objs.size()>3) {
          creatures.get(i).ropes.get(j).removePendulum();
        }
      }
    }
  }
  
  pushMatrix();
  fill(255);
  float m = millis();
  text("Time  "+m, width-100, height-100);
  text("Frame "+frameRate, width-100, height-80);
  text("GSR   "+GSR, width-100, height-60);
  text("BPM   "+heartRate, width-100, height-40);
  popMatrix();
  
  //float time = millis()/1000;
  //saveFrame("file1/"+time+"test4"+"########.tif");
}

void layer1() {

  background(0);
  image(img, 0, 0, width, height);
  float f = map(gazeTrack.getGazeY(), 0, height, 255, 100);   //** FADE DARKNESS 
  tint(f, 200);
  image(img, 0, 0, width, height);
}




void Light() {

  float s = random(0, 10); //noisevariation
  float m = map(gazeTrack.getGazeX(), 0, width, 0, 100);
  for (int i=0; i<width; i++) { //light
    float noiseVal = noise((i+m)*noiseScale, s*noiseScale);
    this.stroke(noiseVal*200, 50); 
    this.line(i*2, height*2, i, 0);
  }
}

void cell() {

  image(img2, gazeTrack.getGazeX()-180, gazeTrack.getGazeY()-220);
} // draw() 

void Bubble() {
  if ((frameCount % 3) == 0) {
    addbubble();
  }


  drawbubble();
  for (int i = 0; i < bubbles.size(); i++) {
    bubble s = bubbles.get(i);
    if (s.death) {
      bubbles.remove(s);
    }
  }
}
void loadbubble() {
  for (int i = 0; i < 1; i++) {
    bubbles.add(new bubble());
  }
}

void drawbubble() {
  for (bubble s : bubbles) {
    s.display();
  }
}


void addbubble() {
  bubbles.add(new bubble());
}

void windbubble() {
}


void Fish() {

  //colorMode(HSB,360);
  noFill();
  stroke(50, 100);
  strokeWeight(4);
  if (mousePressed) {
    force+=0.1;
  }

  for (int i = 0; i < particles_Fish.size(); i++) {
    particles_Fish.get(i).move();
    particles_Fish.get(i).display(ScaleNum);
  }
}


void keyPressed() {
  if (key == 'w') { //FISH ADD
    for (int i = 0; i < 10; i++) {
      particles_Fish.add(new Particle_Fish());
    }
  } else if (key == 's') { //FISH DELETE
    for (int i = 0; i < 10; i++) {
      if (particles_Fish.size() == 0) {
        return;
      }
      int index = int(random(particles_Fish.size()));
      particles_Fish.remove(index);
    }
  }

  if (key == ' ') {  // ** SPACE 
    int w = (int)random(5, 10);
    int h = w;
    int coralNum = (int)random(1, 4);
    int coralGrow = (int)random(4);
    face.addImageCoral(w, h, coralNum, color(random(150, 255)), coralGrow);        //coral
  }

  if (key == 'a') {  // 
    float heartRate = (int)random(80, 100);
    float heartRateMin=80; 
    float heartRateMax=120;
    float GSR = 200;
    float GSRMin = 200;   
    float GSRMax = 450;
    face.addCoralRegion(heartRate, heartRateMin, heartRateMax, GSR, GSRMin, GSRMax);        //coral
  }
  



  if (keyCode == ENTER) { 
    float thickness = random(1, 7); // Thickness of branches 
    float radius = random(20, 40);  // Size of Coral
    float cellNumber = random(5000, 20000);  // More cellnumber == brighter color 

    face.addCodeCoral(thickness, radius, cellNumber);
  }
  
  if (keyCode == UP) {
    for (int i=0; i<creatures.size(); i++ ) {
      for (int j=0; j<creatures.get(i).ropes.size(); j++ ) {

        creatures.get(i).ropes.get(j).addPendulum();
      }
    }
  }
  if (keyCode == DOWN) {
    for (int i=0; i<creatures.size(); i++ ) {
      for (int j=0; j<creatures.get(i).ropes.size(); j++ ) {
        if (creatures.get(i).ropes.get(j).objs.size()>3) {
          creatures.get(i).ropes.get(j).removePendulum();
        }
      }
    }
  }
  
  
}




void reset() {
  particles_Fish.clear();

  for (int i = 0; i < particleCount; i++) {
    particles_Fish.add(new Particle_Fish());
  }
} //Fish Code








void jellyfish() {

  // Display collision object.
  noStroke();
  //fill(255, 50);
  ellipse(gazeTrack.getGazeX(), gazeTrack.getGazeY(), collisionSize*2-150, collisionSize*2-150);

  float nFreq = 0.05;
  float nSpeed = 20;

  for (int c = 0; c < creatures.size(); c++) {
    Creature cre = creatures.get(c);

    // Move creature randomly.
    float nx = noise(cre.fOffset+frameCount*nFreq)*nSpeed-nSpeed*0.5;
    float ny = noise(cre.fOffset+1000+frameCount*nFreq)*nSpeed-nSpeed*0.5;

    if (cre.dir.x > 0) {
      cre.pos.x += nx;
    } else {
      cre.pos.x -= nx;
    }

    if (cre.dir.y > 0) {
      cre.pos.y += ny;
    } else {
      cre.pos.y -= ny;
    }

    // Keep it in-bounds.
    if (cre.pos.x < 0) {
      cre.pos.x = 0;
      cre.dir.x *= -1;
    } else if (cre.pos.x > width) {
      cre.pos.x = width;
      cre.dir.x *= -1;
    }

    if (cre.pos.y < 0) {
      cre.pos.y = 0;
      cre.dir.y *= -1;
    } else if (cre.pos.y > height) {
      cre.pos.y = height;
      cre.dir.y *= -1;
    }

    // React against collision object.
    for (int i = 0; i < cre.ropes.size(); i++) {
      Rope rp = cre.ropes.get(i);

      for (int j = 0; j < rp.objs.size(); j++) {
        Pendulum pn = rp.objs.get(j);
        float d = dist(gazeTrack.getGazeX(), gazeTrack.getGazeY(), pn.pos.x, pn.pos.y);

        if (d < collisionSize) {
          // Push ball away from collision object.
          PVector force = new PVector(pn.pos.x, pn.pos.y);
          force.sub(gazeTrack.getGazeX(), gazeTrack.getGazeY());
          force.normalize();
          force.mult(1);
          pn.acc.add(force);
        }

        Spring sp = rp.objsHead;
        float d2 = dist(gazeTrack.getGazeX(), gazeTrack.getGazeY(), sp.pos.x, sp.pos.y);

        if (d2 < collisionSize) {
          // Push ball away from collision object.
          PVector force = new PVector(sp.pos.x, sp.pos.y);
          force.sub(gazeTrack.getGazeX(), gazeTrack.getGazeY());
          force.normalize();
          force.mult(2);
          sp.acc.add(force);
        }
      }

      Spring sp = rp.objsHead;
      sp.pos = PVector.lerp(sp.pos, cre.pos, 0.02);

      rp.display();
    }

    //cre.display();
  }
}


void Scale() {

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();


  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      {
        KJoint[] joints = skeleton.getJoints();
        fill(255, 0, 0);
        float HeadX = joints[KinectPV2.JointType_Head].getX();
        float HeadY = joints[KinectPV2.JointType_Head].getY(); //get x,y

        int [] rawData = kinect.getRawDepthData();

        int x = (int)HeadX;
       // text(x, 300, 300);
        //int x = mouseX;
        int y = (int)HeadY;
        try {
          int loc= x + 512*y; // width of depth image
          int depthAtXY = rawData[loc];
          ScaleNum = depthAtXY;
          pushMatrix();
          fill(255);
          text("Depth "+depthAtXY, width-100, height-20);
          popMatrix();
         // ellipse(x, y, 30, 30);

          if (x < 260) {
            for (int k = 0; k < bubbles.size(); k++) {
              bubbles.get(k).movewind(1);
            }
          } else if (x<270) {
            for (int k = 0; k < bubbles.size(); k++) {
              bubbles.get(k).movewind(2);
            }
          } else if (280<x) {
            for (int k = 0; k < bubbles.size(); k++) {
              bubbles.get(k).movewind(3);
            }
          } else if (290<x) {
            for (int k = 0; k < bubbles.size(); k++) {
              bubbles.get(k).movewind(4);
            }

            //}
            //else {
            //for (int k = 0; k < bubbles.size(); k++) {
            //    bubbles.get(k).movewind(5);
            //  }
          }
        }
        catch(ArrayIndexOutOfBoundsException e) {

          ScaleNum=500;
        }
      }
    }
  }
}
