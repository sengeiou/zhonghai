//
//  KDTaskDiscussView.h
//  kdweibo
//
//  Created by bird on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDDMChatInputView.h"

@class KDCommentStatus;
@class KDTaskHeaderView;
@protocol KDTaskDiscussViewDelegate <NSObject>
- (void)setImageDataSource:(id<KDImageDataSource>)source;
- (void)thumbnailViewDidTaped:(NSArray *)srcs;

- (NSMutableArray *)getMessages;
- (void)attachmentViewWithSource:(id)source;
- (void)getCommentsFromNetWork;
- (void)postCommentToNetWork:(KDCommentStatus *)status;
@end

@interface KDTaskDiscussView : UIView
{

    UITableView *tableView_;
    
//    id<KDTaskDiscussViewDelegate> delegate_;
    
    id curBubbleCell_;  //weak reference;
    
    UIView *backgroundView_;
}
@property (nonatomic, weak) id<KDTaskDiscussViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<KDTaskDiscussViewDelegate>)delegate;
- (void)reloadData;
- (void)moreMessagesButtonVisible:(BOOL)visible;

- (void)changeTableViewHeightToFitDMChatInputView:(KDDMChatInputView *)dmChatInputView headerView:(KDTaskHeaderView *)headerView animated:(BOOL)animated;

- (void)newMessageInsertedAtIndexPaths:(NSArray *)paths;

- (void)scrollToBottom;

- (void)setTableOffset:(CGPoint)point;

- (void)olderMessageLoaded;

- (void)hideNoTips;
@end
