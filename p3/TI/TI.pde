import processing.serial.*;

Serial myPort;
float joystickXVal, joystickYVal, dial1Val, dial2Val, ldrVal;
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
  size(902, 902);
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

  // Calculate the position of the SVG based on the joystick values
  float xPos = map(joystickYVal, 0, 1023, -1, 1);
  float yPos = map(joystickXVal, 1023, 0, -1, 1);

  if (int(xPos) != 0 || int(yPos) != 0) {
    delay(250);
    // Calculate the grid cell that the SVG is in
    gridX += int(xPos);
    gridY += int(yPos);
    println(int(xPos));
  }

  gridX = constrain(gridX, 0, 2);
  gridY = constrain(gridY, 0, 2);


  // Apply the rotation based on the dial value
  float dialVal = map(dial1Val, 0, 1023, 0, 4);
  int nRotations = round(dialVal);
  
  pushMatrix();
  switch (nRotations) {
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

  rotate(radians(nRotations * 90));


  println("X: " + gridX + "   Y:" + gridY);


  fill(c);
  shape(modules[module], 0, 0, cellSize, cellSize); // Display the chosen module
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
}

void keyPressed() {
  save("artboard.png");
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
    }
  }

  catch(RuntimeException e) {
    e.printStackTrace();
  }
}
