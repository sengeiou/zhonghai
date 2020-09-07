//
//  UIBarButtonItem+Custom.m
//  kdweibo
//
//  Created by sevli on 16/9/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UIBarButtonItem+Custom.h"

#define ChatItem_Width 30.f


@implementation UIBarButtonItem (Custom)

+ (UIBarButtonItem * _Nullable)kd_makeDefaultBackItemTarget:(nullable id)target
                                                     action:(nullable SEL)action {

    UIButton *backBtn = [UIButton backBtnInWhiteNavWithTitle:@""];
    [backBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    return backItem;
}




+ (UIBarButtonItem * _Nullable)kd_makeItemWithImageName:(nullable NSString *)imageName
                                          highlightName:(nullable NSString *)highlightName
                                                offsetX:(CGFloat)offsetX
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action {

    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightName] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, offsetX, 0, -offsetX)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithCustomView:(nullable UIView *)customView {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    customView.bounds = CGRectOffset(customView.bounds, -[[self class] kd_customViewDistance], 0);
    return item;
}

+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithCustomView:(nullable UIView *)customView {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    customView.bounds = CGRectOffset(customView.bounds, [[self class] kd_customViewDistance], 0);
    return item;
}


+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithImageName:(nullable NSString *)imageName
                                              highlightName:(nullable NSString *)highlightName
                                                     target:(nullable id)target
                                                     action:(nullable SEL)action {


    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightName] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[self class] kd_makeLeftItemWithCustomView:button];
    return item;
}

+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithImageName:(nullable NSString *)imageName
                                               highlightName:(nullable NSString *)highlightName
                                                      target:(nullable id)target
                                                      action:(nullable SEL)action {


    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightName] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, [NSNumber kdRightItemDistance], 0, -[NSNumber kdRightItemDistance])];
    UIBarButtonItem *item = [[self class] kd_makeRightItemWithCustomView:button];
    return item;
}


+ (UIBarButtonItem * _Nullable)kd_makeLeftItemWithTitle:(nullable NSString *)title
                                                  color:(nullable UIColor *)color
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName : color, NSFontAttributeName : FS3};
    [item setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
    [item setTitlePositionAdjustment:UIOffsetMake([[self class] kd_marginDistance], 0) forBarMetrics:UIBarMetricsDefault];
    return item;
}

+ (UIBarButtonItem * _Nullable)kd_makeRightItemWithTitle:(nullable NSString *)title
                                                  color:(nullable UIColor *)color
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action {


    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName : color, NSFontAttributeName : FS3};
    [item setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
    [item setTitlePositionAdjustment:UIOffsetMake(-[[self class] kd_marginDistance], 0) forBarMetrics:UIBarMetricsDefault];
    return item;
}


+ (UIBarButtonItem * _Nullable)kd_makeChatItemWithGroup:(GroupDataModel *)group
                                                 target:(nullable id)target
                                                 action:(nullable SEL)action {

    CGFloat offsetX = [[self class] kd_leftSecondItemOffsetX];

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    customView.bounds = CGRectOffset(customView.bounds, offsetX, 0);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [customView addGestureRecognizer:tap];

    UIView *divLine = [UIView new];
    divLine.backgroundColor = [UIColor colorWithHexRGB:@"D5DBDF"];
    [customView addSubview:divLine];
    [divLine makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(customView.left).with.offset(0);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(18);
        make.centerY.equalTo(customView.centerY);
    }];


    UIImageView *photoImageView = [[UIImageView alloc] init];
    photoImageView.layer.masksToBounds = YES;
    photoImageView.layer.cornerRadius = ChatItem_Width/2;

    NSString *doublePersonId = nil;
    if (group.headerUrl.length > 0) {
        [photoImageView setImageWithURL:[NSURL URLWithString:group.headerUrl] placeholderImage:[XTImageUtil headerDefaultImage]];
    }
    else {
        if (group.groupType == GroupTypeDouble) {
            NSString *personId = nil;
            for (NSString *_id in group.participantIds) {
                if (![_id isEqualToString:BOS_CONFIG.user.userId]) {
                    personId = _id;
                    doublePersonId = _id;
                    break;
                }
            }
            PersonSimpleDataModel *person = [KDCacheHelper personForKey:personId];
            [photoImageView setImageWithURL:[NSURL URLWithString:person.photoUrl] placeholderImage:[XTImageUtil headerDefaultImage]];
        }
    }
    [customView addSubview:photoImageView];

    [photoImageView makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(divLine.right).with.offset(16);
        make.width.mas_equalTo(ChatItem_Width);
        make.height.mas_equalTo(ChatItem_Width);
        make.centerY.equalTo(customView.centerY);
    }];

    UILabel *label = [[UILabel alloc] init];
    [customView addSubview:label];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = FC1;
    label.text = group.groupName;
    label.font = FS3;
    [label sizeToFit];

    UIImage *extImage = [UIImage imageNamed:@"message_tip_shang"];
    CGFloat label_width = [[self class] kd_titleWidth];
    if (group.groupType == GroupTypeDouble) {
        label_width -= 50;
    }
    if ([group isExternalGroup]) {
        label_width -= (extImage.size.width+8);
    }

    [label makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(photoImageView.right).with.offset(6);
        make.width.mas_lessThanOrEqualTo(label_width);
        make.centerY.equalTo(customView.centerY);
    }];

    UIImageView *extImageView = [[UIImageView alloc] init];
    extImageView.image = [UIImage imageNamed:@"message_tip_shang"];
    extImageView.hidden = ![group isExternalGroup];
    [customView addSubview:extImageView];

    [extImageView makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(label.right).with.offset(4);
        make.centerY.equalTo(customView.centerY);
    }];

    return item;
}

+ (CGFloat)kd_leftSecondItemOffsetX {

    CGFloat offsetX;
    if (isiPhone6Plus) {
        offsetX = 14;
    }
    else {
        offsetX = 8;
        if (isAboveiOS9) {
            offsetX = 8;
        }
        else {
            offsetX = 9;
        }
    }
    return offsetX;
}

+ (CGFloat)kd_leftSecondImageOffsetX {

    CGFloat offsetX;
    if (isiPhone6Plus) {
        offsetX = 14;
    }
    else {
        offsetX = 8;
        if (isAboveiOS9) {
            offsetX = 8;
        }
        else {
            offsetX = 9;
        }
    }
    return offsetX;
}

+ (CGFloat)kd_titleWidth {

    if (isAboveiPhone6) { //plus
        if (isiPhone6) {  //6
            return 470.f/2;
        }
        else {
            return 820.f/3;
        }
    }
    else {
        return 365.f/2;  // 5
    }
}

// 文字边距
+ (CGFloat)kd_marginDistance {

    if (isAboveiPhone6) { //plus
        if (isiPhone6) {  //6
            return 0;//-4.f;
        }
        else {
            return 0;//-9.f;
        }
    }
    else {
        return 0;//4.f;  // 5
    }

}

// customDistance
+ (CGFloat)kd_customViewDistance {

    if (isAboveiPhone6) { //plus
        if (isiPhone6) {  //6
            return -4.f;
        }
        else {
            return -9.f;
        }
    }
    else {
        return -4.f;  // 5
    }
    
}




@end
