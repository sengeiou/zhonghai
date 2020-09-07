//
//  KDPubAccFooterView.h
//  kdweibo
//
//  Created by wenbin_su on 16/1/21.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDPubAccFooterViewDelegate;
@interface KDPubAccFooterView : UIView
@property (nonatomic, strong, readonly) UIButton *attentionButton;
@property (nonatomic, strong, readonly) UIView *adminTipsView;
@property (nonatomic, strong, readonly) UILabel *adminTipsLabel;
@property (nonatomic, assign) id<KDPubAccFooterViewDelegate> delegate;

-(void)setTipsLabelText:(NSString *)tips;
@end


@protocol KDPubAccFooterViewDelegate <NSObject>
@optional
- (void)pubAccFooterViewAttentionButtonPressed:(KDPubAccFooterView *)view;
@end