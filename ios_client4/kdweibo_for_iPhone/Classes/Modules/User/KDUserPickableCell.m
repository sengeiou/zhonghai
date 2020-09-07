//
//  KDUserPickableCell.m
//  kdweibo
//
//  Created by laijiandong on 12-11-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDUserPickableCell.h"

@interface KDUserPickableCell () <UIGestureRecognizerDelegate>

@property(nonatomic, retain) UIImageView *pickedImageView;

@end

@implementation KDUserPickableCell

@synthesize pickedImageView=pickedImageView_;
@synthesize picked=picked_;

@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        picked_ = NO;
        
        [self _setupUserPickableCell];
    }
    
    return self;
}

- (void)_setupUserPickableCell {
    // picked image view
    pickedImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose-circle-o.png"]];
//    [pickedImageView_ sizeToFit];
    [super.contentView addSubview:pickedImageView_];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
//    [tap release];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    if(delegate_ && [delegate_ respondsToSelector:@selector(didTapUserCell:)]) {
        [delegate_ didTapUserCell:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 10.0;
    CGFloat width = super.contentView.bounds.size.width;
    CGFloat height = super.contentView.bounds.size.height;
    
    CGRect rect = CGRectZero;
    // picked image view
    rect = pickedImageView_.frame;
//    offsetX = super.bounds.size.width - rect.size.width - 13.f;
    rect.origin = CGPointMake(offsetX, (height - rect.size.height) * 0.5);
    rect.size = CGSizeMake(25, 25);
    pickedImageView_.frame = rect;
    
    // avatar view
    offsetX += rect.size.width;
    rect = CGRectMake(offsetX + 10.0, (height - 48.0) * 0.5, 48.0, 48.0);
    super.avatarView.frame = rect;
    super.avatarView.layer.cornerRadius = 6.0f;
    // name label
    offsetX = CGRectGetMaxX(rect) + 10.f;
    rect = CGRectMake(offsetX, (CGRectGetHeight(self.frame) - 16.f) * 0.5 - 12.0f, width - offsetX - 5.0, 16.0);
    super.nameLabel.frame = rect;
    
    rect.origin.y += rect.size.height + 12;
    super.departmentLabel.frame = rect;
    
}

- (void)setPicked:(BOOL)picked {
    if (!!picked_ != !!picked) {
        picked_ = picked;
    
        pickedImageView_.image = [UIImage imageNamed:(picked_ ? @"choose_circle_n.png" : @"choose-circle-o.png")];
//        [pickedImageView_ sizeToFit];
    }
}

#pragma mark - UIGestureRecognizer Delegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    
    if (location.x < CGRectGetMinX(pickedImageView_.frame) - 5.0f) {
        return YES;
    }else {
        return NO;
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(pickedImageView_);
    //[super dealloc];
}

@end
