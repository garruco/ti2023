import processing.serial.*;

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

void setup() {
  size(900, 900);
  rectMode(CENTER);

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
  println(buttonState);
  shapeMode(CORNER);

  updateGridPosition();

  int rotationCount = round(map(dial1Val, 0, 1023, 0, 3));
  color fillColor = color(255, 0, 0, 100);
  moduleIndex = int(map(dial2Val, 0, 1023, 0, n_modules - 1));
  drawCurrentModule(gridX, gridY, rotationCount, fillColor, moduleIndex, cellSize, cellSize);

  for (int v = 0; v < mod.size(); v++) {
    mod.get(v).display();
  }

  if (ldrVal <= 50) {
    Module newMod = new Module(gridX, gridY, color(255, 0, 0), rotationCount, moduleIndex);
    mod.add(newMod);
    delay(500);
  }

  if (buttonState == 1) {
    save("artboard.png");
    delay(500);
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

void updateGridPosition() {
  float xPos = map(joystickYVal, 0, 1023, -1, 1);
  float yPos = map(joystickXVal, 1023, 0, -1, 1);

  if (int(xPos) != 0 || int(yPos) != 0) {
    delay(250);
    gridX += int(xPos);
    gridY += int(yPos);
  }

  gridX = constrain(gridX, 0, 2);
  gridY = constrain(gridY, 0, 2);
}

void drawCurrentModule(int gridX, int gridY, int rotationCount, color fillColor, int moduleIndex, float width, float height) {
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
  fill(fillColor);
  shape(modules[moduleIndex], 0, 0, width, height);
  popMatrix();
}
