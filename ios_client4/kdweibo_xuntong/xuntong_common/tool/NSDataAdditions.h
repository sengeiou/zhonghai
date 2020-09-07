//	
//  NSDataAdditions.h
//
//  Created by Gil on 3/2/11.
//  Edited by Gil on 2012.09.11
//  Copyright 1993-2011 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MBBase64)

/*
 @desc NSString to Base64 NSData;
 Padding '=' characters are optional. Whitespace is ignored.
 */
+(NSData *)base64DataFromString:(NSString *)string;  

/*
 @desc Base64 NSData to NSString;
 */
-(NSString *)base64Encoding;

@end
