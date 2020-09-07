//
//  DSStyleString.m
//  urltextview
//
//  Created by duansong on 10-10-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSStyleString.h"


@implementation DSStyleString

@synthesize isUrl	= _isUrl;
@synthesize string	= _string;
@synthesize style=_style;
@synthesize url=_url;

- (void)dealloc {
//	[_string	release];
	_string		= nil;
    self.url=nil;
	//[super dealloc];
    
}

@end
