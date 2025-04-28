#!/bin/bash

# Check if .env file exists
if [ ! -f ".env" ]; then
  echo "Error: .env file not found. Please create one based on .env.example."
  exit 1
fi

# Read API key from .env file
GOOGLE_MAPS_API_KEY=$(grep GOOGLE_MAPS_API_KEY .env | cut -d '=' -f2)

# Update Android string resources
echo "Updating Android API keys..."
sed -i '' "s|AIzaSyCLTD_badYbt-EY9qA1nA_6QCz9-b8m8s8|$GOOGLE_MAPS_API_KEY|g" android/app/src/main/res/values/strings.xml

# Update iOS plist file
echo "Updating iOS API keys..."
sed -i '' "s|AIzaSyCLTD_badYbt-EY9qA1nA_6QCz9-b8m8s8|$GOOGLE_MAPS_API_KEY|g" ios/Runner/ApiKeys.plist

echo "API keys updated successfully." 