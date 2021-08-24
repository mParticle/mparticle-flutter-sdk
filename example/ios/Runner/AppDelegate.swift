import UIKit
import Flutter
import mParticle_Apple_SDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let options = MParticleOptions(key: "api-key", secret: "secret")
    options.logLevel = MPILogLevel.verbose
    MParticle.sharedInstance().start(with: options)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
