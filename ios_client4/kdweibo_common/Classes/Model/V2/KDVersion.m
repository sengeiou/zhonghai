//
//  KDVersion.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-13.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDVersion.h"

@interface KDVersion ()

@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;
@property (nonatomic, assign) NSInteger micro;

@property (nonatomic, assign) KDReleaseStatus releaseStatus;
@property (nonatomic, copy) NSString *dateString;

@property (nonatomic, copy) NSString *versionString;

@end


@implementation KDVersion

@synthesize major=major_;
@synthesize minor=minor_;
@synthesize micro=micro_;

@synthesize releaseStatus=releaseStatus_;
@synthesize dateString=dateString_;

@synthesize versionString=versionString_;

/////////////////////////////////////////////////

- (NSString *) releaseStatusToString {
    NSString *releaseString = nil;
    if(Alpha == releaseStatus_){
        releaseString = @"Alpha";
        
    }else if(Beta == releaseStatus_){
        releaseString = @"Beta";
        
    }else if(Release == releaseStatus_){
        releaseString = @"";
        
    }else if(ReleaseCondidate == releaseStatus_){
        releaseString = @"RC";
    }
    
    return releaseString;
}

- (KDReleaseStatus) convertVersionPhase:(NSString *)versionPhase {
    if(versionPhase == nil){
        return -1;
    }
    
    KDReleaseStatus status = -1;
    
    NSString *lowercasePhase = [versionPhase lowercaseString];
    if([lowercasePhase hasPrefix:@"alpha"]){
        status = Alpha;
        
    }else if([lowercasePhase hasPrefix:@"beta"]){
        status = Beta;
        
    }else if([lowercasePhase hasPrefix:@"rc"] || [lowercasePhase hasPrefix:@"release_condidate"]){
        status = ReleaseCondidate;
    }else if([lowercasePhase hasPrefix:@"release"])
        status = Release;
    
    return status;
}

- (BOOL)validateStringIsNumeric:(NSString *)str
{
    if(!str || [str length] <= 0)
        return NO;
    for(int i = 0; i < str.length; i++){
        char c = [str characterAtIndex:i];
        if(!(c >= 48 && c <= 57))
            return NO;
    }
    
    return YES;
}

///改动原因：
//    由于版本号命名规则的改动（具体改动见KSSP－7999），改动该解析算法。
- (void) parseVersionString {
    /*
    if(versionString_ != nil && [versionString_ length] > 0){
        NSRange range = [versionString_ rangeOfString:@"_"];
        NSString *prefix = (range.location == NSNotFound) ? versionString_ : [versionString_ substringToIndex:range.location];
        NSArray *componets = [prefix componentsSeparatedByString:@"."];
        if(componets != nil){
            NSInteger count = [componets count];
            if(count > 0x00){
                major_ = [[componets objectAtIndex:0x00] integerValue];
            }
            
            if(count > 0x01){
                minor_ = [[componets objectAtIndex:0x01] integerValue];
            }
            
            if(count > 0x02){
                micro_ = [[componets objectAtIndex:0x02] integerValue];
            }
        }
        
        if(range.location != NSNotFound && (range.location + 1 < [versionString_ length])){
            NSString *suffix = [versionString_ substringFromIndex:range.location + 1];
            // format like: beta_0415
            componets = [suffix componentsSeparatedByString:@"_"];
            if(componets != nil){
                NSInteger count = [componets count];
                if(count > 0x00){
                    NSString *versionPhase = [componets objectAtIndex:0x00];
                    releaseStatus_ = [self convertVersionPhase:versionPhase];
                }
                
                if(count > 0x01){
                    self.dateString = [componets objectAtIndex:0x01];
                }
            }
        }else {
            // if not a suffix start with '_', than we think this version phase is release
            releaseStatus_ = Release;
        }
    }
     */
    if(versionString_ != nil && [versionString_ length] > 0){
        NSArray *components = [versionString_ componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"._" ]];
        if(components){
            NSInteger length = [components count];
            if(length > 0){
                major_ = [self validateStringIsNumeric:[components objectAtIndex:0]] ? [[components objectAtIndex:0] integerValue] : 0;
            }
            
            if(length > 1){
                minor_ = [self validateStringIsNumeric:[components objectAtIndex:1]] ? [[components objectAtIndex:1] integerValue] : 0;
            }
            
            if(length > 2){
                micro_ = [self validateStringIsNumeric:[components objectAtIndex:2]] ? [[components objectAtIndex:2] integerValue] : 0;
            }
            
            if(length > 3){
                if(6 == length){
                    releaseStatus_ = [self convertVersionPhase:[NSString stringWithFormat:@"%@_%@",[components objectAtIndex:3],[components objectAtIndex:4]]];
                    self.dateString = [components objectAtIndex:5];
                }
                else if(5 == length){
                    NSString *lastString = [components lastObject];
                    if([self validateStringIsNumeric:lastString]){
                        self.dateString = lastString;
                        releaseStatus_ = [self convertVersionPhase:(NSString *)[components objectAtIndex:3]];
                    }
                    else {
                        releaseStatus_ = [self convertVersionPhase:[NSString stringWithFormat:@"%@_%@",[components objectAtIndex:3],[components objectAtIndex:4]]];
                    }
                }
                else {
                    if([self validateStringIsNumeric:[components lastObject]]){
                        self.dateString = [components lastObject];
                        releaseStatus_ = Release;
                    }
                    else {
                        releaseStatus_ = [self convertVersionPhase:(NSString *)[components lastObject]];
                    }
                }
            }
            else{
                releaseStatus_ = Release;
            }
        }
    }
}

- (void) buildVersionString {
    NSString *version = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)major_, (long)minor_, (long)micro_];
    NSString *releaseString = [self releaseStatusToString];
    if(releaseString != nil){
        version = [version stringByAppendingFormat:@".%@", releaseString];
    }
    
    if(dateString_ != nil){
        version = [version stringByAppendingFormat:@"_%@", dateString_];
    }
    
//    if(versionString_ != nil){
//        [versionString_ release];
//    }
    versionString_ = [version copy];
}

- (id) init {
    self = [super init];
    if(self){
        major_ = 0;
        minor_ = 0;
        micro_ = 0;
        
        releaseStatus_ = 0;
        dateString_ = 0;
        
        versionString_ = nil;
    }
    
    return self;
}

- (id) initWithMajor:(NSInteger)major minor:(NSInteger)minor micro:(NSInteger)micro 
       releaseStatus:(KDReleaseStatus)releaseStatus dateString:(NSString *)dateString {
    self = [super init];
    if(self){
        major_ = major;
        minor_ = minor;
        micro_ = micro;
        
        releaseStatus_ = releaseStatus;
        dateString_ = [dateString copy];
        
        [self buildVersionString];
    }
    
    return self;
} 

- (id) initWithVersionString:(NSString *)versionString {
    self = [self init];
    if(self){
        versionString_ = [versionString copy];
        [self parseVersionString];
    }
    
    return self;
}

- (NSComparisonResult) compare:(KDVersion *)version {
    if(major_ == version.major && minor_ == version.minor
       && micro_ == version.micro){
        
        // Because we use the format like: 1.1.1_beta_0427 for development. 
        // But when we release new version as public and the versin string is 1.1.1 
        // And some guys need make 1.1.1 (release) greater than 1.1.1_beta_0427 (beta)
        // so add some logic to compare version phase
        
        int diff = releaseStatus_ - version.releaseStatus;
        if(diff > 0){
            return NSOrderedDescending;
            
        }else if(diff < 0){
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }
    
    if(major_ > version.major){
        return NSOrderedDescending;
    }
    
    if(minor_ > version.minor && major_ == version.major){
        return NSOrderedDescending;
    }
    
    if(micro_ > version.micro && major_ == version.major && minor_ == version.minor){
        return NSOrderedDescending;
    }
    
    return NSOrderedAscending;
}

+ (BOOL)quickCompareVersionA:(NSString *)versionStringA versionB:(NSString *)versionStringB results:(NSComparisonResult *)results inRange:(NSRange)range {
    BOOL flag = NO;
    
    if(!KD_IS_BLANK_STR(versionStringA) && !KD_IS_BLANK_STR(versionStringB)) {
        NSMutableArray *componentsA = [NSMutableArray arrayWithArray:[versionStringA componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]]];
        NSMutableArray *componentsB = [NSMutableArray arrayWithArray:[versionStringB componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]]];
        
        NSUInteger beginIndex = range.location;
        NSUInteger endIndex = range.location + range.length;
        
        NSUInteger count = MIN(componentsA.count, componentsB.count);
        
        for(NSUInteger index = 0; index < count; index++) {
            NSString *a = componentsA[index];
            
            if(index < beginIndex || index >= endIndex) {
                [componentsB replaceObjectAtIndex:index withObject:a];
            }
        }
        
        while (componentsA.count < componentsB.count) {
            [componentsB removeObjectAtIndex:componentsA.count];
        }
        
        KDVersion *va = [[KDVersion alloc] initWithVersionString:[componentsA componentsJoinedByString:@"."]];
        KDVersion *vb = [[KDVersion alloc] initWithVersionString:[componentsB componentsJoinedByString:@"."]];
        
        NSComparisonResult value = [va compare:vb];
        if(results != NULL) {
            *results = value;
        }
        
//        [va release];
//        [vb release];
        
        flag = YES;
        
    }
    
    return flag;
}

+ (BOOL) quickCompareVersionA:(NSString *)versionStringA versionB:(NSString *)versionStringB results:(NSComparisonResult *)results {
    BOOL flag = NO;
    if(!KD_IS_BLANK_STR(versionStringA) && !KD_IS_BLANK_STR(versionStringB)){
        KDVersion *va = [[KDVersion alloc] initWithVersionString:versionStringA];
        KDVersion *vb = [[KDVersion alloc] initWithVersionString:versionStringB];
        
        NSComparisonResult value = [va compare:vb];
        if(results != NULL){
            *results = value;
        }
        
//        [va release];
//        [vb release];
        
        flag = YES;
    }
    
    return flag;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(versionString_);
    //KD_RELEASE_SAFELY(dateString_);
    
    //[super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"major:%ld,minor:%ld,micro:%ld,releaseStatus:%@,dataString:%@",(long)major_,(long)minor_,(long)micro_,[self releaseStatusToString],dateString_];
}

@end

