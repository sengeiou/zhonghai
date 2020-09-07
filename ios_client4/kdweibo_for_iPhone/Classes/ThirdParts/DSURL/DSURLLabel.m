//
//  DSURLLabel.m
//  urltextview
//
//  Created by duansong on 10-10-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSURLLabel.h"


@implementation DSURLLabel

@synthesize urlString	= _urlString;
@synthesize urlLabel	= _urlLabel;
@synthesize delegate	= _delegate;
@synthesize style=_style;

#pragma mark -
#pragma mark init method




- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];//autorelease];
		_urlLabel.backgroundColor = [UIColor clearColor];
		_urlLabel.textColor = RGBCOLOR(26, 133, 255);
		[self addSubview:_urlLabel];
		
        _style=URL;
    }
    return self;
}


#pragma mark -
#pragma mark touch event method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(urlTouchesBegan:)]) {
		[_delegate urlTouchesBegan:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(urlTouchesEnd:)]) {
		[_delegate urlTouchesEnd:self];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    _urlLabel.textColor = [UIColor colorWithRed:0.0 green:0x89/255.0 blue:0xbc/255.0 alpha:1.0];
    if (_delegate &&[(NSObject *)_delegate respondsToSelector:@selector(urlTouchesCancle:)]) {
        [_delegate urlTouchesCancle:self];
    }

}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate &&[(NSObject *)_delegate respondsToSelector:@selector(urlTouchesCancle:)]) {
        [_delegate urlTouchesCancle:self];
    }
//    _urlLabel.textColor = [UIColor colorWithRed:0.0 green:0x89/255.0 blue:0xbc/255.0 alpha:1.0];

}



#pragma mark -
#pragma mark dealloc memory method

- (void)dealloc 
{
//	[_urlString			release];	
	_urlString			= nil;
    //[super dealloc];
}


@end
