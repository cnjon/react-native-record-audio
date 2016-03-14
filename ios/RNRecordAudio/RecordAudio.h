#import "RCTBridgeModule.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordAudio : NSObject <RCTBridgeModule, AVAudioRecorderDelegate>

@end