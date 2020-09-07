//
//  KDTodoListCell.h
//  kdweibo
//
//  Created by bird on 13-7-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUserAvatarView.h"
#import "KDTodo.h"
#import "KDExpressionLabel.h"
#define KD_TODOCELL_FONTSIZE              14.0f
#define KD_TODO_CONTENT_TOP_MARGIN    8.0
#define KD_TODO_CONTENT_BOTTOM_MARGIN    10.0
#define KD_TODO_CONTENT_SPACING    8.0
#define KD_TODO_HEADER_HEIGHT     20.0f
#define KD_TODO_FOOT_HEIGHT     35.0f
#define KD_TODO_BG_SPACE        6.5f
#define KD_TODO_BG_TOP        10.0f
@protocol TodoActionDelegate <NSObject>

- (void)todoAction:(Action *)action todo:(KDTodo *)td;

@end

@interface KDTodoListCell : UITableViewCell
{
    KDUserAvatarView    *userAvatarView_;
    UIImageView           *backgroundView_;
    KDTodo *todo_;
    KDExpressionLabel *contentView_;
    KDExpressionLabel *titleView_;
    
    UILabel       *lineView_;
    UILabel       *nameLabel_;
    UILabel       *dateLabel_;
    
    UIView *undoView_;
    UIView *doneView_;
    
    UIImageView *separtorView_;
    
    UIView *highlightedView_;
    
}
@property(nonatomic, retain) KDTodo *todo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controller:(id)delegate;
+ (CGFloat)messageInteractiveCellHeight:(KDTodo *)todo;
@end
