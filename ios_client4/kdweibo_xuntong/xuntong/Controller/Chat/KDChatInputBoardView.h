//
//  KDChatInputBoardView.h
//  kdweibo
//
//  Created by wenbin_su on 15/6/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDChatInputBoardModal : NSObject

@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id block; // press action
@property (nonatomic, assign) BOOL bShouldHideNewFlag;
@property (nonatomic, strong) NSString *picUrl;

@end

@interface KDChatInputBoardView : UIView

- (instancetype)initWithFrame:(CGRect)frame modals:(NSMutableArray *)mArrayModals;

@end
