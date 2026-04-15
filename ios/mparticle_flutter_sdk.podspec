#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mparticle_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mparticle_flutter_sdk'
  s.version          = '0.0.1'
  s.summary          = 'mParticle Flutter Wrapper'
  s.description      = <<-DESC
mParticle Flutter Wrapper
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  # SDK 9.0 split requires both umbrella and ObjC pods.
  s.dependency 'mParticle-Apple-SDK', '~> 9.0'
  s.dependency 'mParticle-Apple-SDK-ObjC', '~> 9.0'
  s.dependency 'RoktContracts', '~> 0.1'
  s.platform = :ios, '15.6'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
