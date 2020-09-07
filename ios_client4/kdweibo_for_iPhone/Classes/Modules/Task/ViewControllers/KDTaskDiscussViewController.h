//
//  KDTaskDiscussViewController.h
//  kdweibo
//
//  Created by bird on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTaskDiscussView.h"
#import "KDDMChatInputView.h"
#import "KDTaskHeaderView.h"

@protocol KDTaskDiscussViewControllerDelegate <NSObject>
- (void)commentCountIncreaseWithTaskId:(NSString *)taskId count:(NSInteger)comments;
- (void)statusChangeWithTaskId:(NSString *)tId status:(int)status;
@end

@interface KDTaskDiscussViewController : UIViewController<KDTaskDiscussViewDelegate>
{
    KDTaskDiscussView *taskView_;
    
    KDDMChatInputView *chatInputView_;
    
    KDTaskHeaderView  *taskHeadView_;
    
    NSString *taskId_;
    
    
    id<KDImageDataSource> tappedOnImageDataSource_;
    
    NSMutableArray *messages_;
    
    struct {
        unsigned int current_cursor;
        unsigned int has_more_cursor:1;
        unsigned int page_count:20;
        BOOL    isFirstload:YES;
    }flags_;
    
    UILabel *label_;
//    id <KDTaskDiscussViewControllerDelegate> delegate_;
}
@property (nonatomic, weak)id<KDTaskDiscussViewControllerDelegate> delegate;

- (id)initWithTaskId:(NSString *)taskId;
@end
