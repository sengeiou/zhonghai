//
//  KDTileViewCell.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTileViewCell.h"

@implementation KDTileViewCell

@synthesize identifier=identifier_;

@synthesize contentView=contentView_;
@synthesize userInfo = _userInfo;
- (id) initWithIdentifier:(NSString *)identifier {
	if(self = [super initWithFrame:CGRectZero]){
		identifier_ = [identifier copy];
		
		contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:contentView_];
	}
	
	return self;
}
- (void) layoutSubviews {
	[super layoutSubviews];
	
	CGRect rect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	contentView_.frame = rect;
}

- (void) prepareForReuse {
}

- (void) shouldCacheCell {
	
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(identifier_);
    //KD_RELEASE_SAFELY(contentView_);
	
    //[super dealloc];
}


@end

