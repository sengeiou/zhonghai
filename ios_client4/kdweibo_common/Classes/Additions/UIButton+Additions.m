//
//  UIButton+Additions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (KD_Utility)

- (void)addImageWithName:(NSString *)imageName forState:(UIControlState)state isBackground:(BOOL)isBackground {
	UIImage *image = [UIImage imageNamed:imageName];
	if(isBackground){
		image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
		[self setBackgroundImage:image forState:state];
		
	}else {
		[self setImage:image forState:state];	
	}
}

@end
