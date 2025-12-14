# Fit Logger

A Flutter workout tracking app with session planning and progressive overload tracking.

## Features

- **Weekly Session Planning**: Organize workouts by day with customizable exercise templates
- **Exercise Library**: 30+ exercises covering bodyweight, barbell, dumbbell, kettlebell, resistance bands, and cardio
- **Smart Logging**: Pre-filled forms with previous workout data for easy progress tracking
- **Difficulty Tracking**: Mark workouts as Easy/Medium/Hard to guide progressive overload
- **Personal Notes**: Add tips and observations to each exercise for week-to-week reference
- **Workout History**: View and edit past workouts with filtering options

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.1 or higher)
- For Android: [Android Studio](https://developer.android.com/studio) with Android SDK
- For Web: Modern web browser (Chrome, Firefox, Safari, Edge)

## Getting Started

### Install Dependencies

```bash
cd fit_logger
flutter pub get
```

### Run in Development

```bash
# Web
flutter run -d chrome

# Android (with device/emulator connected)
flutter run
```

## Deployment

### Web Deployment

1. Build for web:
```bash
flutter build web --release
```

2. Deploy the `build/web` directory to your hosting service:
   - **Firebase Hosting**: `firebase deploy`
   - **Netlify**: Drag `build/web` folder to Netlify dashboard
   - **GitHub Pages**: Copy contents to gh-pages branch

### Android Deployment

#### Development APK (for testing)

```bash
# Build APK
flutter build apk --release

# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Play Store Release

1. Generate signing key (first time only):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure signing in `android/key.properties`

3. Build app bundle:
```bash
flutter build appbundle --release
```

4. Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console

## Project Structure

```
lib/
  ├── core/              # Constants, enums, utilities
  ├── domain/            # Business entities and repository interfaces
  ├── data/              # Repository implementations and data sources
  ├── presentation/      # UI (providers, screens, widgets)
  └── services/          # Business logic services
```

## Development

- Run tests: `flutter test`
- Check code: `flutter analyze`
- Format code: `flutter format .`

For more information, see the [Flutter documentation](https://docs.flutter.dev/).
