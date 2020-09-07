//
//  SpeakProgressBar.m
//  ContactsLite
//
//  Created by kingdee eas on 13-3-4.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "XTRecorderProgressView.h"

@implementation XTRecorderProgressView


-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
        
		self.progressInnerView = [[UIView alloc] initWithFrame:CGRectMake(1.0, 1.0, 0.0, frame.size.height- 2.0)];
		self.progressInnerView.layer.cornerRadius = 1;
		self.progressInnerView.layer.borderColor = [UIColor clearColor].CGColor;
		self.progressInnerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        [self addSubview:self.progressInnerView];
        
		self.progressOutterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		self.progressOutterView.backgroundColor = [UIColor clearColor];
		self.progressOutterView.layer.cornerRadius = 1;
		self.progressOutterView.layer.borderWidth = 1.0;
		self.progressOutterView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.6].CGColor;
		[self addSubview:self.progressOutterView];
	}
	return self;
}

-(void)setProgress:(int)progress
{
	self.progressInnerView.frame = CGRectMake(1.0, 1.0, progress/60.0 * (self.frame.size.width - 2.0), self.frame.size.height - 2.0);
}

@end