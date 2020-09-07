//
//  KDUploadTask.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-5-15.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDCommon.h"

@interface KDUploadTask() {
    BOOL isDependencyTaskOver_;
    NSInteger currentSubTaskIndex_;
}

@property(nonatomic,assign)KDUploadTaskState state;
@end

@implementation KDUploadTask
@synthesize subTasks = subTasks_;
@synthesize superTask = superTask_;
@synthesize state = state_;
@synthesize dependency = dependency_;
@synthesize entity = entity_;
- (id)init {
    self = [super init];
    if (self) {
        ///
        state_ = KDUploadTaskStateReady;
        currentSubTaskIndex_ = 0;
        isDependencyTaskOver_ = NO;

    }
    return self;
}


- (void)taskWillStart {
    
}

- (void)startTask {
    if([self isReady]) {
        [self taskWillStart];
         self.state = KDUploadTaskStateDidStarted;
    }
    
    if (![self startDependency]) {
         [self startSelf];
    }
}

- (void)startSubTasks {
    KDUploadTask *task = [self.subTasks objectAtIndex:currentSubTaskIndex_];
    [task startTask];
}

- (void)startSelf {
    if (self.subTasks) {
        [self startSubTasks];
    }else {
        if (self.state == KDUploadTaskStateDidStarted) {
            self.state = KDUploadTaskUploading;
            [self main];
        }
    }
}

- (BOOL)startDependency {
    BOOL started = NO;
    if (self.dependency && !isDependencyTaskOver_) {
        [self.dependency startTask];
        started = YES;
    }
    return started;
}


- (void)restart {
    if ([self isFailed] ||[self isCanceled]) {
        self.state = KDUploadTaskStateReady;
        [self startTask];
    }
}

- (void)main {
    [NSException raise:@"should overrided" format:@"should overrided"];
}
- (void)taskDidSuccess {
    self.state = KDUploadTaskStateSuccess;
//    if (self.superTask) {
//        [self.superTask determinSuperTask];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskFinished" object:nil userInfo:@{@"task": self}];
}
- (void)addSubTask:(KDUploadTask *)subTask {
    if (!subTasks_) {
        subTasks_ = [[NSMutableArray alloc] init];
    }
     [self.subTasks addObject:subTask];
     [subTask addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
     subTask.superTask = self;
}

- (BOOL)isStarted {
    return  state_ == KDUploadTaskStateDidStarted;
}

- (BOOL)isSuccess {
    return state_ == KDUploadTaskStateSuccess;
}

- (BOOL)isFailed {
    return state_ == KDUploadTaskStateFailed;
}

- (BOOL)isUploading {
    return state_ == KDUploadTaskUploading;
}

- (BOOL)isReady {
    return state_ == KDUploadTaskStateReady;
}

- (void)taskDisFailed {
    if (![self isFailed] && ![self isSuccess]) {
        self.state = KDUploadTaskStateFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskFinished" object:nil userInfo:@{@"task": self}];
    }
    
}


- (void)setDependency:(KDUploadTask *)dependency {
    
    if (dependency &&((self.subTasks &&[self.subTasks containsObject:dependency]) ||self.superTask == dependency)) {
        NSAssert(NO, @"dependency can't be one of subTasks or superTask");
        return;
    }
    if (dependency.dependency == self) { //依赖不能成环
        return;
    }
    if (dependency_ != dependency) {
//        [dependency_ release];
        [dependency_ removeObserver:self forKeyPath:@"state"];
        [dependency addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
        dependency_ = dependency;//；／／ retain];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        KDUploadTask *uploadTask = (KDUploadTask *)object;
        if (uploadTask == self.dependency) {//dependency 的状态发生改变
            if ([uploadTask isSuccess]) {
                [self dependencyDidFinished:uploadTask];
            }else if ([uploadTask isFailed]) {
                [self dependencyDidFailed:uploadTask];
            }
        }
        else if (self.subTasks &&[self.subTasks containsObject:uploadTask]) {//子task 的状态发生改变
//            if ([uploadTask isFailed] ||[uploadTask isCanceled]) { //如果有一个子task失败或者取消，父task 执行取消。
//                //
//                [self startCanceling];
//                NSInteger count= 0;
//                for (KDUploadTask *task in self.subTasks) {
//                    if ([task isFailed] ||[task isCanceled]) {
//                        count++;
//                    }
//                }
//                if (count == [self.subTasks count]) { //如果所有的子task失败或取消，父task 就失败
//                    [self taskDisFailed];
//                }
//
//            }else if([uploadTask isSuccess]) {
//                NSInteger count= 0;
//                for (KDUploadTask *task in self.subTasks) {
//                    if ([task isSuccess]) {
//                        count++;
//                    }
//                }
//                if (count == [self.subTasks count]) { //如果所有的子task成功，父task 就成功
//                    [self taskDidSuccess];
//                }
//            }
            if ([uploadTask isSuccess]) {
//                NSInteger index = [self.subTasks indexOfObject:uploadTask];
//                if ( index == [self.subTasks count] - 1) {
//                    [self taskDidSuccess]; //
//                }else {
//                    [[self.subTasks objectAtIndex:index +1] startTask];
//                }
                if (currentSubTaskIndex_ == [self.subTasks count]- 1) {
                    [self taskDidSuccess];
                }else {
                    currentSubTaskIndex_++;
                    [self startTask];
                }
            }else if([uploadTask isFailed]) {
                    [self taskDisFailed];
            }
        }
       
    }
}

- (void)startCanceling {
    if (self.dependency) {
        [self.dependency startCanceling];
    }
    if (self.subTasks) {
        for (KDUploadTask *subTask in self.subTasks) {
            [subTask startCanceling];
        }
    }else {
        if ([self isUploading] ||[self isReady] ||[self isStarted]) {
            [self cancel];
        }else {
            [self taskDidCanceled];
        }
    }
}

- (void)cancel{
 
   
}

- (BOOL)isCanceled {
    return state_ == KDUploadTaskCanceled;
}

- (void)taskDidCanceled {
    state_ = KDUploadTaskCanceled;
    [self taskDisFailed];
}

- (void)dependencyDidFinished:(KDUploadTask *)dependency {
    isDependencyTaskOver_ = YES;
    [self startTask];
}

- (void)dependencyDidFailed:(KDUploadTask *)dependency {
    [self taskDisFailed];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    if (self.superTask) {
        [self removeObserver:self.superTask forKeyPath:@"state"];
    }
    if (dependency_) {
        [dependency_ removeObserver:self forKeyPath:@"state"];
    }
    //KD_RELEASE_SAFELY(entity_);
    //KD_RELEASE_SAFELY(dependency_);
    //KD_RELEASE_SAFELY(subTasks_);
    //[super dealloc];
}


@end
