//
//  KDPhoneContactCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPhoneContactCell.h"

@implementation KDPhoneContactCell
{
    UIImageView *pickedImageView_;
    UILabel     *nameLabel_;
    UILabel     *stateLabel_;
    
    UIImageView *seperatorView_;
}

@synthesize picked = picked_;
@synthesize pickedImageName = pickedImageName_;
@synthesize normalImageName = normalImageName_;
@synthesize nameLabel = nameLabel_;
@synthesize stateLabel = stateLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        picked_ = NO;
        
        pickedImageName_ = [[NSString alloc] initWithString:@"phone_contact_cell_picked_v3"];
        normalImageName_ = [[NSString alloc] initWithString:@"phone_contact_cell_normal_v3"];
        
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(pickedImageView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(pickedImageName_);
    //KD_RELEASE_SAFELY(normalImageName_);
    //KD_RELEASE_SAFELY(seperatorView_);
    
    //[super dealloc];
}

- (void)setUp
{
    pickedImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:normalImageName_]];
    [pickedImageView_ sizeToFit];
    pickedImageView_.opaque = YES;
    
    [self.contentView addSubview:pickedImageView_];
    
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:nameLabel_];
    
    stateLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    stateLabel_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:stateLabel_];
    
    UIImage *image = [UIImage imageNamed:@"phone_contact_seperator"];
    seperatorView_ = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:seperatorView_];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    pickedImageView_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(pickedImageView_.bounds) - 15.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(pickedImageView_.bounds)) * 0.5f, CGRectGetWidth(pickedImageView_.bounds), CGRectGetHeight(pickedImageView_.bounds));
    
    [nameLabel_ sizeToFit];
    nameLabel_.frame = CGRectMake(15.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(nameLabel_.frame)) * 0.5f, CGRectGetMinX(pickedImageView_.frame) - 20.0f, CGRectGetHeight(nameLabel_.frame));
    
    [stateLabel_ sizeToFit];
    stateLabel_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(stateLabel_.bounds) - 15.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(stateLabel_.bounds)) * 0.5f, CGRectGetWidth(stateLabel_.bounds), CGRectGetHeight(stateLabel_.bounds));
    
    seperatorView_.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame) - 1.0f, CGRectGetWidth(self.contentView.frame), 1.0f);
}

- (void)setPicked:(BOOL)picked
{
    if(!picked_ != !picked) {
        picked_ = picked;
        
        pickedImageView_.image = [UIImage imageNamed:picked_ ? pickedImageName_ : normalImageName_];
        [pickedImageView_ sizeToFit];
    }
}

- (void)setShowStateLabel:(BOOL)show
{
    pickedImageView_.hidden = show;
    stateLabel_.hidden = !show;
}
@end
