//
//  KDABPersonCell.m
//  kdweibo
//
//  Created by laijiandong on 12-11-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDABPersonCell.h"

#import "KDABPerson.h"

@interface KDABPersonCell ()

@property (nonatomic, retain) UIImageView *separatorImageView;
@property (nonatomic, retain) UIImageView *starView;

@end

@implementation KDABPersonCell

@synthesize person=person_;

@synthesize avatarView=avatarView_;
@synthesize nameLabel=nameLabel_;
@synthesize departmentLabel = departmentLabel_;
@synthesize stateLabel = stateLabel_;

@synthesize separatorImageView=separatorImageView_;
@synthesize starView=starView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupABPersonCell];
    }
    
    return self;
}

- (void)_setupABPersonCell {
    // avatar view
    avatarView_ = [KDUserAvatarView avatarView];// retain];
    avatarView_.enabled = NO;
    
    [super.contentView addSubview:avatarView_];
    
	// name label
    nameLabel_                      = [[UILabel alloc] initWithFrame:CGRectZero];
	nameLabel_.backgroundColor      = [UIColor clearColor];
	nameLabel_.font                 = [UIFont systemFontOfSize:16.0f];
	nameLabel_.textColor            = [UIColor blackColor];
    nameLabel_.highlightedTextColor = [UIColor whiteColor];
	
    [super.contentView addSubview:nameLabel_];
    
    departmentLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    departmentLabel_.textColor = MESSAGE_ACTNAME_COLOR;
    departmentLabel_.highlightedTextColor = [UIColor whiteColor];
    departmentLabel_.font = [UIFont systemFontOfSize:14.0f];
    departmentLabel_.backgroundColor = [UIColor clearColor];
    
    [super.contentView addSubview:departmentLabel_];
    
    //state label
    stateLabel_                      = [[UILabel alloc] initWithFrame:CGRectZero];
    stateLabel_.backgroundColor      = [UIColor clearColor];
    stateLabel_.font                 = [UIFont systemFontOfSize:16.0f];
    stateLabel_.textColor            = [UIColor darkGrayColor];
    stateLabel_.textAlignment        = NSTextAlignmentRight;
    stateLabel_.highlightedTextColor = [UIColor whiteColor];
    [super.contentView addSubview:stateLabel_];
    
    // star view
    starView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    starView_.hidden = YES;
    starView_.image = [UIImage imageNamed:@"favoried.png"];
    [starView_ sizeToFit];
    
    [super.contentView addSubview:starView_];
    
    UIImage *separatorImage = [UIImage imageNamed:@"address_book_separator_line_v2.png"];
    separatorImage = [separatorImage stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    separatorImageView_ = [[UIImageView alloc] initWithImage:separatorImage];
    [super.contentView addSubview:separatorImageView_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = super.contentView.bounds.size.height;
    
    // avatar view
    CGFloat offsetX = 10.0;
    CGRect rect = CGRectMake(offsetX, (height - 48.0) * 0.5, 48.0, 48.0);
    avatarView_.frame = rect;
    
    // name label
    offsetX += rect.size.width + 10.0;
    rect = CGRectMake(offsetX, height * 0.5f - 20.0f, 195.0f, 16.0f);
    nameLabel_.frame = rect;
    
    rect.origin.y += rect.size.height + 12.0f;
    rect.size.height = 15.0f;
    departmentLabel_.frame = rect;
    
    // star view
    rect = starView_.bounds;
    offsetX = self.frame.size.width-14-rect.size.width;
    rect.origin = CGPointMake(offsetX, (height - rect.size.height) * 0.5);
    starView_.frame = rect;
    
    separatorImageView_.frame = CGRectMake(0.0f, height - 1.0f, self.bounds.size.width, 1.0f);
    
    //state label
    CGFloat minX = 0.0f;
    if(starView_.hidden) {
        minX = CGRectGetMaxX(nameLabel_.frame) + 5.0f;
    }else {
        minX = CGRectGetMaxX(starView_.frame) + 5.0f;
    }
    
    stateLabel_.frame = CGRectMake(minX, (CGRectGetHeight(super.contentView.frame) - CGRectGetHeight(stateLabel_.bounds)) * 0.5f, CGRectGetWidth(super.contentView.bounds) - 12.0f - minX, CGRectGetHeight(stateLabel_.bounds));
}

- (void)update:(BOOL)showFavoritedState {
    avatarView_.avatarDataSource = person_;
    
    nameLabel_.text = person_.name;
    
    departmentLabel_.text = person_.department;
    
    [nameLabel_ sizeToFit];
    [departmentLabel_ sizeToFit];
    
    //TODO:update state label text
    
    starView_.hidden = (showFavoritedState && person_.favorited) ? NO : YES;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    nameLabel_.highlighted  = selected;
    stateLabel_.highlighted = selected;
    departmentLabel_.highlighted = selected;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(person_);
    
    //KD_RELEASE_SAFELY(separatorImageView_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(departmentLabel_);
    //KD_RELEASE_SAFELY(stateLabel_);
    
    //KD_RELEASE_SAFELY(starView_);
    
    //[super dealloc];
}

@end
