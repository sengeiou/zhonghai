//
//  KDTimelineStatusCell.m
//  kdweibo
//
//  Created by Tan yingqi on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTimelineStatusCell.h"



@implementation KDTimelineStatusCell

@dynamic status;

@synthesize statusView = statusView_;
@synthesize avatarView = avatarView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        KWIAvatarV *theAvatarView = [[KWIAvatarV alloc] initWithFrame:CGRectZero];
       
    }
    
    return self;
}


- (void)dealloc {
    KD_RELEASE_SAFELY(statusView_);
    KD_RELEASE_SAFELY(avatarView_);
    
    [super dealloc];
}

@end
