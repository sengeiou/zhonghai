//
//  NSString+URL.m
//  digu_Iphone
//
//  Created by Jiang Jinke on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString(URL)

- (NSString *)stringByEncodingUrl;
{
  NSString * encodedString = 
  (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                      (CFStringRef)self, 
                                                      NULL,
                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                      kCFStringEncodingUTF8 );
  return encodedString;//[encodedString retain];
}

- (NSString*)URLDecodedString {
    NSString *result =(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                  (CFStringRef)self,
                                                                         CFSTR(""),
                                                                         kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
@end
