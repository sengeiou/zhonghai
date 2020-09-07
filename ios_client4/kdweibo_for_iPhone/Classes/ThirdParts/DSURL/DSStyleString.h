//
//  DSStyleString.h
//  urltextview
//
//  Created by duansong on 10-10-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum 
{
    URL     =0x0000,
    TOPIC   =0x0001,
    USER    =0x0002,
    NEW_LINE =0x0003
}DSStyle;

@interface DSStyleString : NSObject {
	NSString		*_string;
	BOOL			_isUrl;
    DSStyle         _style;
    NSString *       _url;
}

@property (nonatomic, copy)		NSString	*string;
@property (nonatomic, assign)	BOOL		isUrl;
@property (nonatomic, assign) DSStyle       style;
@property (nonatomic, retain) NSString *    url;

@end
