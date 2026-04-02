# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.2] - 2026-04-02

## [1.1.1] - 2025-11-21

- fix: SDKE-627 Return true immediately for isInitialized on iOS (#57)

## [1.1.0] - 2025-06-26

- feat: Add support for Rokt
  - feat: Add support for Rokt embedded layout in the Flutter SDK (#50)
  - feat: Passthrough SDK wrapper type to native SDKs (#51)
  - feat: Add RoktConfig support for selectPlacements in Flutter SDK (#52)
  - feat: Add support for Rokt event channel subscription (#53)
  - feat: Add Rokt purchaseFinalized method (#54)
  - refactor: Update selectPlacements parameter from placementId to identifier (#55)

## [1.0.6] - 2025-01-07

- fix: Resolve linting issues (#48)

## [1.0.5] - 2024-07-10

- fix: type 'Null' is not a subtype of type 'String' in getCurrentUser (#46)

## [1.0.4] - 2024-03-15

- chore: Update Android project to Android Gradle Plugin 8.2, update dependencies (#43)

## [1.0.3] - 2022-12-15

- fix: Update mparticle_flutter_sdk.podspec (#37)

## [1.0.2] - 2022-11-10

- fix: migrate from jcenter to mavenCentral, update misc files for Android 13, update Github Actions (#34)
- fix: Update license and static analysis issues (#36)

## [1.0.1] - 2022-07-12

- fix: resolve iOS mapping product attributes

## [1.0.0-beta.1] - 2021-10-20

- feat: Add support for Consent across iOS, Android, and Web
- BREAKING CHANGE: From 0.2.0-alpha.1 to 1.0.0-beta - Migrated public APIs from using positional parameters to named parameters to ensure more developer-friendly APIs. See README.md for new implementation.

## [0.2.0-alpha.1] - 2021-09-22

- feat: Add support for eCommerce across iOS, Android, and Web
- BREAKING CHANGE: From 0.1.0 to 0.2.0 - The API for custom events and screenviews has been modified to be more developer friendly. See README.md for new implementation.

## [0.1.0-alpha.2] - 2021-08-25

- docs: Update README.md

## [0.1.0-alpha.1] - 2021-08-25

- Initial commit for open sourcing mParticle Flutter SDK
  - Custom event and screen event logging
  - Identity API (identify, login, logout, and alias)
  - Github Actions - semantic PR title check; plugin building

[unreleased]: https://github.com/mParticle/mparticle-flutter-sdk/compare/1.1.2...HEAD
[1.1.2]: https://github.com/mParticle/mparticle-flutter-sdk/compare/47676b23d065e77f8ef7c9e2938793a93ec6dcc6...1.1.2
