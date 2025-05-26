# pet_feeder

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Set Icon
```
dev_dependencies:
  flutter_launcher_icons: ^0.9.2

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png" # Path to your app icon image

```
```
flutter pub get
flutter pub run flutter_launcher_icons:main
```
```
flutter run
```

Build
```
flutter build apk --build-name=1.0 --build-number=1
flutter build apk --build-name=1.1 --build-number=2
flutter build apk --build-name=1.2 --build-number=3
```