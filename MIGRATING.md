<!-- markdownlint-disable MD024 -->

# Migration Guides

This document describes upgrade steps for breaking changes in the mParticle Flutter SDK. It only covers changes that require action on the Flutter side (`ios/Podfile`, Xcode project settings, Dart code, or the `MPRoktEvents` event channel).

For changes in the underlying native iOS SDK (database migration, deprecated `UIApplicationDelegate` methods, removed `AppDelegateProxy`, regional routing / ATS, Rokt event class renames at the Swift/Objective-C level, etc.), refer to the [mParticle Apple SDK 9 migration guide](https://github.com/mParticle/mparticle-apple-sdk/blob/main/MIGRATING.md#migrating-from-versions--900).

## Migrating from versions < 2.0.0

Version 2.0.0 wraps the mParticle Apple SDK 9 on iOS. No Dart source changes are required for existing `selectPlacements`, `purchaseFinalized`, or `MPRoktEvents` integrations, but the iOS build configuration must be updated.

### iOS deployment target raised to 15.6

The plugin now requires iOS 15.6+. Update the following in your app:

- `ios/Podfile`:

  ```ruby
  platform :ios, '15.6'
  ```

- `ios/Flutter/AppFrameworkInfo.plist` — set `MinimumOSVersion` to `15.6`.
- In Xcode, raise the Runner target's **iOS Deployment Target** to `15.6`.

After updating, run:

```sh
cd ios
pod deintegrate
pod install
cd ..
```

### Updated CocoaPods dependencies

The plugin now depends on mParticle Apple SDK 9. In SDK 9 the podspec was restructured and subspecs are gone, so the `/mParticle` suffix is no longer valid:

| Before (1.x)                           | After (2.0.0)                |
| -------------------------------------- | ---------------------------- |
| `mParticle-Apple-SDK/mParticle ~> 8.5` | `mParticle-Apple-SDK ~> 9.0` |

If your app's `Podfile` pins a subspec (for example `pod 'mParticle-Apple-SDK/mParticle', ...`), update it to the new form above.

### Rokt event channel — new event types

Consumers of the `EventChannel('MPRoktEvents')` stream will receive four additional `event` values. The string values for **previously existing** event types are unchanged (`FirstPositiveEngagement`, `OfferEngagement`, `PlacementReady`, `PlacementClosed`, `PlacementCompleted`, `PlacementFailure`, `PlacementInteractive`, `PositiveEngagement`, `OpenUrl`, `CartItemInstantPurchase`, `InitComplete`), so existing listeners continue to work.

New event types and their payload keys:

| `event`                            | Additional keys                                  |
| ---------------------------------- | ------------------------------------------------ |
| `CartItemInstantPurchaseInitiated` | `cartItemId`, `catalogItemId`                    |
| `CartItemInstantPurchaseFailure`   | `cartItemId`, `catalogItemId`, `error`           |
| `InstantPurchaseDismissal`         | —                                                |
| `CartItemDevicePay`                | `cartItemId`, `catalogItemId`, `paymentProvider` |

Any `switch (event['event'])` that did not have a `default` branch should be extended to handle (or explicitly ignore) the new types. Example:

```dart
roktEventChannel.receiveBroadcastStream().listen((dynamic event) {
  final Map<String, dynamic> payload = Map<String, dynamic>.from(event);
  switch (payload['event']) {
    case 'PlacementReady':
      // ...
      break;
    case 'CartItemInstantPurchase':
      // ...
      break;
    case 'CartItemInstantPurchaseInitiated':
    case 'CartItemInstantPurchaseFailure':
    case 'InstantPurchaseDismissal':
    case 'CartItemDevicePay':
      // New in 2.0.0 — handle or ignore as needed.
      break;
    default:
      break;
  }
});
```

### New Rokt API: `selectShoppableAds` (iOS only)

```dart
await MparticleFlutterSdk.getInstance().then((mp) => mp?.rokt.selectShoppableAds(
      identifier: 'shoppable-ads-placement',
      attributes: {'email': 'user@example.com'},
    ));
```

- **iOS**: proxies to `MParticle.sharedInstance().rokt.selectShoppableAds(...)`.
- **Android**: the method is exposed for API parity but is a no-op (logs a warning).
- **Web**: not implemented — calls will throw `MissingPluginException`.

Events for a shoppable ads placement are delivered on the existing `MPRoktEvents` `EventChannel` once `selectShoppableAds` has been called.

The Rokt Apple Pay payment extension (for example `RoktStripePaymentExtension`) is **not** proxied through Dart. Integrators must register it directly from native Swift/Objective-C in the host app (for example `ios/Runner/AppDelegate.swift`), after `MParticle.sharedInstance().start(with:)`. See the [Apple SDK Rokt integration section](https://github.com/mParticle/mparticle-apple-sdk/blob/main/README.md#rokt-integration) for the exact snippet.
