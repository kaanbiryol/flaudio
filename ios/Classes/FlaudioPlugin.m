#import "FlaudioPlugin.h"
#if __has_include(<flaudio/flaudio-Swift.h>)
#import <flaudio/flaudio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flaudio-Swift.h"
#endif

@implementation FLAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFLAudioPlugin registerWithRegistrar:registrar];
}
@end
