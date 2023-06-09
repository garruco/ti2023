// Module class
class Module {
  // Variables for module's properties
  int gridX, gridY;
  color c;
  int nRotations;
  int module;
  int gridSize = 3;
  int cellSize = width / gridSize;

  // Constructor
  Module(int gridX, int gridY, color c, int nRotations, int module) {
    this.gridX = gridX;
    this.gridY = gridY;
    this.c = c;
    this.nRotations = nRotations;
    this.module = module;
  }

  // Method to display the module
  void display() {
    shapeMode(CORNER);
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

    rotate(nRotations * HALF_PI);

    noStroke();
    fill(c);
    shape(modules[module], 0, 0, cellSize, cellSize); // Display the chosen module
    popMatrix();
  }
}
