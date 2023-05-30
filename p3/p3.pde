import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture video;
OpenCV opencv;
Serial myPort;

boolean debug = false;

float counter, counter2;
int buttonState;
float rotationAngle = 0;
PShape svg;
ArrayList<Module> mod = new ArrayList<Module>();

int lightAreaThreshold = 1890; //area needed to stamp shape

int n_modules = 15;
PShape modules[] = new PShape[n_modules];
int moduleIndex;

int gridSize = 3;
int cellSize;
boolean printLastFrame = false;

int gridX = 1, gridY = 1;

color[] referenceColors = {color(8, 8, 11), color(6, 22, 46), color(5, 40, 42), color(48, 18, 22)};
color[] realColors = {color(15, 21, 35), color(42, 37, 138), color(47, 82, 71), color(236, 38, 38)};
String[] charColors = {"U", "P", "O", "I"};
int selectedColor;

void setup() {
  size(900, 900);
  rectMode(CENTER);

  video = new Capture(this, 900, 900);
  opencv = new OpenCV(this, 900, 900);
  video.start();

  for (int i = 0; i < modules.length; i++) {
    modules[i] = loadShape("modules/" + i + ".svg");
    modules[i].disableStyle();
  }

  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');
  cellSize = floor(width / gridSize);
}

void draw() {
  background(255, 255, 255);
  //println(mouseX + "   " + mouseY);

  pushMatrix();

  translate(width/2, height/2);
  rotate(HALF_PI);
  scale(1, -1);
  translate(-width/2, -height/2);


  if (video.available()) {
    video.read();
  }
  opencv.loadImage(video);
  image(video, 0, 0);


  int pixelPos = 700 + (video.height/2 * video.width);
  int centerPixel = video.pixels[pixelPos]; //700
  //video.pixels[pos] = color(255);
  //video.updatePixels();


  int pixelColorIndex = findClosestColor(centerPixel);
  if (realColors[pixelColorIndex] != selectedColor) {
    selectedColor = realColors[pixelColorIndex];
    myPort.write(charColors[pixelColorIndex]);
  }


  fill(selectedColor);
  ellipse(width/2, height/3, 100, 100);

  // Detecting bright spots
  opencv.threshold(200);  // Change this value to match your flashlight brightness

  // Finding contours
  for (Contour contour : opencv.findContours()) {
    contour.draw();
    float area = contour.area();
    if (debug)
      println("Area: " + area);

    // If the contour area is large, print hello
    if (area > 100) {  // Change this value to match your flashlight area
      Rectangle boundingRect = contour.getBoundingBox();
      int centroidX = boundingRect.x;
      int centroidY = boundingRect.y ;

      /*if(abs(centroidX - 462) < 60) break;
       if(abs(centroidY - 531) < 60) break;*/

      PVector currentCell = getCurrentCell(centroidX, centroidY);
      gridX = (int) currentCell.x;
      gridY = (int) currentCell.y;

      if (debug)println(centroidX, centroidY);

      gridX = constrain(gridX, 0, gridSize - 1);
      gridY = constrain(gridY, 0, gridSize - 1);


      //println("Hello, grid position: (" + gridX + ", " + gridY + ")");
    }


    //println(buttonState);
    shapeMode(CORNER);


    int rotationCount = int(counter2);
    moduleIndex = (int) counter;
    drawCurrentModule(gridX, gridY, rotationCount, color(selectedColor, 50), moduleIndex, cellSize, cellSize);

    if (area > lightAreaThreshold && !printLastFrame) {  // Change this value to match your flashlight area
      Module newMod = new Module(gridX, gridY, selectedColor, rotationCount, moduleIndex);
      mod.add(newMod);
      printLastFrame = true;
    } else if (area < 1000)
      printLastFrame=false;

    if (buttonState == 1) {
      save("artboard.png");
      delay(500);
    }
  }
  for (int v = 0; v < mod.size(); v++) {
    mod.get(v).display();
  }

  popMatrix();
}

void serialEvent(Serial myPort) {
  try {
    String dataString = myPort.readStringUntil('\n');
    if (dataString != null) {
      String[] data = dataString.trim().split(",");
      /*for (int i = 0; i < data.length; i++) {
       println(i + " " + data[i]);
       }*/
      if (!Float.isNaN(float(data[0]))) counter = float(data[0]);
      if (!Float.isNaN(float(data[1]))) counter2 = float(data[1]);
    }
  }
  catch (RuntimeException e) {
  }
}

void drawCurrentModule(int gridX, int gridY, int rotationCount, color selectedColor, int moduleIndex, float width, float height) {
  pushMatrix();

  switch (rotationCount) {
  case 0:
    translate(0, 0);
    break;
  case 1:
    translate(cellSize, 0);
    break;
  case 2:
    translate(cellSize, cellSize);
    break;
  case 3:
    translate(0, cellSize);
    break;
  }

  translate(gridX * cellSize, gridY * cellSize);

  rotate(rotationCount * HALF_PI);

  noStroke();
  fill(selectedColor);
  shape(modules[moduleIndex], 0, 0, width, height);
  popMatrix();
}

PVector getCurrentCell(float _centroidX, float _centroidY) {
  int currentX = 2;
  int currentY = 2;

  //println("X: " + _centroidX + "   Y: " + _centroidY);

  float xPaddingLeft = 220;
  float xPaddingRight = 230;
  float yPaddingTop = 35;
  float yPaddingBottom = 80;

  /*
  stroke(255,0,0);
   line(xPaddingLeft, 0, xPaddingLeft, height);
   line(width - xPaddingRight, 0, width - xPaddingRight, height);
   
   line(0, yPaddingTop, width, yPaddingTop);
   line(0, height - yPaddingBottom, width, height - yPaddingBottom);
   */

  int nGaps = 3;

  float xGap = (width - xPaddingLeft - xPaddingRight) / nGaps;
  float yGap = (height - yPaddingTop - yPaddingBottom) / nGaps;


  for (int i = 0; i < nGaps; i ++) {
    float currentCheckingX = xPaddingLeft + (i+1) * xGap;
    if (_centroidX < currentCheckingX) {
      currentX = i;
      break;
    }
  }

  for (int i = 0; i < nGaps; i ++) {
    float currentCheckingY = yPaddingTop + (i+1) * yGap;
    if (_centroidY < currentCheckingY) {
      currentY = i;
      break;
    }
  }

  return new PVector(currentX, currentY);
}

void mousePressed() {
  export();
}

void export() {
  mod = new ArrayList<Module>();
}
