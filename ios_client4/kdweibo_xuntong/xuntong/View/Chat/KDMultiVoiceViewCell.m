//
//  KDMultiVoiceViewCell.m
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMultiVoiceViewCell.h"
#import "PersonSimpleDataModel.h"
#import "UIImageView+WebCache.h"

@interface KDMultiVoiceViewCell ()
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) PersonSimpleDataModel *person;
@end

@implementation KDMultiVoiceViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (void)initSome
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    [self.headImageView setBackgroundColor:[UIColor clearColor]];
    [self.headImageView.layer setMasksToBounds:YES];
    [self.headImageView.layer setCornerRadius:3];
    [self addSubview:self.headImageView];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 70, 35)];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.nameLabel setFont:[UIFont systemFontOfSize:17]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:self.nameLabel];
}

-(void)setCellInformationWithPerson:(PersonSimpleDataModel *)person
{
    self.person = person;
    
    NSURL *imageURL = nil;
    if ([person hasHeaderPicture])
    {
        NSString *url = person.photoUrl;
        if ([url rangeOfString:@"?"].location != NSNotFound)
        {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else
        {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    
    [self.headImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"app_default_icon.png"]];
    [self.nameLabel setText:person.personName];
}
@end

