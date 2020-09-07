//
//  NSString+URL.h
//  digu_Iphone
//
//  Created by Jiang Jinke on 5/13/11.
//  Copyright 2011 Digu.com Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

// Dependant upon GTMNSString+HTML

@interface NSString (URL)

// Instance Methods
//- (NSString *)stringByDecodingUrl;
- (NSString *)stringByEncodingUrl;
- (NSString*) URLDecodedString;
@end

