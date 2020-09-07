//
//  T9Utils.h
//  ContactsLite
//
//  Created by Gil on 13-1-24.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9Utils : NSObject

+(int)getMatchWord:(NSArray *)match;
+(NSString *)toFirstUpper:(NSString *)s;
+(int)getCharMaxLen;
+(int)getIndex:(char)ch;
+(BOOL)isWanted:(unichar)character;
+(NSString *)getChars:(char)ch;
+(NSArray *)getPinYins:(NSString *)fullPinyins;

@end
