//
//  KuQUIEngine.h
//  KuQ
//

#import "BOSAudioRecorder.h"
#import "ContactUtils.h"

@interface BOSAudioRecorder (Private)
-(NSDictionary *)recordingSettings;
-(void)startReceivedRecordingCallBackTimer;
@end

@implementation BOSAudioRecorder
@synthesize recorderingPath = _recorderingPath;
@synthesize audioRecorder = _audioRecorder;
@synthesize deletedRecording = _deletedRecording;

#pragma mark - init & dealloc

- (id)init {
    self = [super init];
    if (self) {
        _recorderingPath = [[ContactUtils recordFilePath] copy];
    }
    return self;
}

-(void)dealloc
{
    //BOSRELEASE_audioRecorder);
    //BOSRELEASE_recorderingPath);
    //[super dealloc];
}

#pragma mark - Start Record & Stop Record

- (BOOL)startRecord
{
    return [self startRecordForDuration:0];    
}

- (BOOL)startRecordForDuration: (NSTimeInterval) duration
{
    if (!_audioRecorder.recording) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([[audioSession category] isEqualToString:AVAudioSessionCategoryPlayAndRecord] ||
            [[audioSession category] isEqualToString:AVAudioSessionCategoryRecord]) {
            if ([audioSession isInputAvailable]) {
                NSError *error = nil;
                NSDictionary *recordingSettings = [self recordingSettings];
                NSURL *fullPathURL = [NSURL fileURLWithPath:_recorderingPath];
                _audioRecorder = [[AVAudioRecorder alloc] initWithURL:fullPathURL
                                                          settings:recordingSettings
                                                          error:&error];
                _audioRecorder.delegate = self;
                _audioRecorder.meteringEnabled = YES;
                if (!error) {
                    if ([_audioRecorder prepareToRecord]) {
                        _deletedRecording = NO;
                        [self startReceivedRecordingCallBackTimer];
                        if (duration < 0.001) {
                            return [_audioRecorder record];
                        }
                        else {
                            return [_audioRecorder recordForDuration:duration];
                        }
                    }
                    else BOSERROR(@"AVAudioRecorder prepareToRecord failure.");
                }else BOSERROR(@"AVAudioRecorder alloc failure.");
            }else BOSERROR(@"Audio input hardware not available.");
        }else BOSERROR(@"AudioSession not allowed to record.");
    }else BOSERROR(@"AVAudioRecorder already in recording.");
    return NO;
}

- (void)stopRecord
{
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
}

- (void)stopAndDeleteRecord
{
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
    if (!_deletedRecording) {
        _deletedRecording = [_audioRecorder deleteRecording];
    }
}

- (void)enableAudioSession {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)disableAudioSession {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    [self disableAudioSession];
    if (_delegate && [_delegate respondsToSelector:@selector(bosAudioRecorderDidFinishRecording:successfully:)]) {
        [_delegate bosAudioRecorderDidFinishRecording:self successfully:flag];
    }
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    [self disableAudioSession];
    if (_delegate && [_delegate respondsToSelector:@selector(bosAudioRecorderEncodeErrorDidOccur:error:)]) {
        [_delegate bosAudioRecorderEncodeErrorDidOccur:self error:error];
    }
}

- (void)audioRecorderReceivedRecordingCallBack:(NSTimer*)timer
{
    if (_audioRecorder.recording) {
        [_audioRecorder updateMeters];
        float peakPower = pow(10, (0.05 * [_audioRecorder peakPowerForChannel:0]));
        float averagePower = pow(10, (0.05 * [_audioRecorder averagePowerForChannel:0]));
        float currentTime = _audioRecorder.currentTime;
        if (_delegate && [_delegate respondsToSelector:@selector(bosAudioRecorderReceivedRecording:peakPower:averagePower:currentTime:)]) {
            [_delegate bosAudioRecorderReceivedRecording:self peakPower:peakPower averagePower:averagePower currentTime:currentTime];
        }
    }  
}

#pragma mark - Private methods

- (void)startReceivedRecordingCallBackTimer{
    if(_recordTimer){[_recordTimer invalidate]; _recordTimer=nil;}
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector(audioRecorderReceivedRecordingCallBack:) 
                                                  userInfo:nil 
                                                   repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop]; 
    [runLoop addTimer:_recordTimer forMode:NSDefaultRunLoopMode];
}

-(NSDictionary *)recordingSettings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
            [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
            [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
            [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
            [NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,
            [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
            [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];
}

@end

