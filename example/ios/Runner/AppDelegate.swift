import UIKit
import Flutter
import mParticle_Apple_SDK

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
    
  var isInitialized = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up EventChannel for mParticle initialization notifications
    let controller = window?.rootViewController as! FlutterViewController
    let initializationEventChannel = FlutterEventChannel(
      name: "com.example.mparticle_initialization",
      binaryMessenger: controller.binaryMessenger
    )
    initializationEventChannel.setStreamHandler(self)
    
    // Subscribe to mParticle initialization notification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMParticleInitialized),
      name: NSNotification.Name(rawValue: "mParticleDidFinishInitializing"),
      object: nil
    )

    let options = MParticleOptions(key: "", secret: "")
    options.logLevel = MPILogLevel.verbose
    MParticle.sharedInstance().start(with: options)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - FlutterStreamHandler
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    if isInitialized {
      events(["initialized": true])
    }
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  // MARK: - mParticle Initialization
  
  @objc private func handleMParticleInitialized(notification: Notification) {
    isInitialized = true
    if let eventSink = self.eventSink {
      eventSink(["initialized": true])
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
