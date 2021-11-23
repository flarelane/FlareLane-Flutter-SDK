#import "FlareLaneFlutterPlugin.h"
#if __has_include(<flarelane_flutter/flarelane_flutter-Swift.h>)
#import <flarelane_flutter/flarelane_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flarelane_flutter-Swift.h"
#endif

@implementation FlareLaneFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlareLaneFlutterPlugin registerWithRegistrar:registrar];
}
@end
