#import "RecordAudio.h"
#import "RCTLog.h"

@implementation RecordAudio {
    
    AVAudioSession *recordSession;
    AVAudioRecorder *audioRecorder;
    NSString *pathForFile;
}

// Expose this module to the React Native bridge
RCT_EXPORT_MODULE()


- (NSString *)getCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/audioCache", documentsDirectory];
}

// Persist data
RCT_EXPORT_METHOD(startRecord:(NSString *)fileName
                  callback:(RCTResponseSenderBlock)successCallback) {
    
    // Validate the file name has positive length
    if ([fileName length] < 1) {
        
        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"param"  : @"Your file does not have a name."
                                      };
        
        // Javascript error handling
        successCallback(@[resultsDict]);
        return;
        
    }
    
    NSRange isRangeWav = [fileName rangeOfString:@".wav" options:NSCaseInsensitiveSearch];
    
    if (isRangeWav.location == NSNotFound) {
        fileName = [NSString stringWithFormat:@"%@.wav",fileName];
    }
    
    NSString *cachePath = [self getCachePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:cachePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Create the path that the file will be stored at
    pathForFile = [NSString stringWithFormat:@"%@/%@", cachePath, fileName];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:pathForFile];
    
    NSDictionary *recordSettings  = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                          [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                          [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
                          [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                          [NSData data], AVChannelLayoutKey, nil];
    
    // Initialize the session for the recording
    NSError *error = nil;
    recordSession = [AVAudioSession sharedInstance];
    [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:audioFileURL
                         settings:recordSettings
                         error:&error];
        
    audioRecorder.delegate = self;
    
    // Validate no errors in the session initialization
    if (error) {
        
        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"param"  : [error localizedDescription]
                                      };
        
        // Javascript error handling
        successCallback(@[resultsDict]);
        return;
        
    } else {
        
        // prepare the recording
        [audioRecorder prepareToRecord];
        
    }
    
    // if recording is in progress, stop
    if (audioRecorder.recording) {
        
        [audioRecorder stop];
        [recordSession setActive:NO error:nil];
        
    }
    
    // start recording
    [recordSession setActive:YES error:nil];
    [audioRecorder record];
    
    // Craft a success return message
    NSDictionary *resultsDict = @{
                                  @"success" : @YES,
                                  @"param" : @"Successfully started."
                                  };
    
    // Call the JavaScript sucess handler
    successCallback(@[resultsDict]);
}

// Persist data
RCT_EXPORT_METHOD(stopRecord:(RCTResponseSenderBlock)successCallback) {
    
    // Validate that the file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if file exists
    if (![fileManager fileExistsAtPath:pathForFile]){
        
        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"param"  : @"File does not exist in app documents directory."
                                      };
        
        // Javascript error handling
        successCallback(@[resultsDict]);
        return;
        
    }
    
    // Validate that session and recorder exist to stop
    if (recordSession && audioRecorder) {
        
        // if recording is in progress, stop
        if (audioRecorder.recording) {
            
            [audioRecorder stop];
            [recordSession setActive:NO error:nil];
            
            // Craft a success return message
            NSDictionary *resultsDict = @{
                                          @"success" : @YES,
                                          @"param"  : pathForFile
                                          };
            
            // Call the JavaScript sucess handler
            successCallback(@[resultsDict]);
            return;
            
        } else {
            
            // Show failure message
            NSDictionary *resultsDict = @{
                                          @"success" : @NO,
                                          @"param"  : @"Recording not in progress. Can not be stopped."
                                          };
            
            // Javascript error handling
            successCallback(@[resultsDict]);
            return;
        }
        
    } else {
        
        // Show failure message
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"param"  : @"Recording was not ever started. Can not be stopped."
                                      };
        
        // Javascript error handling
        successCallback(@[resultsDict]);
        return;
        
    }
}

RCT_EXPORT_METHOD(clearCache:(RCTResponseSenderBlock)callback)
{
    NSString * filepath = [self getCachePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exists = [manager fileExistsAtPath:filepath isDirectory:false];
    if (!exists) {
        NSDictionary *resultsDict=@{
        @"success" : @NO,
        @"messsge" : @"not exist"
        };
        return callback(@[resultsDict]);
    }
    [manager removeItemAtPath:filepath error:nil];
    NSDictionary *resultsDict=@{
    @"success" : @YES,
    @"messsge" : filepath
    };
    callback(@[resultsDict]);
}

@end

