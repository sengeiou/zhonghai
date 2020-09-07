//
//  KDTaskHeaderView.h
//  kdweibo
//
//  Created by bird on 13-11-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDExpressionLabel.h"
#import "KDTask.h"
#import "KDStatusCounts.h"
#import "AttributedLabel.h"

@protocol KDTaskHeaderViewDelegate <NSObject>
- (void)taskFinished;
- (void)taskCancelFinished;
@end

@interface KDTaskHeaderView : UIView
{
    KDExpressionLabel *contentView_;
    UIImageView      *backgroundView_;
    
    UIButton *finishButton_;
    
    UIImageView *arrowImageView_;
    
    UILabel     *replyCountLabel_;
    AttributedLabel     *infoLabel_;
}
@property (nonatomic, retain) KDTask *task;
@property (nonatomic, retain) KDStatusCounts *count;
@property (nonatomic, weak) id<KDTaskHeaderViewDelegate> delegate;
+ (float)getHeightOfHeaderView:(KDTask *)task;
@end
