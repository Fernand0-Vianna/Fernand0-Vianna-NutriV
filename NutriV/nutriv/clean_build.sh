#!/bin/bash

# NutriV Clean & Optimize Script
# Run this before building to avoid memory issues

echo "🧹 Cleaning build artifacts..."
flutter clean

echo "📦 Removing caches..."
rm -rf .dart_tool/
rm -rf build/
rm -rf android/build/
rm -rf ios/build/
rm -rf linux/build/
rm -rf web/build/
rm -rf .gradle/
rm -rf android/.gradle/
rm -rf ios/Pods/

echo "🗑️ Removing generated files..."
find lib/ -name "*.g.dart" -delete
find lib/ -name "*.freezed.dart" -delete
find lib/ -name "*.mocks.dart" -delete

echo "✅ Clean complete! Run your build now."