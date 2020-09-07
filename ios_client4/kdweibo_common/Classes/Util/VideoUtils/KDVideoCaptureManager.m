//
//  VideoCapture.m
//  Video-Pre-research
//
//  Created by 王 松 on 13-6-6.
//  Copyright (c) 2013年 王松. All rights reserved.
//

#import "KDVideoCaptureManager.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define kFramePerSec (int)29

@interface KDVideoCaptureManager () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
    
    dispatch_queue_t movieWritingQueue;
    // Only accessed on movie writing queue
    BOOL readyToRecordAudio;
    BOOL readyToRecordVideo;
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;
    
}

@property (nonatomic, assign) AVCaptureVideoOrientation orientation;

@property (nonatomic, retain) AVCaptureSession *session;

@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;

@property (nonatomic, retain) AVCaptureDeviceInput *audioInput;

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic, retain) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, retain) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, retain) AVAssetWriter *assetWriter;

@property (nonatomic, retain) AVAssetWriterInput *videoWriterInput;

@property (nonatomic, retain) AVAssetWriterInput *audioWriterInput;

@property (nonatomic, copy) NSString *outputFileURL;

@property (nonatomic, assign) NSInteger currentFrame;

@property (nonatomic, assign) NSInteger maxFrame;

@property (nonatomic, assign) CMTime frameDuration;

@property (nonatomic, assign) CMTime nextPTS;

@end

@implementation KDVideoCaptureManager

- (id)init
{
    if (self = [super init]) {
        
		_orientation = AVCaptureVideoOrientationPortrait;
        
        _maxFrame = 30.f * kFramePerSec;
        
        _nextPTS = kCMTimeZero;
        
    }
    
    return self;
}

- (void)setMaxSeconds:(CGFloat)maxSeconds
{
    _maxSeconds = maxSeconds;
    _maxFrame = maxSeconds * kFramePerSec;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)startCaptureWithOutputPath:(NSString *)outputFileURL
{
    [self setAudioDeviceInput];
    dispatch_async(movieWritingQueue, ^{
        
		if ( recordingWillBeStarted || self.recording )
			return;
        
		recordingWillBeStarted = YES;
        
        self.outputFileURL = outputFileURL;
        
        self.started = YES;
        
        if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
            [[self delegate] captureManagerRecordingBegan:self];
        }
        
		// recordingDidStart is called from captureOutput:didOutputSampleBuffer:fromConnection: once the asset writer is setup
		[self.delegate recordingWillStart];
        
		// Create an asset writer
		NSError *error;
        NSURL *movieURL = [NSURL fileURLWithPath:outputFileURL];
		_assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:AVFileTypeMPEG4 error:&error];
		if (error)
			[self showError:error];
	});
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
	if (_assetWriter.status == AVAssetWriterStatusUnknown ) {
		
        if ([_assetWriter startWriting]) {
			[_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
		}
		else {
			[self showError:[_assetWriter error]];
		}
	}
	
	if (_assetWriter.status == AVAssetWriterStatusWriting ) {
		
		if (mediaType == AVMediaTypeVideo) {
			if (_videoWriterInput.readyForMoreMediaData) {
				if (![_videoWriterInput appendSampleBuffer:sampleBuffer]) {
					[self showError:[_assetWriter error]];
				}
			}
		}
		else if (mediaType == AVMediaTypeAudio) {
			if (_audioWriterInput.readyForMoreMediaData) {
				if (![_audioWriterInput appendSampleBuffer:sampleBuffer]) {
					[self showError:[_assetWriter error]];
				}
			}
		}
	}
}

- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
	const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
	size_t aclSize = 0;
	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
	NSData *currentChannelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
	if ( currentChannelLayout && aclSize > 0 )
		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
	else
		currentChannelLayoutData = [NSData data];
	
	NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
											  currentChannelLayoutData, AVChannelLayoutKey,
											  nil];
	if ([_assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
		_audioWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
		_audioWriterInput.expectsMediaDataInRealTime = YES;
		if ([_assetWriter canAddInput:_audioWriterInput])
			[_assetWriter addInput:_audioWriterInput];
		else {
			NSLog(@"Couldn't add asset writer audio input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply audio output settings.");
        return NO;
	}
    
    return YES;
}

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    // 下面这个参数，设置图像质量，数字越大，质量越好
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:512*512.0], AVVideoAverageBitRateKey,
                                           nil ];
    // 设置编码和宽高比。宽高比最好和摄像比例一致，否则图片可能被压缩或拉伸
    NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithFloat:288], AVVideoWidthKey,
                                              [NSNumber numberWithFloat:384], AVVideoHeightKey,
                                              videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    
    // 在不支持竖屏录制的设备上，通过写文件时调整方向, 4.3.3 系统
    
    if (![videoConnection isVideoOrientationSupported]) {
        videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                    [NSNumber numberWithFloat:384], AVVideoWidthKey,
                                    [NSNumber numberWithFloat:288], AVVideoHeightKey,
                                    videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
        // specify the prefered transform for the output file
        CGFloat rotationDegrees = 90.;
        CGFloat rotationRadians = DegreesToRadians(rotationDegrees);
        [self.videoWriterInput setTransform:CGAffineTransformMakeRotation(rotationRadians)];
    }
    
	if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
		_videoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
		_videoWriterInput.expectsMediaDataInRealTime = YES;
		if ([_assetWriter canAddInput:_videoWriterInput])
			[_assetWriter addInput:_videoWriterInput];
		else {
			NSLog(@"Couldn't add asset writer video input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply video output settings.");
        return NO;
	}
    
    return YES;
}

- (void)stopRecording
{
    
    __block KDVideoCaptureManager *weakself = [self retain];
    
    dispatch_async(movieWritingQueue, ^{
		
		if ( recordingWillBeStopped || (weakself.recording == NO) )
        {
            [weakself release];
            return;
        }

		recordingWillBeStopped = YES;
		
		// recordingDidStop is called from saveMovieToCameraRoll
		[weakself.delegate recordingWillStop];
        
		if ([_assetWriter finishWriting]) {
			
			readyToRecordVideo = NO;
			readyToRecordAudio = NO;
            
            [_audioWriterInput release];
			[_videoWriterInput release];
			[_assetWriter release];
			_assetWriter = nil;
            
            weakself.started = NO;
            
            if ([weakself.session isRunning]) {
                [weakself.session stopRunning];
            }
            
            if ([[weakself delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
                    [[weakself delegate] captureManagerRecordingFinished:weakself];
            }
            self.currentFrame = 0;
			
		} else {
			[self showError:[_assetWriter error]];
		}
        [weakself release];
	});
}

- (void)stopAndTearDownCaptureSession
{
    [_session stopRunning];
	if (_session)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_session];
    
	if (movieWritingQueue) {
		dispatch_release(movieWritingQueue);
		movieWritingQueue = NULL;
	}
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
	dispatch_async(movieWritingQueue, ^{
		if ( [self isRecording] ) {
			[self stopRecording];
		}
	});
}

- (BOOL)setupCaptureSession
{
	/*
     Overview: RosyWriter uses separate GCD queues for audio and video capture.  If a single GCD queue
     is used to deliver both audio and video buffers, and our video processing consistently takes
     too long, the delivery queue can back up, resulting in audio being dropped.
     
     When recording, RosyWriter creates a third GCD queue for calls to AVAssetWriter.  This ensures
     that AVAssetWriter is not called to start or finish writing from multiple threads simultaneously.
     
     RosyWriter uses AVCaptureSession's default preset, AVCaptureSessionPresetHigh.
	 */
    
    /*
	 * Create capture session
	 */
    // Set torch and flash mode to auto
//	if ([[self backFacingCamera] hasFlash]) {
//		if ([[self backFacingCamera] lockForConfiguration:nil]) {
//			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
//				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
//			}
//			[[self backFacingCamera] unlockForConfiguration];
//		}
//	}
//	if ([[self backFacingCamera] hasTorch]) {
//		if ([[self backFacingCamera] lockForConfiguration:nil]) {
//			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
//				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeOff];
//			}
//			[[self backFacingCamera] unlockForConfiguration];
//		}
//	}
    
    
    // 24 fps - taking 25 pictures will equal 1 second of video
	self.frameDuration = CMTimeMakeWithSeconds(1./kFramePerSec, 90000);
    
    _session = [[AVCaptureSession alloc] init];
	[_session setSessionPreset:AVCaptureSessionPreset640x480];
    
	/*
	 * Create video connection
	 */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    if ([_session canAddInput:videoIn])
        [_session addInput:videoIn];
    _videoInput = [videoIn retain];
	[videoIn release];
    
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	/*
     RosyWriter prefers to discard late video frames early in the capture pipeline, since its
     processing can take longer than real-time on some platforms (such as iPhone 3GS).
     Clients whose image processing is faster than real-time should consider setting AVCaptureVideoDataOutput's
     alwaysDiscardsLateVideoFrames property to NO.
	 */
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", NULL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([_session canAddOutput:videoOut])
		[_session addOutput:videoOut];
    _videoDataOutput = [videoOut retain];
    videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self videoDataOutput] connections]];
	[videoOut release];
    
    if ([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
	return YES;
}


- (void)setupAndStartCaptureSession
{
	// Create serial queue for movie writing
	movieWritingQueue = dispatch_queue_create("Movie Writing Queue", NULL);
	
    if (!_session)
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:_session];
	
	if (!_session.isRunning)
		[_session startRunning];
}

- (void)pauseCaptureSession
{
	if (_session.isRunning)
		[_session stopRunning];
}

- (void)resumeCaptureSession
{
	if (!_session.isRunning)
		[_session startRunning];
}

#pragma mark Error Handling

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark Camera Properties
// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

- (BOOL)hasTorch
{
    AVCaptureDevicePosition position = [[_videoInput device] position];
    
    if (position == AVCaptureDevicePositionBack) {
        return [[self backFacingCamera] hasTorch];
    } else if (position == AVCaptureDevicePositionFront) {
        return [[self frontFacingCamera] hasTorch];
    } else {
        return NO;
    }
}

- (void)toggleTorch:(BOOL)on
{
    AVCaptureDevicePosition position = [[_videoInput device] position];
    
    if (position == AVCaptureDevicePositionBack && [[self backFacingCamera] hasTorch]) {
        if ([[self backFacingCamera] lockForConfiguration:nil]) {
            if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOn]) {
                [[self backFacingCamera] setTorchMode:AVCaptureTorchModeOn & on];
            }
            [[self backFacingCamera] unlockForConfiguration];
        }
    } else if (position == AVCaptureDevicePositionFront && [[self frontFacingCamera] hasTorch]) {
        if ([[self frontFacingCamera] lockForConfiguration:nil]) {
            if ([[self frontFacingCamera] isTorchModeSupported:AVCaptureTorchModeOn]) {
                [[self frontFacingCamera] setTorchMode:AVCaptureTorchModeOn & on];
            }
            [[self frontFacingCamera] unlockForConfiguration];
        }
    }
}

- (void)saveVideoToAlbums:(NSString *)path withBlock:(void(^)(BOOL result))block
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (block) {
                                            block(error == nil);
                                        }
                                    });
                                }];
    [library release], library = nil;
}

+ (CGFloat)secondsOfVideoOfPath:(NSString *)path
{
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    [avAsset release];
    return duration;
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:avAsset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[[UIImage alloc]initWithCGImage:thumbnailImageRef] autorelease] : nil;
    
    [assetImageGenerator release];
    
    [avAsset release];
    
    if(thumbnailImageRef)
        CFRelease(thumbnailImageRef);
    
    return thumbnailImage;
}

- (BOOL)switchCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        } else {
            return success;
        }
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self videoDataOutput] connections]];
            if ([videoConnection isVideoOrientationSupported])
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            [[self session] commitConfiguration];
            success = YES;
            [newVideoInput release];
        } else if (error) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
    return success;
}

#pragma mark
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);

    CFRetain(sampleBuffer);
	CFRetain(formatDescription);
	dispatch_async(movieWritingQueue, ^{
        
		if (_assetWriter) {
            
			BOOL wasReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!readyToRecordVideo)
					readyToRecordVideo = [self setupAssetWriterVideoInput:formatDescription];
				
				// Write video data to file
				if (readyToRecordVideo && readyToRecordAudio)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                _currentFrame++;
			}
			else if (connection == audioConnection) {
				
				// Initialize the audio input if this is not done yet
				if (!readyToRecordAudio)
					readyToRecordAudio = [self setupAssetWriterAudioInput:formatDescription];
				
				// Write audio data to file
				if (readyToRecordAudio && readyToRecordVideo)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
			if ( !wasReadyToRecord && isReadyToRecord ) {
				recordingWillBeStarted = NO;
                _recording = YES;
				[self.delegate recordingDidStart];
			}
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat p = (CGFloat)((CGFloat)self.currentFrame / (CGFloat)self.maxFrame);
                if (self.started) {
                    [self.delegate captureManager:self captureProgress:p];
                }
            });
            
            if (self.currentFrame >= self.maxFrame) {
                [self performSelectorOnMainThread:@selector(stopRecording) withObject:NO waitUntilDone:YES];
            }
		}
		CFRelease(sampleBuffer);
		CFRelease(formatDescription);
	});
    
}

#pragma mark
#pragma mark private

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

- (void)setupVideoPreviewLayer:(UIView *)view
{
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    CALayer *viewLayer = [view layer];
    newCaptureVideoPreviewLayer.borderWidth = 2.f;
    newCaptureVideoPreviewLayer.borderColor = [UIColor blackColor].CGColor;
    
    CGRect bounds = [view bounds];
    [newCaptureVideoPreviewLayer setFrame:bounds];
    
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    
    [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
    [newCaptureVideoPreviewLayer release];
}


- (void)changeVideoToMPEG4:(NSURL *)fileURL
{
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *outputPath = self.outputFileURL;
    [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:avAsset  presetName:AVAssetExportPresetPassthrough];
    export.shouldOptimizeForNetworkUse = YES;
    export.outputFileType = AVFileTypeMPEG4;
    export.outputURL = [NSURL fileURLWithPath:outputPath];
    [export exportAsynchronouslyWithCompletionHandler:^(void){
        switch ([export status]) {
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusCancelled:
            {
                NSError *error = export.error;
                
                if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                    [[self delegate] captureManager:self didFailWithError:error];
                }
            }
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self delegate] captureManagerRecordingFinished:self];
                    });
                }
            }
                break;
            default:
                break;
        }
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        
    }];
}

#pragma mark Device Counts
- (NSUInteger)cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger)micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}


// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		_orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		_orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		_orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		_orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

- (void)setAudioDeviceInput
{
    [self.session beginConfiguration];
    /*
	 * Create audio connection
	 */
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([_session canAddInput:audioIn])
        [_session addInput:audioIn];
    _audioInput = [audioIn retain];
	[audioIn release];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", NULL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([_session canAddOutput:audioOut])
		[_session addOutput:audioOut];
    _audioDataOutput = [audioOut retain];
    audioConnection = [self connectionWithMediaType:AVMediaTypeAudio fromConnections:[[self audioDataOutput] connections]];
	[audioOut release];
    [self.session commitConfiguration];
}

- (void) dealloc
{
    [_session removeInput:_videoInput];
    [_session removeInput:_audioInput];
    [_session removeOutput:_videoDataOutput];
    [_session removeOutput:_audioDataOutput];
    [_session release];
    [_videoInput release];
    [_audioInput release];
    [_captureVideoPreviewLayer release];
    [_videoDataOutput release];
    [_audioDataOutput release];
    [_outputFileURL release];
    [super dealloc];
}


@end
