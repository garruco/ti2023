# BRICA

BRICA is an interactive and innovative project that combines computer vision, light detection, and Arduino controllers to manipulate SVG modules in a Processing application. The system reads data from two rotary encoders and a button to control the placement and rotation of SVG modules on a 2D grid. A light source (e.g., a flashlight) is tracked, and its position within the grid is used to stamp SVG shapes onto the canvas.

## Hardware Setup

The hardware setup involves connecting rotary encoders and a button to an Arduino board.

Components needed:

- 2 x Rotary encoders
- 1 x Pushbutton
- 1 x Arduino Board (Uno, Mega, or similar)
- 1 x Breadboard
- Jumper Wires
- 1 x RGB LED (Common Cathode)

### Arduino Setup

1. **Rotary Encoders:**
   Connect the first rotary encoder to the Arduino. Connect the CLK, DT, and SW pins of the encoder to digital pins 4, 3, and 2 on the Arduino, respectively. Connect the '+' and GND pins of the encoder to 5V and GND on the Arduino, respectively.
   Connect the second rotary encoder in the same way. Connect CLK2, DT2, and SW2 to digital pins 7, 6, and 5 on the Arduino, respectively.

2. **Pushbutton:**
   Connect one end of the pushbutton to digital pin 13 on the Arduino. Connect the other end of the pushbutton to the GND pin on the Arduino.

3. **RGB LED:**
   Connect the RGB LED's R, G, and B pins to digital pins 8, 9, and 10 on the Arduino, respectively. Connect the common cathode of the LED to the GND pin on the Arduino.

4. **Upload Code:**
   Once all components are connected, upload the provided Arduino code to your board.

## Software Setup

1. **Processing**
   Install the Processing IDE on your computer. This is required to run the Processing sketch for this project.

2. **Libraries**
   You will need the following libraries for Processing:

- OpenCV for Processing: Used for computer vision techniques.
- Video: Required for capturing video from a webcam.

You can install these libraries from the Processing IDE itself.

3. **Running the Sketch**
   Load the provided Processing sketch in the Processing IDE. Make sure the Arduino board is connected to your computer via USB and that the Arduino code is running. Run the Processing sketch.

## Configuration

The application includes debug mode (boolean debug). When enabled, it provides additional information on the canvas and prints relevant data to the console. This mode can be useful for calibration, debugging, and understanding the application's inner workings.

The lightAreaThreshold and the opencv.threshold() function can be adjusted according to the brightness and area of your light source.

## Usage

Rotate the encoders to control the shape and color on the screen. Press the button to save the current state of the artwork.

Note: The Processing sketch uses computer vision techniques to respond to changes in ambient light and colors. Make sure to have some light source and color variation in the environment for a more dynamic interaction.
