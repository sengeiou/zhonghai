//
//  KDInviteColleagueTableViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-6-6.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDInviteColleagueTableViewCell.h"

@interface KDInviteColleagueTableViewCell(){
    CALayer *lineLayer;
}
@property (nonatomic, retain) UIImageView *vectorImage;

@end

@implementation KDInviteColleagueTableViewCell
@synthesize titleTextLabel = _titleTextLabel;
@synthesize imageView  = _imageView;
@synthesize vectorImage = _vectorImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    
    self.imageView = [[UIImageView alloc]init];//autorelease];
    [self.contentView addSubview:_imageView];
    
    self.backgroundColor = [UIColor kdBackgroundColor2];
    self.contentView.backgroundColor = self.backgroundColor;
    
    self.titleTextLabel = [[UILabel alloc]init];//autorelease];
    self.titleTextLabel.textColor = FC1;
    self.titleTextLabel.font = FS3;
    self.textLabel.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:_titleTextLabel];
    
    self.vectorImage = [[UIImageView alloc]init];//autorelease];
    [self.vectorImage setImage:[UIImage imageNamed:@"common_img_vector"]];
    [self.vectorImage sizeToFit];
    self.vectorImage.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_vectorImage];
    
                        lineLayer = [CALayer layer];// retain];
    
    lineLayer.backgroundColor = UIColorFromRGB(0xdddddd).CGColor;
    [self.contentView.layer addSublayer:lineLayer];
    
}


#define imageViewHeightAndWidth 48.f
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offSetX = 10.f;
    CGFloat offSetY = 10.f;
    CGRect rect = CGRectMake(offSetX, offSetY, imageViewHeightAndWidth,imageViewHeightAndWidth);
    self.imageView.frame = rect;
    
    offSetX = CGRectGetMaxX(self.imageView.frame) + 10.f;
    rect = CGRectMake(offSetX, offSetY, 200, CGRectGetHeight(self.contentView.frame) - offSetY *2);
    self.titleTextLabel.frame = rect;
    
    offSetX = CGRectGetMaxX(self.titleTextLabel.frame);
    rect = CGRectMake(CGRectGetWidth(self.contentView.frame) - 13.f - CGRectGetWidth(_vectorImage.frame),
                      (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.vectorImage.frame))/2
                      , CGRectGetWidth(self.vectorImage.frame)
                      , CGRectGetHeight(self.vectorImage.frame));
    self.vectorImage.frame = rect;
    
}


- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    lineLayer.frame = CGRectMake(48.0 + 2*10, CGRectGetHeight(self.contentView.layer.frame) - 0.5f, CGRectGetWidth(self.contentView.layer.frame) - 48.0 + 2*10, 0.5f);
    
}

- (void)dealloc{
    //KD_RELEASE_SAFELY(_imageView);
    //KD_RELEASE_SAFELY(_titleTextLabel);
    //KD_RELEASE_SAFELY(_vectorImage);
    //KD_RELEASE_SAFELY(lineLayer);
    //[super dealloc];
}

@end
