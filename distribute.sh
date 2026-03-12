#!/bin/bash
set -e

FIREBASE_APP_ID="1:420814368276:android:3e5eab34e9ade965a3c101"
RELEASE_NOTES="${1:-Beta release}"
TESTERS="${TESTERS:-olabodeodetunde1@gmail.com,babatopeajayi2@gmail.com}"

echo "==> Building release APK..."
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
  echo "ERROR: APK not found at $APK_PATH"
  exit 1
fi

echo "==> APK built: $APK_PATH ($(du -sh "$APK_PATH" | cut -f1))"

echo "==> Uploading to Firebase App Distribution..."

DISTRIBUTE_CMD="firebase appdistribution:distribute \"$APK_PATH\" --app \"$FIREBASE_APP_ID\" --release-notes \"$RELEASE_NOTES\""

if [ -n "$TESTERS" ]; then
  DISTRIBUTE_CMD="$DISTRIBUTE_CMD --testers \"$TESTERS\""
fi

eval $DISTRIBUTE_CMD

echo "==> Done! Testers will receive an email invite."
