class Module {
  int gridX, gridY;
  color c;
  float rot;
  int module;
  int gridSize = 3;
  int cellSize = width / gridSize;

  Module(int gridX, int gridY, color c, float rot, int module) {
    this.gridX = gridX;
    this.gridY = gridY;
    this.c = c;
    this.rot = rot;
    this.module = module;
  }


  void display() {
    pushMatrix();
    translate((gridX + 0.5) * cellSize, (gridY + 0.5) * cellSize);
    rotate(rot);
    shapeMode(CENTER);
    pushStyle();
    fill(c);
    shape(modules[module], gridX, gridY, width/3, height/3); // Display the chosen module
    popStyle();
    popMatrix();
  }
}
