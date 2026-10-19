#!/bin/bash
set -euo pipefail

echo "==> NextStep AI: Starting Vercel Web Build..."

# If Flutter is not installed in the container, install stable Flutter SDK
if ! command -v flutter &> /dev/null; then
  echo "==> Flutter not found in environment. Installing stable Flutter SDK..."
  FLUTTER_HOME="$HOME/flutter-sdk"
  if [ ! -d "$FLUTTER_HOME" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
  fi
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

echo "==> Flutter SDK version:"
flutter --version

echo "==> Resolving dependencies..."
flutter pub get

# Ensure .env exists to satisfy asset bundle if missing
if [ ! -f .env ]; then
  echo "==> Generating .env for build..."
  if [ -n "${GROQ_API_KEY:-}" ]; then
    echo "GROQ_API_KEY=${GROQ_API_KEY}" > .env
  else
    touch .env
  fi
fi

echo "==> Running static analysis..."
dart analyze

echo "==> Running automated tests..."
flutter test

echo "==> Building Flutter Web (Release)..."
flutter build web --release

# Ensure vercel.json routing is included in output directory
if [ -f vercel.json ]; then
  cp vercel.json build/web/vercel.json
fi

echo "==> Build complete! Output located at build/web"
