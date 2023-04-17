const int joystickXPin = A2;
const int joystickYPin = A3;
const int dial1Pin = A0;
const int dial2Pin = A1;
const int ldrPin = A4;
const int redPin = 8;
const int greenPin = 9;
const int bluePin = 10;

void setup() {
  Serial.begin(9600);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  // Read joystick, potentiometer, and LDR values
  float joystickXVal = analogRead(joystickXPin);
  float joystickYVal = analogRead(joystickYPin);
  float dial1Val = analogRead(dial1Pin);
  float dial2Val = analogRead(dial2Pin);
  float ldrVal = analogRead(ldrPin);

  // Send values to Processing over serial
  Serial.print(joystickXVal);
  Serial.print(",");
  Serial.print(joystickYVal);
  Serial.print(",");
  Serial.print(dial1Val);
  Serial.print(",");
  Serial.print(dial2Val);
  Serial.print(",");
  Serial.print(ldrVal);
  Serial.println();

  delay(10);  // Add a small delay to avoid flooding the serial port
}
