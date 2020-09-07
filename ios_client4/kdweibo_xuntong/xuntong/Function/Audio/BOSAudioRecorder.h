//
//  KuQUIEngine.h
//  KuQ
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol BOSAudioRecorderDelegate;

@interface BOSAudioRecorder : NSObject <AVAudioRecorderDelegate>{
@private
    NSTimer *_recordTimer;
}

@property (nonatomic, assign) id<BOSAudioRecorderDelegate> delegate;
@property (nonatomic, strong,readonly) AVAudioRecorder* audioRecorder;
@property (nonatomic, strong,readonly) NSString *recorderingPath;
@property (nonatomic, assign,readonly) BOOL deletedRecording;

- (BOOL)startRecord;
- (BOOL)startRecordForDuration: (NSTimeInterval) duration;
- (void)stopRecord;
- (void)stopAndDeleteRecord;

@end

@protocol BOSAudioRecorderDelegate <NSObject>
-(void)bosAudioRecorderDidFinishRecording:(BOSAudioRecorder *)recorder successfully:(BOOL)success;
-(void)bosAudioRecorderEncodeErrorDidOccur:(BOSAudioRecorder *)recorder error:(NSError *)error;
@optional
-(void)bosAudioRecorderReceivedRecording:(BOSAudioRecorder *)recorder peakPower:(float)peakPower averagePower:(float)averagePower currentTime:(float)currentTime;
@end

