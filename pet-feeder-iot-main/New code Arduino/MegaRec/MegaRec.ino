#include <SoftwareSerial.h>
#include <AccelStepper.h>

// DC Motor Driver Pins
int motor1Pin1 = 8;  // Motor 1 - IN1
int motor1Pin2 = 9;  // Motor 1 - IN2
int enable1Pin = 5;  // Motor 1 - PWM

int motor2Pin1 = 10; // Motor 2 - IN1
int motor2Pin2 = 11; // Motor 2 - IN2
int enable2Pin = 6;  // Motor 2 - PWM

// Stepper Motor Pins
const int dirPin = 22;   // Stepper Motor Direction
const int stepPin = 23;  // Stepper Motor Step

#define limitSwitchPin 3 // Limit Switch

// Define steps per revolution for your stepper motor
const int stepsPerRevolution = 18000; // Adjust this if necessary for your stepper


#define mySerial Serial1 
// Define motor interface type for the stepper motor
#define motorInterfaceType 1
AccelStepper myStepper(motorInterfaceType, stepPin, dirPin);

// Global variable to store the previous stepper position
long previousStepperPosition = 0;



void setup() {
    Serial.begin(9600);  // USB Serial Monitor
    Serial1.begin(9600); // Communication with ESP32

    // Set motor pins as outputs
    pinMode(motor1Pin1, OUTPUT);
    pinMode(motor1Pin2, OUTPUT);
    pinMode(enable1Pin, OUTPUT);
    pinMode(motor2Pin1, OUTPUT);
    pinMode(motor2Pin2, OUTPUT);
    pinMode(enable2Pin, OUTPUT);

    // Set the pins as outputs
  pinMode(dirPin, OUTPUT);
  pinMode(stepPin, OUTPUT);

  pinMode(limitSwitchPin, INPUT_PULLUP);


    // Ensure motors are stopped initially
    stopMotors();

    // Setup Stepper Motor
    myStepper.setMaxSpeed(1000);
    myStepper.setAcceleration(100);
    myStepper.setSpeed(200);

    
}

void loop() {
    if (Serial1.available()) {
        String message = Serial1.readStringUntil('\n');
        message.trim();  // Remove any whitespace or newline characters

        Serial.println("Received: " + message);

        if (message == "moveUp") {
            moveForward();
        } else if (message == "moveDown") {
            moveBackward();
        } else if (message == "moveLeft") {
            turnLeft();
        } else if (message == "moveRight") {
            turnRight();
        } else if (message == "stopMotor") {
            stopMotors();
        } else if (message == "stepperForward") {
            rotateStepperForward();
        } else if (message == "stepperBackward") {
            rotateBackToPrevious();
        } else {
            Serial.println("Unknown command received.");
        }
    }
}

// -------------------------
// Motor and Door Functions
// -------------------------

void moveForward() {
    Serial.println("Moving Forward");
    analogWrite(enable1Pin, 255);
    analogWrite(enable2Pin, 255);
    digitalWrite(motor1Pin1, LOW);
    digitalWrite(motor1Pin2, HIGH);
    digitalWrite(motor2Pin1, LOW);
    digitalWrite(motor2Pin2, HIGH);
}

void moveBackward() {
    Serial.println("Moving Backward");
    analogWrite(enable1Pin, 255);
    analogWrite(enable2Pin, 255);
    digitalWrite(motor1Pin1, HIGH);
    digitalWrite(motor1Pin2, LOW);
    digitalWrite(motor2Pin1, HIGH);
    digitalWrite(motor2Pin2, LOW);
}

void turnLeft() {
    Serial.println("Turning Left");
    analogWrite(enable1Pin, 255);
    analogWrite(enable2Pin, 255);
    digitalWrite(motor1Pin1, LOW);
    digitalWrite(motor1Pin2, HIGH);
    digitalWrite(motor2Pin1, HIGH);
    digitalWrite(motor2Pin2, LOW);
}

void turnRight() {
    Serial.println("Turning Right");
    analogWrite(enable1Pin, 255);
    analogWrite(enable2Pin, 255);
    digitalWrite(motor1Pin1, HIGH);
    digitalWrite(motor1Pin2, LOW);
    digitalWrite(motor2Pin1, LOW);
    digitalWrite(motor2Pin2, HIGH);
}

void stopMotors() {
    Serial.println("Motors Stopped");
    analogWrite(enable1Pin, 0);
    analogWrite(enable2Pin, 0);
    digitalWrite(motor1Pin1, LOW);
    digitalWrite(motor1Pin2, LOW);
    digitalWrite(motor2Pin1, LOW);
    digitalWrite(motor2Pin2, LOW);
}

// -------------------------
// Stepper Motor Functions
// -------------------------

void rotateStepperForward() {
    // Open the door by reversing the motor's direction
  digitalWrite(dirPin, LOW); // Set direction to open
  for (int i = 0; i < stepsPerRevolution; i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(500); // Reduced delay for higher speed
    digitalWrite(stepPin, LOW);
    delayMicroseconds(500); // Reduced delay for higher speed
  }

    Serial.println("Stepper rotation complete.");
}

void rotateBackToPrevious() {
    // Close the door by reversing the motor's direction
    digitalWrite(dirPin, HIGH); // Set direction to close

    // Keep rotating until the limit switch is triggered (reads HIGH)
    while (digitalRead(limitSwitchPin) == LOW) { 
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(500); // Adjust for speed
        digitalWrite(stepPin, LOW);
        delayMicroseconds(500);
    }

    Serial.println("Stepper stopped: Limit switch triggered.");
}
