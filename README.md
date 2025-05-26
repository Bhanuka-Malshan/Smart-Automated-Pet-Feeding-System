# 🐾 Pet Feeder App

A new Flutter-based mobile application designed to automate and monitor your pet’s feeding routine. This project is the starting point for a smart pet care system that integrates cross-platform mobile support and background automation using Python.

---

## 🚀 Getting Started

This project is a starting point for a Flutter application.

### 📚 Resources to Learn Flutter:
- [🌟 Write your first Flutter app – Lab](https://docs.flutter.dev/get-started/codelab)
- [📖 Flutter Cookbook – Useful samples](https://docs.flutter.dev/cookbook)
- [📘 Flutter Documentation](https://docs.flutter.dev/)


## 2️⃣ Run the following commands:
bash
Copy
Edit
flutter pub get
flutter pub run flutter_launcher_icons:main

🛠️ Build APKs
To generate APKs with specific versioning:

bash
Copy
Edit
flutter build apk --build-name=1.0 --build-number=1
flutter build apk --build-name=1.1 --build-number=2
flutter build apk --build-name=1.2 --build-number=3
⚙️ Python Automation Setup (Background Script)
🪟 Windows (Task Scheduler)
1. (Optional) Convert Python Script to .exe
bash
Copy
Edit
pip install pyinstaller
pyinstaller --onefile --noconsole your_script.py
2. Create Batch File
bat
Copy
Edit
@echo off
python "C:\path\to\your_script.py"
Save as run_script.bat.

3. Add to Startup
Press Win + R → type shell:startup → press Enter.

Paste run_script.bat or the .exe file here.

4. OR Use Task Scheduler
Open Task Scheduler → Create Basic Task.

Name: Pet Feeder Automation

Trigger: At startup

Action: Start a program

Program: C:\Python39\python.exe

Arguments: C:\path\to\your_script.py

🐧 Linux (Using systemd)
1. Create a systemd service
bash
Copy
Edit
sudo nano /etc/systemd/system/pet_feeder.service
2. Add this content:
ini
Copy
Edit
[Unit]
Description=Pet Feeder Script
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/user/path_to_script.py
WorkingDirectory=/home/user
Restart=always
User=user

[Install]
WantedBy=multi-user.target
3. Enable the service
bash
Copy
Edit
sudo systemctl daemon-reload
sudo systemctl enable pet_feeder
sudo systemctl start pet_feeder
🍏 macOS (Using Launch Agents)
1. Create Launch Agent
bash
Copy
Edit
nano ~/Library/LaunchAgents/com.pet.feeder.plist
2. Add:
xml
Copy
Edit
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.pet.feeder</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/python3</string>
      <string>/Users/yourname/path_to_script.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
3. Load it:
bash
Copy
Edit
launchctl load ~/Library/LaunchAgents/com.pet.feeder.plist
✅ Done!
With the above setup:

Your Flutter app will run with a custom icon 📱

The background Python automation will launch on system startup 💻

