# Interactive Modular Art Generator

This project is an interactive art generator created for the "Tecnologias de Interfaces" subject of the Master in Design and Multimedia in University of Coimbra. It combines Arduino and Processing to create a user-friendly interface for generating and customizing modular art designs. Users can control various parameters using a joystick, potentiometer, LDR, and a button to create unique and engaging artwork.

## Arduino Sketch

The Arduino sketch reads input from various components including a joystick, two potentiometers (dials), an LDR (Light Dependent Resistor), and a button. The joystick controls the position of the module in the grid, dial1 controls the rotation of the module, dial2 selects the module, the LDR adds a module to the canvas, and the button saves the artwork as an image.

You can find the Arduino sketch in the `arduino.ino` file.

## Processing Sketch

The Processing sketch receives the values from the Arduino and updates the visual display accordingly. It uses the input values to control the grid position, rotation, module selection, and addition of modules to the canvas. Users can also save their artwork as a PNG image by pressing the button.

You can find the Processing sketch in the `p3.pde` file.

## Setup and Usage

### Hardware Components

To set up the hardware, you will need the following components:

1. Arduino board (e.g., Arduino Uno)
2. Joystick
3. 2x Potentiometers (dials)
4. LDR (Light Dependent Resistor)
5. Button
6. Breadboard and jumper wires

### Software Installation

1. Install the [Arduino IDE](https://www.arduino.cc/en/software) and [Processing](https://processing.org/download/) on your computer.
2. Upload the `arduino.ino` sketch to your Arduino board.
3. Open the `p3.pde` sketch in Processing.
4. Update the serial port in the `p3.pde` sketch to match the port used by your Arduino board.

### Usage

1. Run the Processing sketch.
2. Use the joystick to move the module in the grid.
3. Use dial1 to rotate the module.
4. Use dial2 to select the desired module.
5. Cover the LDR to add the current module to the canvas.
6. Press the button to save the artwork as a PNG image.

Enjoy creating your unique modular art designs!
