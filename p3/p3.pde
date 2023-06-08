// Import necessary libraries
import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

// Declare global variables for webcam capture, image processing, serial communication, and design
Capture video;
OpenCV opencv;

Serial myPort;
float counter, counter2;
float buttonState;
float rotationAngle = 0;
PShape svg;
ArrayList<Module> mod = new ArrayList<Module>();

boolean debug = false; // Debug mode

int lightAreaThreshold = 700; // Threshold of area needed to stamp shape

// Variables for modules
int n_modules = 15;
PShape modules[] = new PShape[n_modules];
int gridSize = 3;
int cellSize;
boolean printLastFrame = false;

// Variables for grid position
int gridX = 1, gridY = 1;
int moduleIndex;

// Define colors
color[] referenceColors = {color(8, 8, 11), color(6, 22, 46), color(5, 40, 42), color(48, 18, 22)}; // Reference colors for the computer vision to compare
color[] realColors = {color(15, 21, 35), color(42, 37, 138), color(47, 82, 71), color(236, 38, 38)}; // Real Colors to convert from  the reference colors
String[] charColors = {"U", "P", "O", "I"}; // Characters to send via serial to arduino for the RGB LED to light up
int selectedColor;

void setup() {
  size(900, 900);
  rectMode(CENTER);

  // Start the video capture and OpenCV
  video = new Capture(this, 900, 900);
  opencv = new OpenCV(this, 900, 900);
  video.start();

  // Load the SVG shapes
  for (int i = 0; i < modules.length; i++) {
    modules[i] = loadShape("modules/" + i + ".svg");
    modules[i].disableStyle();
  }

  // Initialize the serial port
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');
  cellSize = floor(width / gridSize);
}

void draw() {
  background(255, 255, 255);

  // Apply a series of transformations so the result you see is aligned with the object you are controlling
  pushMatrix();
  translate(width/2, height/2);
  rotate(HALF_PI);
  scale(1, -1);
  translate(-width/2, -height/2);

  // Process the video
  if (video.available()) {
    video.read();
  }
  opencv.loadImage(video);  // Load video into OpenCV for processing
  if (debug) image(video, 0, 0); // Display the video frame if debug mode is on

  // Display all the modules
  for (int v = 0; v < mod.size(); v++) {
    mod.get(v).display();
  }

  // Code for color detection and shape stamping
  int pixelPos = 700 + (video.height/2 * video.width);
  int centerPixel = video.pixels[pixelPos];

  int pixelColorIndex = findClosestColor(centerPixel);
  if (realColors[pixelColorIndex] != selectedColor) {
    selectedColor = realColors[pixelColorIndex];
    myPort.write(charColors[pixelColorIndex]);
  }

  // If the debug mode is on, draw a circle with the selected color
  if (debug) {
    fill(selectedColor);
    ellipse(width/2, height/3, 100, 100);
  }

  // Apply a threshold to the image to detect bright spots
  opencv.threshold(200);  // Change this value to match your flashlight brightness

  // Find the contours of the bright spots in the image
  for (Contour contour : opencv.findContours()) {
    if (debug) contour.draw();
    float area = contour.area();

    if (debug)println("Area: " + area); // If debug mode is on, print the area to the console

    // If the area of the contour is larger than a number defined (i.e., it's likely a flashlight)
    if (area > 500) {  // Change this value to match your flashlight area

      Rectangle boundingRect = contour.getBoundingBox();

      int centroidX = boundingRect.x;
      int centroidY = boundingRect.y ;

      // Get the current grid cell based on the centroid
      PVector currentCell = getCurrentCell(centroidX, centroidY);
      gridX = (int) currentCell.x;
      gridY = (int) currentCell.y;

      if (debug)println(centroidX, centroidY);  // If debug mode is on, print the centroid to the console

      // Constrain the grid position to within the grid
      gridX = constrain(gridX, 0, gridSize - 1);
      gridY = constrain(gridY, 0, gridSize - 1);


      if (debug) println("grid position: (" + gridX + ", " + gridY + ")");
    }

    shapeMode(CORNER);

    // Determine the rotation count and module index based on arduino's encoders
    int rotationCount = int(counter2);
    moduleIndex = (int) counter;

    // Draw the current module at the current grid position
    drawCurrentModule(gridX, gridY, rotationCount, color(selectedColor, 50), moduleIndex, cellSize, cellSize, true);

    // Add new modules and prevent creating infinite ones if you don't move away the flashlight
    if (area > lightAreaThreshold && !printLastFrame) {
      Module newMod = new Module(gridX, gridY, selectedColor, rotationCount, moduleIndex);
      mod.add(newMod);
      printLastFrame = true;
    } else if (area < 1000)
      printLastFrame=false;
  }

  popMatrix(); // End of the transformations
  
  // Display a mini tutorial when there's no modules stamped
  textAlign(CENTER);
  textSize(40);
}

// Function to handle serial events
void serialEvent(Serial myPort) {
  try {
    String dataString = myPort.readStringUntil('\n');
    if (dataString != null) {
      // Check for specific commands and split the data and update the counter values
      if (dataString.indexOf("button") >= 0) {
        export();
      }
      String[] data = dataString.trim().split(",");
      for (int i = 0; i <= data.length; i++) {
        if (debug) println(i + " " + data[i]);
      }
      if (!Float.isNaN(float(data[0]))) counter = float(data[0]);
      if (!Float.isNaN(float(data[1]))) counter2 = float(data[1]);
    }
  }
  catch (RuntimeException e) {
    // Handle exceptions
  }
}

// Function to draw the current module (the one you are controlling)
void drawCurrentModule(int gridX, int gridY, int rotationCount, color selectedColor, int moduleIndex, float width, float height, boolean hasStroke) {
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

  if (!hasStroke)noStroke();
  else {
    stroke(150);
    strokeWeight(1);
  }
  fill(selectedColor);
  shape(modules[moduleIndex], 0, 0, width, height);
  popMatrix();
}

// Function to get the current cell based on centroid
PVector getCurrentCell(float _centroidX, float _centroidY) {
  int currentX = 2;
  int currentY = 2;

  if (debug) println("X: " + _centroidX + "   Y: " + _centroidY);

  float xPaddingLeft = 220;
  float xPaddingRight = 230;
  float yPaddingTop = 70;
  float yPaddingBottom = 60;

  if (debug) {
    stroke(255, 0, 0);
    line(xPaddingLeft, 0, xPaddingLeft, height);
    line(width - xPaddingRight, 0, width - xPaddingRight, height);

    line(0, yPaddingTop, width, yPaddingTop);
    line(0, height - yPaddingBottom, width, height - yPaddingBottom);
  }

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

// Function to export the design
void export() {
  if (mod.size() < 1) return;
  if (debug) println("EXPORTED");
  save("creation.png");
  mod = new ArrayList<Module>();
}
