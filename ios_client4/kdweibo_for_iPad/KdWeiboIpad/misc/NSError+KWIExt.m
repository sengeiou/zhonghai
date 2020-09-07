//
//  NSError+KWIExt.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "NSError+KWIExt.h"

#import "iToast.h"
#import "SBJson.h"

@implementation NSError (KWIExt)

- (void)KWIGeneralProcess
{
    //NSLog(@"%@", self);
    
    /*NSError *underlying = [self.userInfo objectForKey:NSUnderlyingErrorKey];
    
    if (nil != underlying) {        
        [underlying KWIGeneralProcess];
        return;
    }*/
    
    NSString *msg = @"噢，貌似出错了，稍后再试试";
    NSDictionary *raw_resp = nil;
    if (self.userInfo && [[self.userInfo objectForKey:@"raw_resp"] isKindOfClass:NSString.class]) {
        raw_resp = [[self.userInfo objectForKey:@"raw_resp"] JSONValue];
    }
    
    [self.userInfo objectForKey:@"raw_resp"];
    
    if ([@"ASIHTTPRequestErrorDomain" isEqualToString:self.domain]) {
        switch (self.code) {
            case 1:
                msg = @"连不上服务器，无网络连接";
                break;
                
            case 2:
                msg = @"连不上服务器，可能是网速太慢或无网络连接";                
                break;
                
            default:
                break;
        }
    } else if ([@"ResponseWithError" isEqualToString:self.domain]) {
        switch (self.code) {
            case 500:
                msg = [raw_resp objectForKey:@"message"];
                if (!(msg && [msg isKindOfClass:NSString.class] && msg.length)) {
                    msg = @"噢，貌似出错了，稍后再试试";
                }
                
                break;
                
            default:
                break;
        }
    }
    
    [[iToast makeText:msg] show];
}

@end
