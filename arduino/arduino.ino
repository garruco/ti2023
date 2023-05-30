#define CLK 4
#define DT 3
#define SW 2

#define CLK2 7
#define DT2 6
#define SW2 5

int counter = 0, counter2 = 0;
int currentStateCLK, currentStateCLK2;
int lastStateCLK, lastStateCLK2;

int red, green, blue;
int redPin = 8;
int greenPin = 9;
int bluePin = 10;

void setup() {
  Serial.begin(9600);   // Setup Serial Monitor
  pinMode(CLK, INPUT);  // Set encoder pins as inputs
  pinMode(DT, INPUT);
  pinMode(SW, INPUT_PULLUP);
  lastStateCLK = digitalRead(CLK);  // Read the initial state of CLK

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  analogWrite(redPin, 255);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  bool changedLed = false;

  while (Serial.available()) {
    char incomingByte = (char)Serial.read();
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

if(changedLed){
  analogWrite(redPin, 255- red);
  analogWrite(greenPin, 255 -green);
  analogWrite(bluePin, 255 - blue);
}


  currentStateCLK = digitalRead(CLK);  // Read the current state of CLK

  currentStateCLK2 = digitalRead(CLK2);  // Read the current state of CLK

  if (currentStateCLK != lastStateCLK && currentStateCLK == 1) {
    if (digitalRead(DT) != currentStateCLK) {
      counter--;
    } else {
      counter++;
    }

    if (counter < 0) counter = 14;
    counter = counter % 15;
  }


  if (currentStateCLK2 != lastStateCLK2 && currentStateCLK2 == 1) {
    if (digitalRead(DT2) != currentStateCLK2) {
      counter2--;
    } else {
      counter2++;
    }

    if (counter2 <= 0) counter2 = 3;
    counter2 = counter2 % 4;
  }


  Serial.println(counter);
  Serial.print(",");
  Serial.println(counter2);
  Serial.println("");



  lastStateCLK = currentStateCLK;

  lastStateCLK2 = currentStateCLK2;


  delay(1);
}