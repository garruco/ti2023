import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture video;
OpenCV opencv;

Serial myPort;
float joystickXVal, joystickYVal, dial1Val, dial2Val, ldrVal;
int buttonState;
float rotationAngle = 0;
PShape svg;
ArrayList<Module> mod = new ArrayList<Module>();

int n_modules = 15;
PShape modules[] = new PShape[n_modules];
int gridSize = 3;
int cellSize;

int gridX = 1, gridY = 1;
int moduleIndex;

color[] referenceColors = {color(255, 0, 0), color(0, 255, 102), color(0, 77, 255)};
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

  if (video.available()) {
    video.read();
  }
  opencv.loadImage(video);
  image(video, 0, 0);

  int centerPixel = video.pixels[video.width/2 + video.height/2*video.width];
  selectedColor = findClosestColor(centerPixel);

  fill(selectedColor);
  ellipse(width/2, height/2, 100, 100);

  // Detecting bright spots
  opencv.threshold(200);  // Change this value to match your flashlight brightness

  // Finding contours
  for (Contour contour : opencv.findContours()) {
    contour.draw();
    float area = contour.area();
    println("Area: " + area);

    // If the contour area is large, print hello
    if (area > 100) {  // Change this value to match your flashlight area
      Rectangle boundingRect = contour.getBoundingBox();
      int centroidX = boundingRect.x;
      int centroidY = boundingRect.y ;
      gridX = (int) ((centroidX) / (cellSize));
      gridY = (int) ((centroidY) / (cellSize));

      println(centroidX, centroidY);

      gridX = constrain(gridX, 0, gridSize - 1);
      gridY = constrain(gridY, 0, gridSize - 1);


      //println("Hello, grid position: (" + gridX + ", " + gridY + ")");
    }


    println(buttonState);
    shapeMode(CORNER);


    int rotationCount = round(map(dial1Val, 0, 1023, 0, 3));
    moduleIndex = int(map(dial2Val, 0, 1023, 0, n_modules - 1));
    drawCurrentModule(gridX, gridY, rotationCount, color(selectedColor,50), moduleIndex, cellSize, cellSize);


    if (area > 1000) {  // Change this value to match your flashlight area
      Module newMod = new Module(gridX, gridY, selectedColor, rotationCount, moduleIndex);
      mod.add(newMod);
      delay(1000);
    }

    if (buttonState == 1) {
      save("artboard.png");
      delay(500);
    }
  }
  for (int v = 0; v < mod.size(); v++) {
    mod.get(v).display();
  }
}

void serialEvent(Serial myPort) {
  try {
    String dataString = myPort.readStringUntil('\n');
    if (dataString != null) {
      String[] data = dataString.trim().split(",");
      joystickXVal = float(data[0]);
      joystickYVal = float(data[1]);
      dial1Val = float(data[2]);
      dial2Val = float(data[3]);
      ldrVal = float(data[4]);
      buttonState = int(data[5]);
    }
  }
  catch (RuntimeException e) {
    e.printStackTrace();
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
