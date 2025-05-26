#include <AccelStepper.h>
#include <WiFi.h>
#include <esp_wifi.h>
#include <Firebase_ESP_Client.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <time.h>
// -------------------------
// Wi-Fi and Firebase Setup
// -------------------------
const char* ssid = "Bhanuka";
const char* password = "987654123";

// Firebase credentials
#define FIREBASE_HOST "https://pet-feeder-94fe8-default-rtdb.firebaseio.com/"  // Project ID
#define FIREBASE_AUTH "qDUFnE9Fv1b85j3BtcOgg6i7fJzTMPaAn581tE6g"               // Firebase database secret

#define RXD2 25
#define TXD2 26

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// -------------------------
// Hardware Pin Definitions
// -------------------------

// DC Motor Driver Pins
// int motor1Pin1 = 32;  // Motor 1 - IN1
// int motor1Pin2 = 33;  // Motor 1 - IN2
// int enable1Pin = 25;  // Motor 1 - PWM

// int motor2Pin1 = 26;  // Motor 2 - IN1
// int motor2Pin2 = 27;  // Motor 2 - IN2
// int enable2Pin = 14;  // Motor 2 - PWM

// Stepper Motor Pins
const int dirPin = 18;   // Stepper Motor Direction
const int stepPin = 19;  // Stepper Motor Step

// Ultrasonic Sensor Pins
const int trigPin1 = 12;  // Front sensor Trigger 16
const int echoPin1 = 14;  // Front sensor Echo 4
const int trigPin2 = 5;   // Storage sensor Trigger 5
const int echoPin2 = 17;  // Storage sensor Echo 17

// PWM Settings
const int freq = 30000;
const int pwmChannel1 = 0;
const int pwmChannel2 = 1;
const int resolution = 8;
int dutyCycle = 200;

// Food level calibration distances (in centimeters)
const float minDistance = 5.0;   // When container is completely full
const float maxDistance = 32.0;  // When container is empty

// -------------------------
// Other Global Variables
// -------------------------

int lastValue = 2;

// Define motor interface type for the stepper motor
#define motorInterfaceType 1
AccelStepper myStepper(motorInterfaceType, stepPin, dirPin);

// Device controls
int moveUp = 0;
int moveDown = 0;
int moveleft = 0;
int moveRight = 0;
int doorstate = 0;

// Variables for ultrasonic sensors
long duration1;
int distance1;
long duration2;
int distance2;

// Global variable to store the previous stepper position
long previousStepperPosition = 0;

unsigned long openStartTime = 0;
bool doorOpen = false;

// -------------------------
// LCD Display Setup
// -------------------------
// Change the I2C address if needed (commonly 0x27 or 0x3F) and specify the LCD size.
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);

  Wire.begin(21, 22);

  // Initialize LCD Display
  lcd.init();       // Initialize the LCD
  lcd.backlight();  // Turn on the backlight
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Device Turned On");

  // Setup WiFi
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println();
  Serial.println("Connected to Wi-Fi");

  // Initialize time from NTP
  configTime(19800, 0, "pool.ntp.org", "time.nist.gov");
  // Wait until time is synced (adjust the condition as needed)
  time_t now = time(nullptr);
  while (now < 100000) {  // a simple check – time should be a large number if synced
    delay(500);
    now = time(nullptr);
  }
  Serial.println("Time synchronized");


  //update LCD when WiFi connects
  lcd.setCursor(0, 1);
  lcd.print("WiFi Connected");

  // Configure Firebase
  config.database_url = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Setup Stepper Motor
  myStepper.setMaxSpeed(1000);
  myStepper.setAcceleration(50);
  myStepper.setSpeed(200);

  if (Firebase.ready()) {
    Firebase.RTDB.setInt(&fbdo, "/computer/cat-or-dog", 2);
    Firebase.RTDB.setInt(&fbdo, "/mobile/door", 0);
  }


  // Set motor pins as outputs
  // pinMode(motor1Pin1, OUTPUT);
  // pinMode(motor1Pin2, OUTPUT);
  // pinMode(enable1Pin, OUTPUT);
  // pinMode(motor2Pin1, OUTPUT);
  // pinMode(motor2Pin2, OUTPUT);
  // pinMode(enable2Pin, OUTPUT);

  // Setup ultrasonic sensor pins
  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);

  // Configure LEDC PWM channels for motors
  // ledcAttachChannel(enable1Pin, freq, resolution, pwmChannel1);
  // ledcAttachChannel(enable2Pin, freq, resolution, pwmChannel2);
}

void loop() {

  if (Serial.available() > 0) {             // Check if data is available to read
    int receivedValue = Serial.parseInt();  // Read the integer from serial

    if (receivedValue == 5) {                      // Check if the received value is 5
      Serial.println("Door Closing manually...");  // Print message to serial monitor
      rotateBackToPrevious();
    }
  }
  controlDevice();
  checkSchedules();
  //objectDetection();
  //getModelResults();
  controlDoor();


  // Get the food level and send it to Firebase
  float foodLevel = getFoodLevel();
  sendFoodLevelToFirebase(foodLevel);

  // Optionally update the LCD with the current food level (as percentage)
  lcd.setCursor(0, 0);
  lcd.print("Food: ");
  lcd.setCursor(6, 0);
  lcd.print(foodLevel * 100, 0);  // Display percentage value
  lcd.print("%          ");       // Extra spaces to clear previous data

  delay(1);
}

// -------------------------
// Motor and Door Functions
// -------------------------

// void moveForward() {
//   Serial.println("Moving Forward");
//   digitalWrite(motor1Pin1, LOW);
//   digitalWrite(motor1Pin2, HIGH);
//   digitalWrite(motor2Pin1, LOW);
//   digitalWrite(motor2Pin2, HIGH);
// }

// void moveBackward() {
//   Serial.println("Moving Backwards");
//   digitalWrite(motor1Pin1, HIGH);
//   digitalWrite(motor1Pin2, LOW);
//   digitalWrite(motor2Pin1, HIGH);
//   digitalWrite(motor2Pin2, LOW);
// }

// void turnLeft() {
//   Serial.println("Turning Left");
//   digitalWrite(motor1Pin1, LOW);
//   digitalWrite(motor1Pin2, HIGH);
//   digitalWrite(motor2Pin1, LOW);
//   digitalWrite(motor2Pin2, LOW);
// }

// void turnRight() {
//   Serial.println("Turning Right");
//   digitalWrite(motor1Pin1, LOW);
//   digitalWrite(motor1Pin2, LOW);
//   digitalWrite(motor2Pin1, LOW);
//   digitalWrite(motor2Pin2, HIGH);
// }

// void stopMotors() {
//   Serial.println("Motors Stopped");
//   digitalWrite(motor1Pin1, LOW);
//   digitalWrite(motor1Pin2, LOW);
//   digitalWrite(motor2Pin1, LOW);
//   digitalWrite(motor2Pin2, LOW);
// }

// -------------------------
// Stepper Motor Functions
// -------------------------
void rotateStepperForward() {
  previousStepperPosition = myStepper.currentPosition();
  Serial2.println("stepperForward");
  Serial.println("stepperForward Sent to Arduino");
  // Serial.println("Rotating stepper motor 10 steps forward...");
  // myStepper.moveTo(previousStepperPosition + 10);
  // myStepper.runToPosition();
  // Serial.println("Stepper rotation complete.");
}

void rotateBackToPrevious() {
  Serial2.println("stepperBackward");
  Serial.println("stepperBackward Sent to Arduino");
  // Serial.println("Rotating stepper motor back to previous position...");
  // myStepper.moveTo(previousStepperPosition);
  // myStepper.runToPosition();
  // Serial.println("Stepper returned to previous position.");
}

// -------------------------
// Device and Door Control Functions
// -------------------------
void controlDevice() {
  if (Firebase.ready()) {
    int moveUp = 0, moveDown = 0, moveLeft = 0, moveRight = 0;

    if (Firebase.RTDB.getInt(&fbdo, "/mobile/device/up")) {
      moveUp = fbdo.intData();
    }
    if (Firebase.RTDB.getInt(&fbdo, "/mobile/device/down")) {
      moveDown = fbdo.intData();
    }
    if (Firebase.RTDB.getInt(&fbdo, "/mobile/device/left")) {
      moveLeft = fbdo.intData();
    }
    if (Firebase.RTDB.getInt(&fbdo, "/mobile/device/right")) {
      moveRight = fbdo.intData();
    }

    if (moveUp == 1) {
      Serial2.println("moveUp");
      Serial.println("moveUp Sent to Arduino");
    } else if (moveDown == 1) {
      Serial2.println("moveDown");
      Serial.println("moveDown Sent to Arduino");
    } else if (moveLeft == 1) {
      Serial2.println("moveLeft");
      Serial.println("moveLeft Sent to Arduino");
    } else if (moveRight == 1) {
      Serial2.println("moveRight");
      Serial.println("moveRight Sent to Arduino");
    } else {
      Serial2.println("stopMotor");
      Serial.println("stopMotor Sent to Arduino");
    }
  }
}

void readFrontDistance() {
  digitalWrite(trigPin1, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin1, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin1, LOW);
  duration1 = pulseIn(echoPin1, HIGH);
  distance1 = duration1 * 0.034 / 2;
  Serial.print("Distance: ");
  Serial.println(distance1);
}

void controlDoor() {
  if (!Firebase.ready()) return;

  String pathdoor = "/mobile/door";
  if (!Firebase.RTDB.getInt(&fbdo, pathdoor)) {
    Serial.println("Failed to read door status from Firebase");
    Serial.println(fbdo.errorReason());
    return;
  }

  doorstate = fbdo.intData();

  // If Firebase says to close the door while it's open, close immediately
  if (doorstate == 0 && doorOpen) {
    Serial.println("Received close command. Closing door...");

    rotateBackToPrevious();  // Close the door immediately
    doorOpen = false;

    // Reset timers to prevent the door from opening again
    openStartTime = 0;

    // Update Firebase to confirm door closure
    if (Firebase.ready()) {
      if (Firebase.RTDB.setInt(&fbdo, "/esp/data", 0)) {
        Serial.println("Alert off sent successfully.");
      } else {
        Serial.print("Failed to send Alert off: ");
        Serial.println(fbdo.errorReason());
      }
    }
    return;  // Exit function to prevent further execution
  }

  // If door should open and it's not already open

  if (doorstate == 1 && !doorOpen) {
    Serial.println("Opening the door...");
    objectDetection();
    rotateStepperForward();
    openStartTime = millis();
    doorOpen = true;
  }

  if (doorOpen) {
    readFrontDistance();
    Serial.print("Distance: ");
    Serial.println(distance1);

    if (distance1 < 200) {
      Serial.println("Object detected, keeping door open...");
      openStartTime = millis();
    }

    if (millis() - openStartTime >= 5000 && distance1 >= 40) {
      Serial.println("No object detected, Alerting...");
      if (Firebase.ready()) {
        if (Firebase.RTDB.setInt(&fbdo, "/esp32/data", 1)) {
          Serial.println("Alert sent successfully.");
        } else {
          Serial.print("Failed to send Alert: ");
          Serial.println(fbdo.errorReason());
        }
      }
    }

    if (millis() - openStartTime >= 10000 && distance1 >= 40) {
      Serial.println("No object detected, closing the door...");
      if (Firebase.ready()) {
        if (Firebase.RTDB.setInt(&fbdo, "/mobile/door", 0)) {
          Serial.println("Door status updated successfully.");
        } else {
          Serial.print("Failed to send door status: ");
          Serial.println(fbdo.errorReason());
        }
        if (Firebase.RTDB.setInt(&fbdo, "/esp32/data", 0)) {
          Serial.println("Alert off sent successfully.");
        } else {
          Serial.print("Failed to send Alert off: ");
          Serial.println(fbdo.errorReason());
        }
      }
      rotateBackToPrevious();
      doorOpen = false;
      openStartTime = 0;  // Reset timer to prevent re-triggering
    }
  }
}



// -------------------------
// Food Level Sensor and Firebase Functions
// -------------------------
float getFoodLevel() {
  // Trigger the ultrasonic sensor for food level
  digitalWrite(trigPin2, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin2, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin2, LOW);

  // Read the echo pulse duration (in microseconds)
  long duration = pulseIn(echoPin2, HIGH);
  // Convert duration to distance in centimeters
  float distance = duration * 0.034 / 2;

  // Constrain the distance within expected values
  if (distance < minDistance) distance = minDistance;
  if (distance > maxDistance) distance = maxDistance;

  // Map the distance to a percentage: full (minDistance) => 1.0, empty (maxDistance) => 0.0
  float levelPercentage = (maxDistance - distance) / (maxDistance - minDistance);
  return levelPercentage;
}

void sendFoodLevelToFirebase(float foodLevel) {
  if (Firebase.ready()) {
    if (Firebase.RTDB.setFloat(&fbdo, "/mobile/level", foodLevel)) {
      Serial.println("Food level sent successfully.");
    } else {
      Serial.print("Failed to send food level: ");
      Serial.println(fbdo.errorReason());
    }
  }
}

void checkSchedules() {
  // Get current time in "HH:MM" format
  time_t now = time(nullptr);
  struct tm* timeInfo = localtime(&now);
  char currentTime[6];
  sprintf(currentTime, "%02d:%02d", timeInfo->tm_hour, timeInfo->tm_min);

  // To avoid multiple triggers in the same minute
  static String lastTriggered = "";
  if (lastTriggered == String(currentTime)) {
    return;
  }

  // Retrieve scheduled times from Firebase
  if (Firebase.ready()) {
    for (int i = 0; i < 3; i++) {  // Adjust the range based on the number of scheduled times
      String path = "/mobile/schedule/" + String(i);

      if (Firebase.RTDB.getString(&fbdo, path)) {  // Fetch each scheduled time as a string
        String scheduledTime = fbdo.stringData();

        Serial.print("Scheduled Time ");
        Serial.print(i);
        Serial.print(": ");
        Serial.println(scheduledTime);

        // Compare the scheduled time with the current time
        if (scheduledTime == String(currentTime)) {
          Serial.println("Scheduled time matched.");

          // Update Firebase to open the door
          scheduleDoor();

          lastTriggered = String(currentTime);
          break;  // Only trigger once per minute
        }
      } else {
        Serial.print("Failed to get schedule time at ");
        Serial.print(path);
        Serial.print(": ");
        Serial.println(fbdo.errorReason());
      }
    }
  }
}

void scheduleDoor() {
  if (!Firebase.ready()) return;

  // Send alert
  if (Firebase.RTDB.setInt(&fbdo, "/esp/data", 1)) {
    Serial.println("Alert Activated successfully.");
  } else {
    Serial.print("Failed to send alert: ");
    Serial.println(fbdo.errorReason());
  }

  objectDetection();  // Check object detection for 5 seconds
}

void objectDetection() {
  unsigned long startTime = millis();  // Start timer

  while (millis() - startTime < 30000) {  // Check for 5 seconds
    // Trigger the ultrasonic sensor
    digitalWrite(trigPin1, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin1, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin1, LOW);

    long duration = pulseIn(echoPin1, HIGH);
    int distance = duration * 0.034 / 2;

    if (distance < 50) {  // Object detected within 100cm
      if (Firebase.ready()) {
        if (Firebase.RTDB.setInt(&fbdo, "/computer/door", 1)) {
          Serial.println("Object Detected.");
          Serial.print("Distance: ");
          Serial.println(distance);

          checkAnimalDetection();  // Check pet detection
          return;                  // Exit once an object is detected and processed
        } else {
          Serial.print("Failed to send object detection: ");
          Serial.println(fbdo.errorReason());
        }
      }
    }
    delay(500);  // Reduce sensor polling frequency
  }
  Firebase.RTDB.setInt(&fbdo, "/esp/data", 0);
  Firebase.RTDB.setInt(&fbdo, "/alert/data", 1);
  delay(5000);
  Firebase.RTDB.setInt(&fbdo, "/alert/data", 0);

  Serial.println("No object detected within 5 seconds.");
}


void checkAnimalDetection() {
  bool doorOpened = false;
  unsigned long startTime = millis();

  while (millis() - startTime < 10000) {  // Check for 10 seconds
    if (Firebase.RTDB.getInt(&fbdo, "/computer/cat-or-dog")) {
      int catOrDogValue = fbdo.intData();

      // Open door only if the value has changed and is either 0 (Dog) or 1 (Cat)
      if (catOrDogValue != lastValue && (catOrDogValue == 0 || catOrDogValue == 1)) {
        lastValue = catOrDogValue;  // Update last known value

        // Display detected animal on LCD
        String animal = (catOrDogValue == 0) ? "Dog" : "Cat";
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Detected:");
        lcd.setCursor(0, 1);
        lcd.print(animal);

        // Open door
        Serial.println("Detected pet, opening door.");
        rotateStepperForward();
        doorOpened = true;
        break;  // Stop checking once door is opened
      }
    }
    delay(500);  // Reduce Firebase request frequency
  }

  // Keep door open until ultrasonic detects object < 40cm
  if (doorOpened) {
    while (true) {
      digitalWrite(trigPin1, LOW);
      delayMicroseconds(2);
      digitalWrite(trigPin1, HIGH);
      delayMicroseconds(10);
      digitalWrite(trigPin1, LOW);

      long duration = pulseIn(echoPin1, HIGH);
      int distance = duration * 0.034 / 2;

      if (distance < 40) {
        Serial.println("Pet is still near, keeping door open.");
        delay(1000);
      } else {
        Serial.println("Pet left, closing door in 5 seconds.");
        delay(5000);
        rotateBackToPrevious();
        Firebase.RTDB.setInt(&fbdo, "/computer/door", 0);  // Close door
        Firebase.RTDB.setInt(&fbdo, "/esp/data", 0);
        Firebase.RTDB.setInt(&fbdo, "/esp32/data", 0);
        Serial.println("Door closed.");
        break;
      }
    }
  } else {
    Serial.println("No Pet Detected.");
    Firebase.RTDB.setInt(&fbdo, "/computer/door", 0);  // Close door
    Firebase.RTDB.setInt(&fbdo, "/esp/data", 0);
    Firebase.RTDB.setInt(&fbdo, "/esp32/data", 0);
  }
}