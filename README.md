# Chuspita

**Keep every wallet, currency, and journey within reach.**

[![CI](https://github.com/lponzebellido/chuspita/actions/workflows/ci.yml/badge.svg)](https://github.com/lponzebellido/chuspita/actions/workflows/ci.yml)

## About

Chuspita is a personal finance manager for keeping expenses, income, wallets,
and transfers clear and easy to understand.

It is especially useful while traveling, when money may be spread across cash,
cards, bank accounts, and different currencies. Chuspita helps travelers keep a
transparent record of their movements without losing sight of where their money
is or how it has changed along the way.

The name is inspired by the *chuspa*, a traditional Andean pouch, and reflects
the idea of carrying a small, dependable wallet wherever the journey leads.

Chuspita currently supports:

- Multiple wallets and currencies.
- Expenses, income, and transfers between wallets.
- Cross-currency transfers with an editable conversion factor.
- Categories, filters, summaries, and spending statistics.
- Spanish and English interfaces.
- Light and dark themes.

Financial data is currently stored locally. Each installation has its own
independent database and data is not synchronized through GitHub.

## Requirements

- Git.
- Flutter stable. The project is developed with Flutter 3.47.1 and Dart 3.13.1.
- For Android: Android Studio, the Android SDK, and an emulator or device.
- For iOS: macOS, Xcode, a simulator or device, and CocoaPods.

Check the development environment before starting:

```bash
flutter --version
flutter doctor -v
```

## Set up the project on another computer

```bash
git clone https://github.com/lponzebellido/chuspita.git
cd chuspita
flutter pub get
flutter test
flutter analyze
```

`pubspec.lock` and the required generated files are versioned, so running
`build_runner` is not necessary to start the project.

## Run the application

List the available devices first:

```bash
flutter devices
```

Run the application using an identifier shown by the previous command:

```bash
flutter run -d <device-id>
```

### Android

To use an existing emulator:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter devices
flutter run -d <device-id>
```

You can also connect a phone with USB debugging enabled and authorize the
computer when prompted.

Every successful GitHub Actions run also produces a test APK. Open the run from
the repository's **Actions** tab and download `chuspita-android-debug` from its
**Artifacts** section. After extracting it, install `app-debug.apk` on an
Android device. This development build is not intended for store distribution.

### iOS

Open the simulator before running the application:

```bash
open -a Simulator
flutter devices
flutter run -d <device-id>
```

A physical iPhone requires a development team to be configured in Xcode.

## Everyday development workflow

```bash
git pull
flutter pub get
flutter test
flutter analyze
```

Run `flutter pub get` again whenever `pubspec.yaml` or `pubspec.lock` changes.
