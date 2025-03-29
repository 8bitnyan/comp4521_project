# School Guide App

A Flutter application designed to help students navigate and interact with their school campus. This app includes features like campus map navigation, user authentication, and customizable settings.

## Features

- **User Authentication**: Secure login system for student access
- **Dashboard**: Central hub providing access to all app features
- **Campus Map**: Interactive map showing key campus locations
- **Settings**: Personalize your app experience with theme options and notification preferences

## Getting Started

### Prerequisites

- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio or VS Code with Flutter/Dart plugins
- Android emulator or iOS simulator (or physical device)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/school_guide_app.git
cd school_guide_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Setup Google Maps API Key:
   - Get an API key from the [Google Cloud Console](https://console.cloud.google.com/)
   - For Android: Add your API key to `android/app/src/main/AndroidManifest.xml`
   - For iOS: Add your API key to `ios/Runner/AppDelegate.swift`

### Running the App

```bash
flutter run
```

## Usage

- **Login**: Use the test account (email: test@example.com, password: password) to access the app
- **Dashboard**: View your profile and access different features
- **Map**: Navigate the campus map to find buildings and locations
- **Settings**: Customize your app theme and notification preferences

## Project Structure

```
lib/
├── constants/       # App constants and theme data
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Backend services
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## Tech Stack

- Flutter (UI framework)
- Provider (State management)
- Google Maps Flutter (Map integration)
- Shared Preferences (Local storage)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
