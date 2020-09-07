//
//  KDBasicAuthorization.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "KDBasicAuthorization.h"
#import "GTMBase64.h"

@interface KDBasicAuthorization ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, retain) NSString *basic;

@end


@implementation KDBasicAuthorization

@synthesize identifier=identifier_;
@synthesize password=password_;
@synthesize basic=basic_;

- (id) init {
    self = [super init];
    if(self){
        identifier_ = nil;
        password_ = nil;
        basic_ = nil;
    }
    
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier password:(NSString *)password {
    self = [self init];
    if(self){
        identifier_ = [identifier copy];
        password_ = [password copy];
        
        self.basic = [self encodeBasicAuthenticationString];
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAuthorization protocol methods

- (KDAuthorizationType)getAuthorizationType {
    return KDAuthorizationTypeBasic;
}

- (NSString *)getAuthorizationHeader:(KDRequestWrapper *)req {
    return basic_;
}

- (BOOL)isEnabled {
    return YES;
}

- (NSUInteger)hash {
    return [basic_ hash];
}

- (NSString *)encodeBasicAuthenticationString {
    if(identifier_ != nil && password_ != nil){
        NSString *combination = [NSString stringWithFormat:@"%@:%@", identifier_, password_];
        NSData *data = [combination dataUsingEncoding:NSUTF8StringEncoding];
        data = [GTMBase64 encodeData:data];
        
        NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return [NSString stringWithFormat:@"Basic %@", str];
    }
    
    return nil;
}

- (BOOL)isEqual:(id)object {
    if(self == object) return YES;
    if(![object isKindOfClass:[KDBasicAuthorization class]]) return NO;
    
    KDBasicAuthorization * that = (KDBasicAuthorization *)object;
    return [that.basic isEqualToString:self.basic];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"KDBasicAuthorization{identifier='%@', password='%@'}", identifier_, password_];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(identifier_);
    //KD_RELEASE_SAFELY(password_);
    //KD_RELEASE_SAFELY(basic_);
    
//    [super dealloc];
}

@end
