// Function to find the closest color
int findClosestColor(int pixelColor) {
  float minDist = Float.MAX_VALUE;
  int colorIndex = 0;

  for (int i = 0; i < referenceColors.length; i++) {
    float currentDist = colorDist(pixelColor, referenceColors[i]);
    if (currentDist < minDist) {
      minDist = currentDist;
      colorIndex = i;
    }
  }

  return colorIndex;
}

// Function to calculate the distance between two colors
float colorDist(int c1, int c2) {
  float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
  float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
  return sqrt(sq(r2 - r1) + sq(g2 - g1) + sq(b2 - b1));
}
