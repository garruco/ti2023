// Define pins for the first rotary encoder
#define CLK 4
#define DT 3
#define SW 2

// Define pins for the second rotary encoder
#define CLK2 7
#define DT2 6
#define SW2 5

// Initialize counters and state variables for the rotary encoders
int counter = 0, counter2 = 0;
int currentStateCLK, currentStateCLK2;
int lastStateCLK, lastStateCLK2;

// Define pin and state variable for a button
int buttonPin = 13;   // the number of the pushbutton pin
int buttonState = 0;  // variable for reading the pushbutton status

// Initialize RGB values and define pins for the RGB LED
int red, green, blue;
int redPin = 8;
int greenPin = 9;
int bluePin = 10;

void setup() {
  Serial.begin(9600);  // Setup Serial Monitor
  // Set encoder pins as inputs
  pinMode(CLK, INPUT);
  pinMode(DT, INPUT);
  pinMode(SW, INPUT_PULLUP);
  lastStateCLK = digitalRead(CLK);  // Read the initial state of CLK

  // Set the second encoder pins as inputs
  pinMode(CLK2, INPUT);
  pinMode(DT2, INPUT);
  pinMode(SW2, INPUT_PULLUP);
  lastStateCLK = digitalRead(CLK) 2;  // Read the initial state of CLK

  pinMode(buttonPin, INPUT_PULLUP);  // initialize the pushbutton pin as an input with pullup resistor

  // Set pins for the RGB LED as outputs
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  // Initialize the RGB LED as white
  analogWrite(redPin, 255);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  bool changedLed = false;

  // Handle serial communication
  while (Serial.available()) {
    char incomingByte = (char)Serial.read();  // Read incoming serial data
    // Change LED color based on incoming byte
    if (incomingByte == 'U') {  // Black
      red = 0;
      green = 0;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'I') {  // Red
      red = 255;
      green = 0;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'O') {  // Green
      red = 0;
      green = 255;
      blue = 0;
      changedLed = true;
    } else if (incomingByte == 'P') {  // Blue
      red = 0;
      green = 0;
      blue = 255;
      changedLed = true;
    }
  }

  if (changedLed) {
    analogWrite(redPin, 255 - red);
    analogWrite(greenPin, 255 - green);
    analogWrite(bluePin, 255 - blue);
  }

  // Read current state of rotary encoders
  currentStateCLK = digitalRead(CLK);    // Read the current state of CLK
  currentStateCLK2 = digitalRead(CLK2);  // Read the current state of CLK

  // Read state of pushbutton
  buttonState = digitalRead(buttonPin);  // read the state of the pushbutton value

  // Handle rotation of first rotary encoder
  if (currentStateCLK != lastStateCLK && currentStateCLK == 1) {
    if (digitalRead(DT) != currentStateCLK) {
      counter--;
    } else {
      counter++;
    }

    if (counter < 0) counter = 14;
    counter = counter % 15;
  }

  // Handle rotation of second rotary encoder
  if (currentStateCLK2 != lastStateCLK2 && currentStateCLK2 == 1) {
    if (digitalRead(DT2) != currentStateCLK2) {
      counter2--;
    } else {
      counter2++;
    }

    if (counter2 <= 0) counter2 = 3;
    counter2 = counter2 % 4;
  }

  // Print rotary encoder values and button state to serial monitor
  Serial.println(counter);
  Serial.print(",");
  Serial.println(counter2);
  if (buttonState > 0) {
    Serial.print(",");
    Serial.println("button");
  }

  Serial.println("");

  // Store current state of rotary encoders for next loop iteration
  lastStateCLK = currentStateCLK;
  lastStateCLK2 = currentStateCLK2;

  delay(1);  // Short delay to ensure stable readings
}