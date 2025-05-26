# Smart Automated Pet Feeding System

![Platform](https://img.shields.io/badge/platform-IoT%20%7C%20Mobile%20App-blue) ![Status](https://img.shields.io/badge/status-In%20Progress-yellow)

A cross-platform smart pet feeding system that combines IoT, computer vision, and mobile technology to automatically feed and monitor pets with real-time notifications and facial recognition.

## 🐾 Project Overview

This system automates the pet feeding process while providing real-time monitoring and personalized care. It identifies the pet using facial recognition, dispenses customized food portions, and sends alerts to the owner through a mobile app. Perfect for busy pet owners who want to ensure their pets are fed and healthy.

## 🧠 Key Features

- ✅ Automatic food dispensing
- 📷 Facial recognition to identify specific pets
- 🎥 Real-time camera feed and monitoring
- 🔔 Push notifications and feeding logs via mobile app
- 🎞️ Plays pet-attracting videos during feeding
- 📱 Mobile app built with Flutter for Android/iOS
- 🔌 Arduino-based hardware integration

## 🔧 System Architecture

### 1. Hardware Components (IoT Module)
- **Arduino UNO / ESP32**
- **Servo motor** to control food dispenser
- **Camera module (ESP32-CAM / USB cam)** for face detection
- **Wi-Fi module** for cloud communication
- **IR Sensor** to detect pet presence

### 2. Software Components
- **Python Backend**
  - Pet face recognition using OpenCV and trained ML model
  - MQTT / HTTP for IoT communication
- **Flutter Mobile App**
  - Displays live camera feed
  - Shows feeding history and system status
  - Sends notifications and alerts
- **Firebase**
  - Cloud database for storing logs and real-time updates
  - Firebase Authentication for user login

## 📱 Mobile App Screens

- Home screen with pet status
- Live video monitoring
- Feeding history and schedule management
- Notifications and alerts
- Settings and user profile

## 🤖 How It Works

1. The camera detects motion and identifies if the approaching pet matches the trained face data.
2. If verified, the servo motor activates the food dispenser.
3. The mobile app is notified and updates the feeding log.
4. Owners can view live footage, receive alerts, and monitor pet activity remotely.

## 🔌 Setup Instructions

### Hardware
1. Connect the servo motor, camera, and IR sensor to the Arduino/ESP32.
2. Upload the Arduino sketch for motor control and camera streaming.
3. Ensure Wi-Fi credentials are set correctly for MQTT communication.

## Firebase Setup
Configure Firebase project and enable Authentication & Firestore.

Add your google-services.json to the Flutter app for Android.

## 📊 Future Improvements

Nutrient tracking and smart portion control
Voice command integration via Alexa/Google Assistant
Multi-pet support with profile-based feeding
Remote firmware updates and diagnostics

## 📚 Technologies Used
Tech Stack	Description
Arduino/ESP32	IoT controller and camera
OpenCV	Real-time face recognition
Flutter	Cross-platform mobile development
Firebase	Real-time database & cloud messaging
Python	Backend server and logic

📎 Repository Structure

Smart-Automated-Pet-Feeding-System/
├── arduino/             # Arduino/ESP32 code
├── backend/             # Python backend with ML & camera control
├── pet_feeder_app/      # Flutter mobile app
├── dataset/             # Face dataset for pets
└── README.md


📄 License
This project is open-source and available under the MIT License.

This smart system is designed to give your pets the care they deserve, even when you're not home. 🐶🐱

