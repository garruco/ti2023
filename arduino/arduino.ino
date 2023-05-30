// Define pin numbers for the first rotary encoder
#define CLK 4
#define DT 3
#define SW 2

// Define pin numbers for the second rotary encoder
#define CLK2 7
#define DT2 6
#define SW2 5

// Initialize counter variables for the encoders
int counter = 0, counter2 = 0;

// Initialize variables to store the current and previous states of the encoders
int currentStateCLK, currentStateCLK2;
int lastStateCLK, lastStateCLK2;

// Initialize variables for RGB colors and respective pins
int red, green, blue;
int redPin = 8;
int greenPin = 9;
int bluePin = 10;

void setup() {
  Serial.begin(9600);   // Start serial communication at 9600 baud rate
  pinMode(CLK, INPUT);  // Set encoder pins as inputs
  pinMode(DT, INPUT);
  pinMode(SW, INPUT_PULLUP);
  lastStateCLK = digitalRead(CLK);  // Read the initial state of CLK

  // Set RGB pins as outputs
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  // Turn off the RGB LED
  analogWrite(redPin, 255);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  bool changedLed = false; // Variable to check if LED color has been changed

  // Check for incoming data from serial port
  while (Serial.available()) {
    char incomingByte = (char)Serial.read();

    // Change LED color based on incoming character
    if (incomingByte == 'U') { //black
      red = 0;
      green = 0;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'I') { //red
      red = 255;
      green = 0;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'O') { //green
      red = 0;
      green = 255;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'P') { //blue
      red = 0;
      green = 0;
      blue = 255;
      changedLed = true;
    }
  }

  // If LED color was changed, update the color
  if(changedLed){
    analogWrite(redPin, 255- red);
    analogWrite(greenPin, 255 -green);
    analogWrite(bluePin, 255 - blue);
  }

  // Read current state of both rotary encoders
  currentStateCLK = digitalRead(CLK); 
  currentStateCLK2 = digitalRead(CLK2); 

  // If the first encoder has been rotated, update the counter
  if (currentStateCLK != lastStateCLK && currentStateCLK == 1) {
    if (digitalRead(DT) != currentStateCLK) {
      counter--;
    } else {
      counter++;
    }

    if (counter < 0) counter = 14;  // Clamp minimum value of counter
    counter = counter % 15;  // Wrap around if counter exceeds 14
  }

  // If the second encoder has been rotated, update the counter
  if (currentStateCLK2 != lastStateCLK2 && currentStateCLK2 == 1) {
    if (digitalRead(DT2) != currentStateCLK2) {
      counter2--;
    } else {
      counter2++;
    }

    if (counter2 <= 0) counter2 = 3;  // Clamp minimum value of counter
    counter2 = counter2 % 4;  // Wrap around if counter exceeds 3
  }

  // Print the current state of the counters
  Serial.println(counter);
  Serial.print(",");
  Serial.println(counter2);
  Serial.println("");

  // Update last state of encoders for next loop iteration
  lastStateCLK = currentStateCLK;
  lastStateCLK2 = currentStateCLK2;

  // Delay to reduce noise in the readings
  delay(1);
}
