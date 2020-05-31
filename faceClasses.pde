class Face {
  // ArrayLists for saving face data temporarily
  ArrayList<PVector> vertices;
  ArrayList<Float> depths; 

  // ArrayList and Array for Delaunay triangulation
  ArrayList<PVector> faceVetices;
  float [][] delaunayPoints;

  // Final face triangles
  ArrayList<Triangle> triangles; 
  IntList randomOrder;

  boolean faceGenerated=false;
  Delaunay delaunay;

  ArrayList<imageCoral> imageCoralGroup = new ArrayList<imageCoral>();
  ArrayList<codeCoral> codeCoralGroup = new ArrayList<codeCoral>();

  int faceDrawn=0;
  int spread =0;
  Triangle currentTriangle=null;
  int currentType = 1;

  Face() {
    triangles = new ArrayList<Triangle>();
    faceVetices  = new ArrayList<PVector>();
    vertices  = new ArrayList<PVector>();
    depths = new ArrayList<Float>();
    randomOrder = new IntList();
  }

  void addTriangle(PVector _p1, PVector _p2, PVector _p3, float _dc) {
    triangles.add(new Triangle(_p1, _p2, _p3, _dc));
  }

  boolean isAddedTriangle(PVector _p1, PVector _p2, PVector _p3) {
    boolean p1in=false, p2in=false, p3in=false, result=false;
    for (Triangle t : triangles) {
      p1in=false; 
      p2in=false; 
      p3in=false;
      for (PVector p : t.points) {
        if (dist (p.x, p.y, _p1.x, _p1.y)==0) {
          p1in=true;
        }
        if (dist (p.x, p.y, _p2.x, _p2.y)==0) {
          p2in=true;
        }
        if (dist (p.x, p.y, _p3.x, _p3.y)==0) {
          p3in=true;
        }
      }
      if (p1in && p2in && p3in)
        result = true;
    } 
    return result;
  }

  void triangulateFace(ArrayList<Float> _faceDepths) {

    for (int i=0; i<delaunayPoints.length; i++) {
      // Draw starting point at i
      float iX = delaunayPoints[i][0];
      float iY = delaunayPoints[i][1];

      int[] firstLinks = delaunay.getLinked(i); // idx of _points linked to point #1

      for (int j=0; j<firstLinks.length; j++) {
        if (firstLinks[j]!=0) {
          // Draw first connected _points at j
          float jX = delaunayPoints[firstLinks[j]][0];
          float jY = delaunayPoints[firstLinks[j]][1];

          int[] secondLinks = delaunay.getLinked(firstLinks[j]);
          for (int k=0; k<secondLinks.length; k++) {
            if (secondLinks[k]!=i && secondLinks[k]!=0) {
              float kX = delaunayPoints[secondLinks[k]][0];
              float kY = delaunayPoints[secondLinks[k]][1];

              for (int l=0; l<firstLinks.length; l++) {
                if (secondLinks[k]==firstLinks[l]) { //  green intersect blue 
                  fill(0, 255, 255);
                  PVector p1 = new PVector(iX, iY);
                  PVector p2 = new PVector(jX, jY);
                  PVector p3 = new PVector(kX, kY);

                  Float p1d = new Float(_faceDepths.get(i));
                  Float p2d = new Float(_faceDepths.get(j));
                  Float p3d = new Float(_faceDepths.get(k));
                  float depthColor = (p1d+p2d+p3d)/3.0;

                  if (isAddedTriangle(p1, p2, p3)==false) 
                    addTriangle(p1, p2, p3, depthColor);
                }
              }
            }
          }
        }
      }
    }
  }

  void generateFace(ArrayList<PVector> _faceVertices, ArrayList<Float> _faceDepths) {
    if (!faceGenerated ) {
      delaunayPoints = new float[_faceVertices.size()][2];

      for (int i=0; i<delaunayPoints.length; i++) {
        PVector fv = _faceVertices.get(i);
        delaunayPoints[i][0] = fv.x;
        delaunayPoints[i][1] = fv.y;
      }
      delaunay = new Delaunay( delaunayPoints );
      if (delaunayPoints.length>0) {
        triangulateFace(_faceDepths);
        for (int i=0; i<triangles.size(); i++)
          randomOrder.append(i);
        randomOrder.shuffle();
        println("[Random Order of coral generation on triangles]");
        println(randomOrder);
        faceGenerated = true;
      } else {
        println("No vertex has passed :(");
        exit();
      }
    }
  }

  void processFaceGeneration(float brightest, float darkest) {

    //raw body data 0-6 users 255 nothing
    int [] bodyData = kinect.getRawBodyTrack();
    int [] rawDepth = kinect.getRawDepthData();

    ArrayList<KSkeleton> skeletonArray  = kinect.getSkeletonDepthMap();
    for (int x=0; x<skeletonArray.size(); x++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(x);
      if (skeleton.isTracked()) {

        KJoint[] joints = skeleton.getJoints();
        int faceX = (int)joints[KinectPV2.JointType_Head].getX();
        int faceY = (int)joints[KinectPV2.JointType_Head].getY();
        int leftShoulderX = (int)joints[KinectPV2.JointType_ShoulderLeft].getX();
        int leftShoulderY = (int)joints[KinectPV2.JointType_ShoulderLeft].getY();
        int rightShoulderX = (int)joints[KinectPV2.JointType_ShoulderRight].getX();
        int rightShoulderY = (int)joints[KinectPV2.JointType_ShoulderRight].getY();

        if (!face.faceGenerated) {
          int cs = 5;
          float minimum=4500, maximum=0;
          for (int i = 0; i < 512; i+=cs) {
            for (int j =0; j<424; j+=cs) {
              int loc = i+512*j;
              if (bodyData[loc]!=255) {

                float d = rawDepth[loc];
                //float dmap = map(d, 0, 4500, 0, 255);
                float distFromFace = dist(faceX, faceY, i, j);

                float wiggle = 0.5;
                if (distFromFace < 50) {
                  if (random(1)<0.6)
                    vertices.add(new PVector(i-faceX+random(-wiggle, wiggle), j-faceY+random(-wiggle, wiggle)));
                  if (d<minimum)  minimum = d;
                  if (d>maximum) maximum = d;
                  depths.add(d);
                } else if (distFromFace < 100) {
                  if (random(1)<0.3)
                    vertices.add(new PVector(i-faceX+random(-wiggle, wiggle), j-faceY+random(-wiggle, wiggle)));
                  depths.add(d);
                }
              }
            }
          }

          for (int i=0; i<8; i++) {
            vertices.add(new PVector( lerp(faceX, leftShoulderX, random(0.5, 1))-faceX, lerp(faceY, leftShoulderY, random(0.1, 0.7))-faceY ));
            depths.add((maximum+minimum)/2);
            vertices.add(new PVector( lerp(faceX, rightShoulderX, random(0.5, 1))-faceX, lerp(faceY, rightShoulderY, random(0.1, 0.7))-faceY ));
            depths.add((maximum+minimum)/2);
          }

          for (int i=0; i<depths.size(); i++) {
            float d = depths.get(i);
            depths.set(i, map(d, minimum, maximum, brightest, darkest));
          }
          println("depth min: "+minimum+", max :"+maximum);
          generateFace(vertices, depths);
        }
      }
    }
  }


  void drawFace(float _x, float _y, float _xs, float _ys) {
    if (faceDrawn<10 && faceGenerated) {
      coralLayer.pushMatrix();
      coralLayer.translate(_x, _y);
      coralLayer.scale(_xs, _ys);
      for (Triangle t : triangles) {
        t.draw();
      }
      coralLayer.popMatrix();
      faceDrawn++;
    }
  }

  void drawCorals(float _x, float _y, float _xs, float _ys) {
    coralLayer.pushMatrix();
    coralLayer.translate(_x, _y);
    coralLayer.scale(_xs, _ys);
    for (imageCoral c : imageCoralGroup) {
      if (c!=null)  
        c.draw();
    }
    for (codeCoral c : codeCoralGroup) {
      if (c!=null)  
        c.updateAndDraw();
    }
    coralLayer.popMatrix();
  }
  void limitNumber(int max) {
    if (codeCoralGroup.size()>max) {
      codeCoralGroup.remove(0);
    }
    if (imageCoralGroup.size()>max) {
      imageCoralGroup.remove(0);
    }
  }

  Triangle getRandomTriangle() {
    Triangle tri = null;
    for (int i=0; i< randomOrder.size(); i++) {
      int t = randomOrder.get(i);
      if (triangles.get(t).coralOn==false) {
        tri = triangles.get(t);
        break;
      }
    }
    return tri;
  }

  Triangle getClosestTriangle(Triangle currentTri) {
    Triangle tri = null;
    float closest = 10000000;
    //println("triangles.size():"+triangles.size());
    for (int i=0; i<triangles.size(); i++) {
      Triangle t = triangles.get(i);
      if (!t.coralOn) {
        if (t.midPoint.dist(currentTri.midPoint)<closest) {
          closest = t.midPoint.dist(currentTri.midPoint);
          tri = t;
        }
      }
    }
    return tri;
  }

  Triangle addImageCoral(float _w, float _h, int coralType, color coralColor, int growLevel) {      
    Triangle tri = getRandomTriangle(); 
    if (tri!=null) {
      tri.coralOn = true;
      imageCoralGroup.add(new imageCoral(tri.midPoint.x, tri.midPoint.y, _w, _h, coralType, coralColor, growLevel));
    }
    return tri;
  }  
  Triangle addImageCoral(float _w, float _h, int coralType, color coralColor, int growLevel, Triangle currTri) {      
    if (currTri!=null) {
      currTri.coralOn = true;
      imageCoralGroup.add(new imageCoral(currTri.midPoint.x, currTri.midPoint.y, _w, _h, coralType, coralColor, growLevel));
    }
    return currTri;
  } 

  void addCodeCoral(float _thickness, float _radius, float _cellNum) {      
    Triangle tri = getRandomTriangle(); 
    if (tri!=null) {
      tri.coralOn = true;
      codeCoralGroup.add(new codeCoral(tri.midPoint.x, tri.midPoint.y, _thickness, _radius, _cellNum));
    }
  }

  void addCoralRegion(float heartRate, float heartRateMin, float heartRateMax, float GSR, float GSRMin, float GSRMax) {
    float w = map(heartRate, heartRateMin, heartRateMax, 8, 18);
   // float w = heartRate;
    float h = w*0.8;
    float brightness = map(GSR, GSRMin, GSRMax, 180, 255);

    int growLevel = (int)random(0, 4);
    if (spread ==0) {
      currentType = (int)random(1, 6); //CORAL 5 !!
      currentTriangle = addImageCoral(w, h, currentType, color(brightness), growLevel);
      spread = (int)random(4, 9);
      //println("spread: "+spread);
    } else if (spread >0) {
      Triangle closestTriangle = getClosestTriangle(currentTriangle);
      addImageCoral(w, h, currentType, color(brightness), growLevel, closestTriangle);
      spread--;
      //println("add subsequent coral"+" spread: "+spread);
    }
  }
}

class Triangle {
  PVector[] points;
  PVector midPoint;
  color col;
  float depthColor;
  boolean coralOn;

  Triangle(PVector p1, PVector p2, PVector p3, float _depthColor) {
    float dw = 512, dh=424;
    points = new PVector[3];
    for (int i=0; i<points.length; i++) 
      points[i] = new PVector(0, 0);
    points[0].x = p1.x;
    points[0].y = p1.y;
    points[1].x = p2.x;
    points[1].y = p2.y;
    points[2].x = p3.x;
    points[2].y = p3.y;
    midPoint = new PVector(p1.x/3+p2.x/3+p3.x/3, p1.y/3+p2.y/3+p3.y/3);
    depthColor = _depthColor;
    col = color(_depthColor);
    coralOn = false;
  }
  void draw () {
    //coralLayer.smooth(8);
    //coralLayer.stroke(col);
    coralLayer.noStroke();
    coralLayer.fill(col);
    coralLayer.triangle(points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
  }
}

class imageCoral {
  float x, y, w, h;
  int growLevel, finalGrow;
  color coralColor;
  float alpha;
  int coralNum;
  float angle;

  imageCoral(float _x, float _y, float _w, float _h, int _coralNum, color _coralColor, int _growLevel) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    growLevel = _growLevel;
    coralColor = _coralColor;
    coralNum = _coralNum;
    angle = random(-0.1, 0.1);
  }

  void draw() {
    if (alpha<255) {
      coralLayer.pushMatrix();
      coralLayer.translate(x, y);
      coralLayer.rotate(angle);
      coralLayer.tint(coralColor, alpha);
      if (coralNum==1) {
        coralLayer.image(growingCoral1[growLevel], -w/2, -h/2, w, h);
      } else if (coralNum==2) {
        coralLayer.image(growingCoral2[growLevel], -w/2, -h/2, w, h);  // center mode
      } else if (coralNum==3) {
        coralLayer.image(growingCoral3[growLevel], -w/2, -h/2, w, h);  // center mode
      } else if (coralNum==4) {
        coralLayer.image(growingCoral4[growLevel], -w/2, -h/2, w, h);  // center mode
      } else if (coralNum==5) {
        coralLayer.image(growingCoral5[growLevel], -w/2, -h/2, w, h);  // center mode
      }
      coralLayer.popMatrix();
      alpha++;
    } else {
      if (growLevel<3) {
        alpha = 0;
        growLevel++;
      }
    }
  }
}

class codeCoral {
  float x, y, xs, ys;
  float scaleValue, rotateValue;
  PVector [] ap;
  float minRad=1, maxRad= 1;
  float thickness;
  float distanceToCenter;
  float distance;
  float newR; 
  float newX; 
  float newY;
  int cellNum;
  color startColor = color(204, 102, 0);
  float endHue;

  codeCoral(float _x, float _y, float _thickness, float _radius, float _cellNum) {
    x = _x;
    y=_y;
    xs=1;
    ys=1;
    thickness=_thickness;
    maxRad = _radius;
    cellNum = (int)_cellNum;
    ap = new PVector[0];
    for (int i=0; i<1; i++) {
      ap = (PVector []) append(ap, new PVector (width/2, height/2, random (minRad, maxRad)));
      //colorMode( RGB, 1000); //colorMode(HSB, 600);
    }
    scaleValue = 0.001*_radius;
    rotateValue = random(-0.1, 0.1);
    minRad = 1;

    int ranStart = (int)random(4);
    switch(ranStart) {
    case 0:
      startColor = color(#D3D3B7);
      break;
    case 1:
      startColor = color(#CAD3B7);
      break;
    case 2:
      startColor = color(#D3C2B7);
      break;
    case 3:
      startColor = color(#D3CFB7);
      break;
    default:
      startColor = color(#CAD3B7);
    }
    endHue = random(255);
  }

  void updateAndDraw() {
    if (ap.length<cellNum) {
      for (int s=0; s<500; s++) { 
        newR = maxRad;
        newX = random(newR, width-newR);
        newY = random(newR, height/2-newR);
        distanceToCenter = dist (newX, newY, width/2, height/2);
        if (distanceToCenter +  50 *cos(distanceToCenter/ sqrt(distanceToCenter /100)) < 250 &&
          distanceToCenter +  50 *cos(distanceToCenter/ sqrt(distanceToCenter /100)) > 50) {
          float closestDist = 100000000;
          int closestIndex = 0;
          // which circle is the closest?
          for (int i=0; i < ap.length; i++) {
            distance = dist(newX, newY, ap[i].x, ap[i].y);
            if (distance < closestDist)
            {
              closestDist = distance;
              closestIndex = i;
            }
            if (distance < 5) //quit sooner
            {
              i = ap.length;
            }
          } 
          if (distance > 0) { // avoid branches touching one another
            // aline it to the closest circle outline
            float angle = atan2(newY-ap[closestIndex].y, newX-ap[closestIndex].x);
            //      float deltaX = cos(angle) * ap [closestIndex].z;
            //      float deltaY = sin(angle) * ap [closestIndex].z;
            float deltaX =  cos((angle+frameCount)*3 ); // the spiral //+ log(distanceToCenter)*12
            float deltaY =  sin((angle+frameCount)*3 );
            // draw them
            //for (int i=0 ; i < ap.length; i++) {
            //}
            newR =  exp( map (closestDist, 0, width, 1.6, 12) ) * 2/sqrt(distanceToCenter/10)  ;
            newX = ap[closestIndex].x  + 1*deltaX; 
            newY = ap[closestIndex].y  + 1*deltaY; 
            if (ap.length<cellNum)  ap = (PVector []) append (ap, new PVector (newX, newY, newR ));
            int i= closestIndex;

            //coralLayer.stroke( i%ap.length/2+50, i %ap.length/10, i %ap.length/+50);   //fill 3 10 2
            //fill 3 10 2

            coralLayer.strokeWeight(ap[i].z*thickness); 
            coralLayer.pushMatrix();
            coralLayer.translate(x-width/2*xs*scaleValue, y-height/2*ys*scaleValue);
            coralLayer.rotate(rotateValue);
            coralLayer.scale(xs*scaleValue, ys*scaleValue);
            coralLayer.stroke(startColor); // start hue
            coralLayer.line(ap[i].x, ap[i].y, newX, newY ) ;
            coralLayer.stroke( endHue, i %ap.length/10*0.1+20, 255, i %ap.length/10*0.2);
            coralLayer.line(ap[i].x, ap[i].y, newX, newY ) ; // end hue
            coralLayer.popMatrix();
          }
        }
      }
    }
  }
}
