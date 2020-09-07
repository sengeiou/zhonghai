//
//  KDChatDetailSearchCell.m
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChatDetailSearchCell.h"

@interface KDChatDetailSearchCell ()

@property (nonatomic, strong)  UIButton *fileButton;
@property (nonatomic, strong)  UIButton *pictureButton;
@property (nonatomic, strong)  UIButton *appButton;
@property (nonatomic, strong)  UIButton *messageButton;

@end

#define NUMBER_OF_TYPE 3

@implementation KDChatDetailSearchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (UIButton *)customButtonForSearch {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 80, 24)];
    [button setImage:[UIImage imageNamed:@"detail_img_file"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdButtonHightColor]] forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [button setTitle:@"文件" forState:UIControlStateNormal];
    [button setTitleColor:FC1 forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [button.titleLabel setFont:FS6];
    
    return button;
}

- (void)setupViews{
    _fileButton = [self customButtonForSearch];
    [_fileButton setImage:[UIImage imageNamed:@"detail_img_file"] forState:UIControlStateNormal];
    [_fileButton setTitle:ASLocalizedString(@"Chat_send_file") forState:UIControlStateNormal];
    [_fileButton addTarget:self action:@selector(fileAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_fileButton];
    [_fileButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left);
        make.top.and.bottom.equalTo(self.contentView);
        make.width.equalTo(self.contentView.width).multipliedBy(1.0/NUMBER_OF_TYPE);
    }];
    
    _pictureButton = [self customButtonForSearch];
    [_pictureButton setImage:[UIImage imageNamed:@"detail_img_picture"] forState:UIControlStateNormal];
    [_pictureButton setTitle:ASLocalizedString(@"KDCommunityShareView_Pic") forState:UIControlStateNormal];
    [_pictureButton addTarget:self action:@selector(pictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_pictureButton];
    [_pictureButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_fileButton.right);
        make.top.and.bottom.equalTo(self.contentView);
        make.width.equalTo(self.contentView.width).multipliedBy(1.0/NUMBER_OF_TYPE);
    }];
    
//    _appButton = [self customButtonForSearch];
//    [_appButton setImage:[UIImage imageNamed:@"detail_img_app"] forState:UIControlStateNormal];
//    [_appButton setTitle:@"应用" forState:UIControlStateNormal];
//    [_appButton addTarget:self action:@selector(appAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:_appButton];
//    [_appButton makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_pictureButton.right);
//        make.top.and.bottom.equalTo(self.contentView);
//        make.width.equalTo(self.contentView.width).multipliedBy(1.0/4);
//    }];
    
    _messageButton = [self customButtonForSearch];
    [_messageButton setImage:[UIImage imageNamed:@"detail_img_search"] forState:UIControlStateNormal];
    [_messageButton setTitle:ASLocalizedString(@"KDSearchForXTChatViewController_Search") forState:UIControlStateNormal];
    [_messageButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_messageButton];
    [_messageButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pictureButton.right);
        make.top.and.bottom.equalTo(self.contentView);
        make.width.equalTo(self.contentView.width).multipliedBy(1.0/NUMBER_OF_TYPE);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame; //强制设置下宽度，在有索引下会留出索引的宽度
    frame.size.width = ScreenFullWidth;
    //    self.contentView.frame = frame;
}

- (void)fileAction:(id)sender{
    if (self.actionBlock) {
        self.actionBlock(KDChatDetailSearchType_File);
    }
}

- (void)pictureAction:(id)sender{
    if (self.actionBlock) {
        self.actionBlock(KDChatDetailSearchType_Picture);
    }
}

- (void)appAction:(id)sender{
    if (self.actionBlock) {
        self.actionBlock(KDChatDetailSearchType_App);
    }
}

- (void)messageAction:(id)sender{
    if (self.actionBlock) {
        self.actionBlock(KDChatDetailSearchType_Message);
    }
}

@end
