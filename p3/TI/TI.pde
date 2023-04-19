import processing.serial.*;

Serial myPort;
float joystickXVal, joystickYVal, dial1Val, dial2Val, ldrVal;
int buttonState;
float rotationAngle = 0;
color squareColor;
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

  //printArray(Serial.list());

  // Open the serial port
  myPort = new Serial(this, Serial.list()[1], 9600);

  // Set the serial port to buffer incoming data with a timeout of 100 milliseconds
  myPort.bufferUntil('\n');

  // Set the initial square color
  squareColor = color(255, 255, 0);

  // Calculate the size of each grid cell
  cellSize = floor( width / gridSize);
}

void draw() {
  background(255, 255, 255);
  println(buttonState);
  // Calculate the position of the SVG based on the joystick values
  float xPos = map(joystickYVal, 0, 1023, -1, 1);
  float yPos = map(joystickXVal, 1023, 0, -1, 1);


  //println(ldrVal);

  shapeMode(CENTER);

  if (int(xPos) != 0 || int(yPos) != 0) {
    delay(250);
    // Calculate thße grid cell that the SVG is in
    gridX += int(xPos);
    gridY += int(yPos);
  }

  gridX = constrain(gridX, 0, 2);
  gridY = constrain(gridY, 0, 2);


  // Apply the rotation based on the dial value
  float dialVal = map(dial1Val, 0, 1023, 0, 3);
  int nRotations = round(dialVal);
  rotationAngle = nRotations * HALF_PI;

  pushMatrix();
  translate((gridX + 0.5) * cellSize, (gridY + 0.5) * cellSize);
  rotate(rotationAngle);

  // Draw the SVG
  noStroke();
  fill(255, 0, 0, 100);
  moduleIndex = int(map(dial2Val, 0, 1023, 0, n_modules-1)); // Calculate the module index based on the dial value
  shape(modules[moduleIndex], 0, 0, width/3, height/3); // Display the chosen module
  popMatrix();

  for (int v = 0; v < mod.size(); v++) {
    mod.get(v).display();
  }

  if (ldrVal <= 50) {
    Module newMod = new Module(gridX, gridY, color(255, 0, 0), nRotations, moduleIndex);
    mod.add(newMod);
    //println(mod.size());
    delay(500);
  }

  if (buttonState == 1) {
    save("artboard.png");
    delay(500);
  }
}


void serialEvent(Serial myPort) {
  try {
    // Read the incoming serial data
    String dataString = myPort.readStringUntil('\n');
    if (dataString != null) {
      // Split the incoming data into separate values
      String[] data = dataString.trim().split(",");

      // Convert the data to floats and assign them to variables
      joystickXVal = float(data[0]);
      joystickYVal = float(data[1]);
      dial1Val = float(data[2]);
      dial2Val = float(data[3]);
      ldrVal = float(data[4]);
      buttonState = int(data[5]);
    }
  }

  catch(RuntimeException e) {
    e.printStackTrace();
  }
}
