//
//  KDMessageUploadTaskHelper.m
//  kdweibo
//
//  Created by Tan yingqi on 13-6-7.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTaskHelper.h"
#import "KDMessageUploadTask.h"
@interface KDUploadTaskHelper ()
@property(nonatomic,retain)NSMutableDictionary *taskPool;
@end

@implementation KDUploadTaskHelper
@synthesize taskPool = taskPool_;

-(id)init {
    self = [super init];
    if (self) {
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinished:) name:@"TaskFinished" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(enteredBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];

    }
    return self;
}

- (BOOL)isTaskOnRunning:(NSString *)theId {
     KDUploadTask *theTask = [self.taskPool objectForKey:theId];
     return (theTask && ([theTask isStarted] ||[theTask isUploading]));
}

- (id)entityById:(NSString *)theId {
    id returnObj = nil;
    KDUploadTask *theTask = [self.taskPool objectForKey:theId];
    if (theTask) {
        returnObj = [theTask entity];
    }
    return returnObj;
}

- (void)handleTask:(KDUploadTask *)task entityId:(NSString *)theId{
    if (theId == nil || [theId isEqualToString:@"-1"]) {
        return;
    }
    KDUploadTask *theTask = [self.taskPool objectForKey:theId];
    if (theTask == nil) {
        [self.taskPool setObject:task forKey:theId];
        [task startTask];
    }
}

- (void)taskFinished:(NSNotification *)noti {
    KDUploadTask *task = [[noti userInfo] objectForKey:@"task"];
    id obj = task.entity;
    NSString *id_ = [obj performSelector:@selector(id_)];
    if (id_) {
        DLog(@"taskPool remove Object....");
         [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskHasRemoved" object:self userInfo:@{@"task":task}];
         [self.taskPool removeObjectForKey:id_];
    }
}

- (NSMutableDictionary *)taskPool {
    if (taskPool_ == nil) {
        taskPool_ = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return taskPool_;
}

+ (KDUploadTaskHelper *)shareUploadTaskHelper {
    static KDUploadTaskHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[KDUploadTaskHelper alloc] init];
    });
    
    return helper;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //KD_RELEASE_SAFELY(taskPool_);
    //[super dealloc];
}

- (void)enteredBackground:(NSNotification *)notification { //程序进入后台失败处理
    for (KDUploadTask *task in [self.taskPool allValues]) {
        [task  startCanceling];
    }
}

@end
