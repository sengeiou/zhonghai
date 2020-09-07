//
//  BOSLogger.m
//  Workflow
//
//  Created by 锦维 徐 on 11-12-28.
//  Edited by Gil on 12-04-28
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2011年 Kingdee. All rights reserved.
//

#import "BOSLogger.h"

@interface BOSLogger (Private)
- (id)initWithLogLevel:(BOSLogLevel)levelSetting;
+ (NSString *)levelName:(BOSLogLevel)level;
- (void)log:(NSString *)msg withLevel:(BOSLogLevel)level inFile:(NSString *)fileName inLine:(int)lineNr;
- (void)changeLogpath;
@end

@implementation BOSLogger
@synthesize logLevel;
@synthesize bufferString;
@synthesize logPath;
@synthesize mylock;

static BOSLogger *logger = nil;

#pragma mark Class Method
+ (BOSLogger *)sharedLogger
{
	@synchronized(self)
	{
        if (logger == nil)
        {
            logger = [[BOSLogger alloc] init];
        }
    }
	return logger;
}

+(NSString *)levelName:(BOSLogLevel)level
{
	switch (level) {
		case BOS_INFO:    
            return @"INFO";
            break;
		case BOS_DEBUG:   
            return @"DEBUG";
            break;
		case BOS_WARN:    
            return @"WARN";
            break;
		case BOS_ERROR:   
            return @"ERROR";
            break;
		case BOS_FATAL:   
            return @"FATAL";
            break;
		default: 
            return @"NOLEVEL"; 
            break;
	}
}
#pragma mark -
#pragma mark Method init

- (id)init
{
	return [self initWithLogLevel:BOS_DEBUG];
}

- (id)initWithLogLevel:(BOSLogLevel)levelSetting
{
    self = [super init];
	if (self)
    {
		self.logLevel = levelSetting;
        mylock = [[NSLock alloc]init];
        NSDate *date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
        NSString *timeDate = [formatter stringFromDate:date];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString * tempsavefile= [documentDirectory stringByAppendingString:
                                  [NSString stringWithFormat:@"/Log_%@.txt",timeDate]];
        if (WRITETOFILE) {
            NSString *defaultText = @"****Log Begin****!\n";
            [defaultText writeToFile:tempsavefile atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        self.logPath = tempsavefile;
        self.bufferString = [NSMutableString stringWithCapacity:10];
//        [formatter release];
    }
	return self;
}

#pragma mark -
#pragma mark Method
- (void)changeLogpath{
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *timeDate = [formatter stringFromDate:date];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString * tempsavefile= [documentDirectory stringByAppendingString:
                              [NSString stringWithFormat:@"/Log_%@.txt",timeDate]];
    
    if (WRITETOFILE) {
        NSString *defaultText = @"****Log Begin****!\n";
        [defaultText writeToFile:tempsavefile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    self.logPath = tempsavefile;
    [bufferString setString:@""];
//    [formatter release];
    
}
- (void)log:(NSString *)msg withLevel:(BOSLogLevel)level inFile:(NSString *)fileName inLine:(int)lineNr
{
    [mylock lock];
	if (level >= logLevel)
    {
        printf("\nBOS:[%sL:%d-][%s]%s\n", [fileName cStringUsingEncoding:NSUTF8StringEncoding],lineNr,[[BOSLogger levelName:level] cStringUsingEncoding:NSUTF8StringEncoding],[msg cStringUsingEncoding:NSUTF8StringEncoding]);
        if (WRITETOFILE) 
        {
            NSDate *date = [NSDate date];
            NSDateFormatter* formatter =[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timeDate = [formatter stringFromDate:date];
            
            NSString *localString = [NSString stringWithFormat:@"\n%@[%@L:%d-]\n[%@]%@",timeDate,fileName, lineNr,
                                     [BOSLogger levelName:level], msg];
            char cLogWrite[10240];
            char *cLogPath = (char *)[logPath UTF8String];
            [localString getCString:cLogWrite maxLength:10240 encoding:NSUTF8StringEncoding];   
            
            m_fp = fopen(cLogPath, "a+");
            fwrite(cLogWrite, strlen(cLogWrite), 1, m_fp);
            fclose(m_fp);
//            [formatter release];
        }
    }
    [mylock unlock];
}

- (void)info:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:BOS_INFO inFile:fileName inLine:lineNr];
}

- (void)debug:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:BOS_DEBUG inFile:fileName inLine:lineNr];	
}

- (void)warn:(NSString *)msg 
	  inFile:(NSString *)fileName 
	  inLine:(int)lineNr
{
	[self log:msg withLevel:BOS_WARN inFile:fileName inLine:lineNr];	
}

- (void)error:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:BOS_ERROR inFile:fileName inLine:lineNr];
}

- (void)fatal:(NSString *)msg 
	   inFile:(NSString *)fileName 
	   inLine:(int)lineNr
{
	[self log:msg withLevel:BOS_FATAL inFile:fileName inLine:lineNr];
}

@end
