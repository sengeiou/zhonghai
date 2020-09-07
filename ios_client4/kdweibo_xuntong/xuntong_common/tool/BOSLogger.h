//
//  BOSLogger.h
//  Workflow
//
//  Created by 锦维 徐 on 11-12-28.
//  Edited by Gil on 12-04-28
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2011年 Kingdee. All rights reserved.
//


#import <Foundation/Foundation.h>

/*
 日志打印方法：BOSINFO、BOSDEBUG、BOSWARN、BOSERROR、BOSFATAL
 在DEBUG模式下（需在Preprocesser Macros中定义Debug）将会打印日志到控制台
 */
#ifdef DEBUG
//是否将打印的日志写入到文件并放到Documents文件夹下。1为写 0为不写
#define WRITETOFILE 1
#define BOSINFO(format, ...) [[BOSLogger sharedLogger] info:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[NSString stringWithUTF8String:__FUNCTION__] \
inLine:__LINE__]
#define BOSDEBUG(format, ...) [[BOSLogger sharedLogger] debug:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[NSString stringWithUTF8String:__FUNCTION__] \
inLine:__LINE__]
#define BOSWARN(format, ...) [[BOSLogger sharedLogger] warn:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[NSString stringWithUTF8String:__FUNCTION__] \
inLine:__LINE__]
#define BOSERROR(format, ...) [[BOSLogger sharedLogger] error:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[NSString stringWithUTF8String:__FUNCTION__] \
inLine:__LINE__]
#define BOSFATAL(format, ...) [[BOSLogger sharedLogger] fatal:[NSString stringWithFormat:(format), ##__VA_ARGS__] \
inFile:[NSString stringWithUTF8String:__FUNCTION__] \
inLine:__LINE__]
#else
//是否将打印的日志写入到文件并放到Documents文件夹下。1为写 0为不写
#define WRITETOFILE 0
#define BOSINFO(format, ...) 
#define BOSDEBUG(format, ...) 
#define BOSWARN(format, ...) 
#define BOSERROR(format, ...)
#define BOSFATAL(format, ...)
#endif


//日志打印等级
typedef enum _BOSLogLevel{
    BOS_DEBUG   = 40,
	BOS_INFO    = 50,
	BOS_WARN = 60,
	BOS_ERROR   = 70,
	BOS_FATAL   = 80,
    BOS_NONE = 1000
}BOSLogLevel;

@interface BOSLogger : NSObject {
	BOSLogLevel logLevel;
    NSMutableString *bufferString;
    NSString *logPath;
    NSLock *mylock;
    FILE * m_fp;
}

@property (nonatomic, assign) BOSLogLevel logLevel;
@property (nonatomic, retain) NSMutableString *bufferString;
@property (nonatomic, retain) NSString *logPath;
@property (nonatomic, retain) NSLock *mylock;

+ (BOSLogger *)sharedLogger;

- (void)debug:(NSString *)msg inFile:(NSString *)fileName inLine:(int)lineNr;
- (void)info:(NSString *)msg inFile:(NSString *)fileName inLine:(int)lineNr;
- (void)warn:(NSString *)msg inFile:(NSString *)fileName inLine:(int)lineNr;
- (void)error:(NSString *)msg inFile:(NSString *)fileName inLine:(int)lineNr;
- (void)fatal:(NSString *)msg inFile:(NSString *)fileName inLine:(int)lineNr;



@end

