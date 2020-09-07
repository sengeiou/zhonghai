//
//  KWOAuthToken.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KWOAuthToken.h"

@implementation KWOAuthToken

@synthesize key = _key, secret = _secret;

+ (KWOAuthToken *)tokenWithKey:(NSString *)key secret:(NSString *)secret
{
    return [[[KWOAuthToken alloc] initWithKey:key secret:secret] autorelease];
}

- (KWOAuthToken *)initWithKey:(NSString *)key secret:(NSString *)secret
{
    //_key = [[key retain] autorelease];
    //_secret = [[secret retain] autorelease];
    
    [self setKey:key];
    [self setSecret:secret];
    
    return self;
}

- (void)dealloc
{
    [_key release];
    [_secret release];
    [super dealloc];
}

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{
    return [[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", [self key], [self secret]] dataUsingEncoding:encoding];
}

+ (KWOAuthToken *)tokenFromQuerystring:(NSString *)query
{
    if ((nil == query) || ([@"" isEqualToString:query])) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    NSArray *params = [query componentsSeparatedByString:@"&"];
    for (NSString *param in params) {
        NSArray *kv = [param componentsSeparatedByString:@"="];
        if (nil == kv || 2 != [kv count]) {
            continue;
        }
        NSString *k = [kv objectAtIndex:0];
        NSString *v = [kv lastObject];
        [dict setObject:v forKey:k];
    }
    
    NSString *key = [dict valueForKey:@"oauth_token"];
    NSString *secret = [dict valueForKey:@"oauth_token_secret"];
    
    if ((nil != key) && (nil != secret)) {
        
        return [self tokenWithKey:key secret:secret];
        
    } else {
        NSException *err = [NSException exceptionWithName:@"InvalidOAuthTokenException" 
                                                   reason:[NSString stringWithFormat:@"got invalid OAuth token string: %@", query] 
                                                 userInfo:nil];
        @throw err;
    }
}

- (BOOL)isValid
{
    return TRUE;
}

- (void)validOrException
{
    if (![self isValid]) {
        // TODO: renew, throw exception if failed
    }
}

@end
