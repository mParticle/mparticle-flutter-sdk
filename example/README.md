# mparticle_flutter_sdk_example

Demonstrates how to use the mparticle_flutter_sdk plugin.

## Prerequisites

- Flutter SDK (stable channel)
- Xcode 16.4 or later (for iOS development)
- CocoaPods
- iOS 13.0+ (minimum deployment target)

## Setup

### 1. Install Flutter

If Flutter is not installed, follow these steps:

```bash
# Clone Flutter SDK to your home directory
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to your PATH in ~/.zshrc
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor
```

### 2. Install Dependencies

```bash
# From the example directory
cd example

# Get Flutter packages
flutter pub get

# Precache iOS artifacts (first time only)
flutter precache --ios
```

### 3. Install iOS Dependencies

```bash
# Install CocoaPods dependencies
cd ios
pod install
cd ..
```

**Note:** The Podfile has been configured with iOS 13.0 as the minimum deployment target to ensure compatibility with Flutter and mParticle dependencies.

## Running the App

### iOS Simulator

```bash
# List available devices
flutter devices

# Run on iOS simulator
flutter run -d <device-id>

# Or simply
flutter run
```

### iOS Device

```bash
# Connect your iOS device and ensure it's in Developer Mode
flutter run -d <your-device-name>
```

## Resources

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Flutter Documentation](https://flutter.dev/docs)
- [mParticle Documentation](https://docs.mparticle.com/)
