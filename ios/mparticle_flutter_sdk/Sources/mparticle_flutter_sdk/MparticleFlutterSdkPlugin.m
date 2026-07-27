#import "MparticleFlutterSdkPlugin.h"
#if __has_include(<mparticle_flutter_sdk/mparticle_flutter_sdk-Swift.h>)
#import <mparticle_flutter_sdk/mparticle_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mparticle_flutter_sdk-Swift.h"
#endif

@implementation MparticleFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMparticleFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
