# API Keys Setup

This project requires API keys for certain services like Google Maps. For security reasons, these keys are not included in the source code repository and need to be set up separately.

## Setup Instructions

1. Create a `.env` file in the project root directory based on the example file:
   ```bash
   cp scripts/env.example .env
   ```

2. Edit the `.env` file and replace the placeholder values with your actual API keys:
   ```
   GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key
   ```

3. Run the API keys update script to apply the keys to the project files:
   ```bash
   ./scripts/update_api_keys.sh
   ```

4. The script will update the necessary files in the Android and iOS projects.

## For Development

In development mode, the application uses Flutter's dotenv package to load API keys at runtime:

1. Make sure the `.env` file is in your project root
2. The app will automatically load the keys when it starts
3. If you change any keys, you only need to restart the app

## For CI/CD Pipelines

For continuous integration and deployment, you'll need to:

1. Store your API keys as secrets in your CI/CD system (GitHub Secrets, CircleCI Environment Variables, etc.)
2. Create the `.env` file dynamically during the build process, for example:
   ```bash
   echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY" > .env
   ```
3. Run the update script as part of your build process:
   ```bash
   ./scripts/update_api_keys.sh
   ```

## Adding New API Keys

If you need to add new API keys:

1. Add the key to the `.env` file with an appropriate variable name
2. Modify `scripts/update_api_keys.sh` script to include the new key
3. Update the relevant platform files to use the new key
4. Add a getter method in `lib/config/app_config.dart` to access the key

## Important Notes

- Never commit your `.env` file or any file containing actual API keys to version control
- Always use placeholder values in committed files
- The `.env` file is listed in `.gitignore` to prevent accidental commits
- The runtime loading of `.env` files is a development convenience - for production, keys should be embedded at build time using the update script

## Platform-Specific Details

### Android
API keys are stored in `android/app/src/main/res/values/strings.xml` and referenced in `AndroidManifest.xml`.

### iOS
API keys are stored in `ios/Runner/ApiKeys.plist` and loaded in `AppDelegate.swift`.

## Updating Keys
If you need to update your API keys, simply edit the `.env` file and run the update script again. 