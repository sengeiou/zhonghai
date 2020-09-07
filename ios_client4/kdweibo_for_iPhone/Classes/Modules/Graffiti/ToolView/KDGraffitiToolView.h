//
//  KDGraffitiToolView.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDGraffitiToolViewDelegate <NSObject>
- (void)choosePencil;
- (void)chooseText;
- (void)chooseCut;
- (void)send;

@end

// 高44
@interface KDGraffitiToolView : UIView

@property (nonatomic, strong) UIButton *drawBtn;
@property (nonatomic, strong) UIButton *textBtn;
@property (nonatomic, strong) UIButton *cutBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, weak)id <KDGraffitiToolViewDelegate> delegate;

@end
