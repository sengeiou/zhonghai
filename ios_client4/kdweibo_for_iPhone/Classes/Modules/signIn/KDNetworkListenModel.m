//
//  KDNetworkListenModel.m
//  kdweibo
//
//  Created by lichao_liu on 15/4/24.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDNetworkListenModel.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>
//Snip, you know we're in the implementation...
@implementation KDNetworkListenModel

#pragma mark - 是否存在网络

+ (BOOL) isNetworkReachable{
    
    // Create zero addy
    
    struct sockaddr_in zeroAddress;
    
    bzero (&zeroAddress, sizeof (zeroAddress));
    
    zeroAddress. sin_len = sizeof (zeroAddress);
    
    zeroAddress. sin_family = AF_INET ;
    
    // Recover reachability flags
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress ( NULL , ( struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags (defaultRouteReachability, &flags);
    
    CFRelease (defaultRouteReachability);
    
    if (!didRetrieveFlags)
        
    {
        
        return NO ;
        
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable ;
    
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired ;
    
    return (isReachable && !needsConnection) ? YES : NO ;
    
}

@end