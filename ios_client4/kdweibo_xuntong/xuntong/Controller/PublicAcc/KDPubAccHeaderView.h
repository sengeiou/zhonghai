//
//  KDPubAccHeaderView.h
//  kdweibo
//
//  Created by wenbin_su on 15/9/15.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol KDPubAccHeaderViewDelegate;
@interface KDPubAccHeaderView : UIView

@property (nonatomic, strong, readonly) UIImageView *photoView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *distributionLabel;
@property (nonatomic, strong, readonly) UILabel *noteLabel;
//@property (nonatomic, strong, readonly) UIButton *attentionButton;

//@property (nonatomic, assign) id<KDPubAccHeaderViewDelegate> delegate;

@end

//@protocol KDPubAccHeaderViewDelegate <NSObject>
//@optional
//- (void)pubAccHeaderViewAttentionButtonPressed:(KDPubAccHeaderView *)view;
//@end
