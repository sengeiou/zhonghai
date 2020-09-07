//
//  KDSubscribeCell.m
//  kdweibo
//
//  Created by wenbin_su on 15/9/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSubscribeCell.h"
@interface KDSubscribeCell()
@end

@implementation KDSubscribeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        //应用logo
        _appImageView = [[XTPersonHeaderImageView alloc] init];
        _appImageView.frame = CGRectMake(10, 7, 55, 55);
        _appImageView.layer.cornerRadius =  8;
        _appImageView.layer.masksToBounds = YES;
        _appImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_appImageView];
        
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 75, 30)];
        _appNameLabel.backgroundColor = [UIColor clearColor];
        _appNameLabel.textColor = FC1;
        _appNameLabel.font = FS7;
        _appNameLabel.numberOfLines = 0;
        _appNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_appNameLabel];
        _isCreatorPerson = NO;
    }
    return self;
}

- (void)setData:(PersonSimpleDataModel *)data
{
    _data = data;
    
    _appImageView.person = data;
    _appNameLabel.text = data.personName;
    
    [_appNameLabel sizeToFit];
    CGSize size = CGSizeMake(75, 30);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FS7,NSFontAttributeName, nil];
    CGSize actualSize = [data.personName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    _appNameLabel.frame = CGRectMake(0, 70,75,actualSize.height);
}

- (void)setIsCreatorPerson:(BOOL)isCreatorPerson
{
//    _isCreatorPerson = isCreatorPerson;
//    if(isCreatorPerson)
//    {
//        _appNameLabel.text = [NSString stringWithFormat:@"☆%@",self.data.personName];
//        [_appNameLabel sizeToFit];
//        CGSize size = CGSizeMake(75, 30);
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FS7,NSFontAttributeName, nil];
//        CGSize actualSize = [self.data.personName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
//        _appNameLabel.frame = CGRectMake(0, 70,75,actualSize.height);
//    }
    _isCreatorPerson = isCreatorPerson;
    if(isCreatorPerson)
    {
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@", self.data.personName]];
        [mas dz_setImageWithName:@"app_pic_initiator_normal" range:NSMakeRange(0, 0)];
        [mas dz_setFont:FS7];
        [mas dz_setBaselineOffset:-2 range:NSMakeRange(0, 1)];
        _appNameLabel.attributedText = mas;
        
        //            SetBorder(_appNameLabel, [UIColor blackColor]);
        //            _appNameLabel.text = nil;
        [_appNameLabel sizeToFit];
        //            CGSize size = CGSizeMake(75, 30);
        //            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FS7,NSFontAttributeName, nil];
        //            CGSize actualSize = [self.data.personName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        //            _appNameLabel.frame = CGRectMake(0, 70,75,actualSize.height);
        SetOrigin(_appNameLabel.frame, 0, 70);
        SetWidth(_appNameLabel.frame, 75);
    }
}
- (void)setIsPersonStateChanged:(BOOL)isChanged
{
    if(isChanged)
    {
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  ", self.data.personName]];
        UIImage *image =[UIImage imageNamed:@"phone_tip_green"];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = image;
        textAttachment.bounds = CGRectMake(0, -2, 12, 12);
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [mas replaceCharactersInRange:NSMakeRange(mas.length -1, 1) withAttributedString:attrStringWithImage];
        
        _appNameLabel.attributedText = mas;
        [mas dz_setFont:FS7];
        [_appNameLabel sizeToFit];
        SetOrigin(_appNameLabel.frame, 0, 70);
        SetWidth(_appNameLabel.frame, 75);
    }
}
@end
