//
//  KDTodoListCell.m
//  kdweibo
//
//  Created by bird on 13-7-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTodoListCell.h"
#import "KDDefaultViewControllerContext.h"
#import "NSDate+Additions.h"
#import "UIImage+Additions.h"

#define AVARTAR_SIZE 34.f
#define CONTENT_MARGIN 11.f
#define TITLE_MARGIN 18.f
@interface KDTodoListCell()<KDExpressionLabelDelegate>

@property(nonatomic, assign) id<TodoActionDelegate> delegate_;
@end

@implementation KDTodoListCell
@synthesize todo = todo_;
@synthesize delegate_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controller:(id)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.delegate_ = delegate;
        
        backgroundView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        backgroundView_.backgroundColor = [UIColor kdBackgroundColor2];
        backgroundView_.userInteractionEnabled = YES;
        [self addSubview:backgroundView_];
        
        highlightedView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:highlightedView_];
        
        CGRect rect = self.bounds;
        rect.size.width -= 2*KD_TODO_BG_SPACE+2*KD_TODO_CONTENT_SPACING;
        contentView_ = [[KDExpressionLabel alloc] initWithFrame:rect andType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
        contentView_.delegate = self;
        contentView_.backgroundColor = [UIColor clearColor];
        contentView_.font = [UIFont systemFontOfSize:17.0];
        contentView_.textColor = MESSAGE_TOPIC_COLOR;
        contentView_.textAlignment = NSTextAlignmentLeft;
        [backgroundView_ addSubview:contentView_];
        
        titleView_ = [[KDExpressionLabel alloc] initWithFrame:rect andType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
        titleView_.delegate = self;
        titleView_.backgroundColor = [UIColor clearColor];
        titleView_.font = [UIFont systemFontOfSize:16.f];
        titleView_.textColor = MESSAGE_NAME_COLOR;
        titleView_.textAlignment = NSTextAlignmentLeft;
        [backgroundView_ addSubview:titleView_];
        
        // avatar view
        userAvatarView_ = [KDUserAvatarView avatarView];// retain];
        [userAvatarView_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        userAvatarView_.layer.cornerRadius = 6;
        userAvatarView_.layer.masksToBounds = YES;
        [backgroundView_ addSubview:userAvatarView_];
        
        // name
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor blackColor];
        nameLabel_.font = [UIFont systemFontOfSize:16.f];
        nameLabel_.textAlignment = NSTextAlignmentLeft;
        [backgroundView_ addSubview:nameLabel_];
        
        // date
        dateLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        dateLabel_.backgroundColor = [UIColor clearColor];
        dateLabel_.textColor = MESSAGE_DATE_COLOR;
        dateLabel_.font = [UIFont systemFontOfSize:12.f];
        dateLabel_.textAlignment = NSTextAlignmentLeft;
        [backgroundView_ addSubview:dateLabel_];
        
        separtorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"todo_line"]];
        [backgroundView_ addSubview:separtorView_];
        
        
        lineView_ = [[UILabel alloc] initWithFrame:CGRectZero];
        lineView_.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0];
        [backgroundView_ addSubview:lineView_];
        
        
        undoView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:undoView_];
//        [undoView_ release];
        undoView_.hidden = YES;
        
        doneView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:doneView_];
//        [doneView_ release];
        doneView_.hidden = YES;
        
        
        UIImage *finishedImage = [UIImage imageNamed:@"todo_finished"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:finishedImage];
        imageView.frame = CGRectMake(KD_TODO_CONTENT_SPACING, (KD_TODO_FOOT_HEIGHT - finishedImage.size.height)/2, finishedImage.size.width, finishedImage.size.height);
        [doneView_ addSubview:imageView];
//        [imageView release];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+8, 0, 100, KD_TODO_FOOT_HEIGHT)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = MESSAGE_NAME_COLOR;
        nameLabel.font = [UIFont systemFontOfSize:14.0];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [doneView_ addSubview:nameLabel];
//        [nameLabel release];
        nameLabel.tag = 0x99;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+30, 0, self.bounds.size.width - 2*KD_TODO_BG_SPACE -(CGRectGetMaxX(nameLabel.frame)+30)-7 , KD_TODO_FOOT_HEIGHT)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = MESSAGE_NAME_COLOR;
        dateLabel.font = [UIFont systemFontOfSize:14.0];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [doneView_ addSubview:dateLabel];
//        [dateLabel release];
        dateLabel.tag = 0x98;
        
        CGSize size = CGSizeMake((self.bounds.size.width-2*KD_TODO_BG_SPACE)/3.0, KD_TODO_FOOT_HEIGHT-1);
        
        UIButton *detailButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss"] forState:UIControlStateNormal];
        [detailButton_ setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        detailButton_.frame =CGRectMake(0, 0, size.width, size.height);
        [detailButton_ setTitleColor:[UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.0f] forState:UIControlStateNormal];
        detailButton_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [detailButton_ setTitle:ASLocalizedString(@"KDTodoListCell_disscus")forState:UIControlStateNormal];
        [detailButton_ setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
        [detailButton_ setBackgroundImage:[UIImage imageNamed:@"todo_selected_bg"] forState:UIControlStateHighlighted];
        [undoView_ addSubview:detailButton_];
        detailButton_.tag = 0x99;
        [detailButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
//        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 7, 22, 17)];
//        countLabel.backgroundColor = [UIColor clearColor];
//        countLabel.textColor = [UIColor whiteColor];
//        countLabel.adjustsFontSizeToFitWidth = YES;
//        countLabel.font = [UIFont systemFontOfSize:13.0f];
//        countLabel.textAlignment = NSTextAlignmentCenter;
//        [detailButton_ addSubview:countLabel];
//        [countLabel release];
//        countLabel.tag = 0x11;
        
        
        UIButton *ignoreButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [ignoreButton_ setTitleColor:[UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.0f] forState:UIControlStateNormal];
        [ignoreButton_ setImage:[UIImage imageNamed:@"todo_finish"] forState:UIControlStateNormal];
        [ignoreButton_ setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        ignoreButton_.frame =CGRectMake(size.width, 0, size.width, size.height);
        ignoreButton_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [ignoreButton_ setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")forState:UIControlStateNormal];
        [ignoreButton_ setTitleEdgeInsets:UIEdgeInsetsMake(3, 7, 0, 0)];
        [ignoreButton_ setBackgroundImage:[UIImage imageNamed:@"todo_selected_bg"] forState:UIControlStateHighlighted];
        [undoView_ addSubview:ignoreButton_];
        ignoreButton_.tag = 0x98;
        [ignoreButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *finishButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [finishButton_ setTitleColor:[UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.0f] forState:UIControlStateNormal];
        [finishButton_ setImage:[UIImage imageNamed:@"todo_ingore"] forState:UIControlStateNormal];
        [finishButton_ setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        finishButton_.frame =CGRectMake(size.width*2, 0, size.width, size.height);
        finishButton_.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [finishButton_ setTitle:ASLocalizedString(@"KDInviteTeamCell_ignore")forState:UIControlStateNormal];
        [finishButton_ setTitleEdgeInsets:UIEdgeInsetsMake(3, 7, 0, 0)];
        [finishButton_ setBackgroundImage:[UIImage imageNamed:@"todo_selected_bg"] forState:UIControlStateHighlighted];
        [undoView_ addSubview:finishButton_];
        finishButton_.tag = 0x97;
        [finishButton_ addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layout];
}
- (void)layout
{
    // margin left and top both is 10
    CGFloat offsetX = KD_TODO_CONTENT_SPACING;
    CGFloat offsetY = KD_TODO_CONTENT_TOP_MARGIN;
    
    CGRect rect = CGRectMake(offsetX, offsetX, AVARTAR_SIZE, AVARTAR_SIZE);
    userAvatarView_.frame = rect;
    
    rect.origin.x = CGRectGetMaxX(rect) + 10.f;
    rect.origin.y += 2.f;
    rect.size.width = self.bounds.size.width - rect.origin.x -2*KD_TODO_BG_SPACE - KD_TODO_CONTENT_SPACING;
    rect.size.height = 16.f;
    nameLabel_.frame =  rect;
    
    rect.origin.y = CGRectGetMaxY(rect) + 3.f;
    rect.size.height = 12.f;
    dateLabel_.frame = rect;
    
    
    offsetY = CGRectGetMaxY(userAvatarView_.frame) + CONTENT_MARGIN;
    float width = self.bounds.size.width - 2*KD_TODO_BG_SPACE-2*KD_TODO_CONTENT_SPACING;;
    
    CGSize size =  [titleView_ sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    
    
    if(![todo_ isTask])
    {
        rect = CGRectMake(offsetX, offsetY, size.width, size.height);
        titleView_.frame = rect;
    }
    else
        rect.origin.x = offsetX;
    
    
    separtorView_.frame = CGRectMake(6, CGRectGetMaxY(rect) +8, self.bounds.size.width-12, separtorView_.image.size.height);
    
    rect.origin.y = CGRectGetMaxY(rect) + TITLE_MARGIN;
    size = [contentView_ sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    rect.size = size;
    contentView_.frame = rect;
    
    rect.origin.x = 6;
    rect.origin.y += rect.size.height + KD_TODO_CONTENT_BOTTOM_MARGIN;
    size = CGSizeMake(self.bounds.size.width - 12, 0.5);
    rect.size = size;
    lineView_.frame = rect;
    
    rect.size.height = KD_TODO_FOOT_HEIGHT;
    CGRect frame = rect;
    frame.origin.x += 0.5f;
    frame.origin.y += 0.5f;
    frame.size.height -= 1.0f;
    frame.size.width  -= 1.0f;
    
    doneView_.frame = frame;
    undoView_.frame = frame;
    
    rect.origin.x = 0;
    rect.size.width = self.bounds.size.width;
    rect.size.height += rect.origin.y;
    rect.origin.y = KD_TODO_BG_TOP;
    backgroundView_.frame = rect;
    
    highlightedView_.frame = CGRectInset(backgroundView_.bounds, 0.5, 0.5);
}
- (Action *)getIngoreAction
{
    if ([todo_.action count]>1)
        return [todo_.action objectAtIndex:1];
    else
    {
        Action *action =[[Action alloc] init];
        action.title =@"delete";
        return action;
    }
    return nil;
}
- (Action *)getOtherAction
{
    if ([todo_.action count]>0)
        return [todo_.action objectAtIndex:0];
    else
    {
        Action *action =[[Action alloc] init];
        if([todo_.status isEqualToString:@"30"])
            action.title =@"finish";
        else
            action.title =@"unFinish";
        return action;
    }
    return nil;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(highlightedView_);
    //KD_RELEASE_SAFELY(separtorView_);
    //KD_RELEASE_SAFELY(titleView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(userAvatarView_);
    //KD_RELEASE_SAFELY(dateLabel_);
    //KD_RELEASE_SAFELY(lineView_);
    //KD_RELEASE_SAFELY(contentView_);
    //KD_RELEASE_SAFELY(todo_);
    //[super dealloc];
}
#pragma mark - user action methods
- (void)action:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    Action  *action = nil;
    switch (btn.tag) {
        case 0x98:
            action = [self getOtherAction];
            break;
        case 0x97:
            action = [self getIngoreAction];
            break;
        case 0x99:
            
            break;
        default:
            break;
    }
    
    if (self.delegate_ && [self.delegate_ respondsToSelector:@selector(todoAction:todo:)])
        [self.delegate_ todoAction:action todo:todo_];
}
#pragma mark - update methods
- (void)update
{
    if ([todo_.status isEqualToString:@"undo"]) {
        [undoView_ setHidden:NO];
        [doneView_ setHidden:YES];
        [separtorView_ setHidden:NO];
        
        UIButton *detailButton_ = (UIButton *)[undoView_ viewWithTag:0x99];
        UIButton *ignoreButton_ = (UIButton *)[undoView_ viewWithTag:0x97];
        UIButton *finishButton_ = (UIButton *)[undoView_ viewWithTag:0x98];
        
        [detailButton_ setHidden:![todo_.fromType isEqual:@"task"]];
        
        if (!detailButton_.hidden) {
            
            if ([todo_.taskCommentCount intValue]>0) {
                NSString *taskCommentCount = todo_.taskCommentCount;
                int count = [todo_.taskCommentCount intValue];
                if (count >99)
                    taskCommentCount = @"99+";
                //countLabel.text = taskCommentCount;
                
                //[detailButton_ setImage:[UIImage imageNamed:@"todo_discuss_active"] forState:UIControlStateNormal];
                [detailButton_ setTitle:taskCommentCount forState:UIControlStateNormal];
            }
            else
            {
                [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss"] forState:UIControlStateNormal];
                [detailButton_ setTitle:ASLocalizedString(@"KDTodoListCell_disscus")forState:UIControlStateNormal];
            }
            
            
        }
        
        Action *ignore = [self getIngoreAction];
        Action *other  = [self getOtherAction];
        
        [ignoreButton_ setHidden:!ignore];
        [finishButton_ setHidden:!other];
        
        if (ignore)
            [ignoreButton_ setTitle:ignore.title forState:UIControlStateNormal];
        
        if (other)
            [finishButton_ setTitle:other.title forState:UIControlStateNormal];
        
        
        CGSize size = CGSizeMake((self.bounds.size.width-2*KD_TODO_BG_SPACE-1.0f)/3.0, KD_TODO_FOOT_HEIGHT-1);
        
        detailButton_.frame = CGRectMake(0, 0, size.width, size.height);
        ignoreButton_.frame = CGRectMake(2*size.width, 0, size.width, size.height);
        finishButton_.frame = CGRectMake(size.width, 0, size.width, size.height);
        
        //忽略按钮
        [ignoreButton_ setImage:[UIImage imageNamed:@"todo_ingore"] forState:UIControlStateNormal];
        [ignoreButton_ setTitle:ASLocalizedString(@"KDInviteTeamCell_ignore")forState:UIControlStateNormal];
        //完成按钮
        [finishButton_ setImage:[UIImage imageNamed:@"todo_finish"] forState:UIControlStateNormal];
        [finishButton_ setTitle:ASLocalizedString(@"KDCompanyChoseViewController_complete")forState:UIControlStateNormal];
    }
    else if([todo_.status isEqualToString:@"ignore"])
    {
        [undoView_ setHidden:NO];
        [doneView_ setHidden:YES];
        [separtorView_ setHidden:NO];
        
        UIButton *detailButton_ = (UIButton *)[undoView_ viewWithTag:0x99];
        UIButton *ignoreButton_ = (UIButton *)[undoView_ viewWithTag:0x97];
        UIButton *finishButton_ = (UIButton *)[undoView_ viewWithTag:0x98];
        
        [detailButton_ setHidden:![todo_.fromType isEqual:@"task"]];
        [ignoreButton_ setHidden:YES];
        if (!detailButton_.hidden) {
            
            if ([todo_.taskCommentCount intValue]>0) {
                
                NSString *taskCommentCount = todo_.taskCommentCount;
                int count = [todo_.taskCommentCount intValue];
                if (count >99)
                    taskCommentCount = @"99+";
//                countLabel.text = taskCommentCount;
//                [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss_active"] forState:UIControlStateNormal];
                
                [detailButton_ setTitle:taskCommentCount forState:UIControlStateNormal];
            }
            else
            {
                [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss"] forState:UIControlStateNormal];
                [detailButton_ setTitle:ASLocalizedString(@"KDTodoListCell_disscus")forState:UIControlStateNormal];
            }
            
            
        }
        
        Action *other  = [self getOtherAction];
        if (other)
            [finishButton_ setTitle:other.title forState:UIControlStateNormal];
        
        
        CGSize size = CGSizeMake((self.bounds.size.width-2*KD_TODO_BG_SPACE-1.0f)/3.0, KD_TODO_FOOT_HEIGHT-1);
        
        detailButton_.frame = CGRectMake(size.width, 0, size.width, size.height);
        ignoreButton_.frame = CGRectZero;
        finishButton_.frame = CGRectMake(2*size.width, 0, size.width, size.height);
        
        //完成按钮
        [finishButton_ setImage:[UIImage imageNamed:@"todo_finish"] forState:UIControlStateNormal];
    }
    else if([todo_.status isEqualToString:@"done"])
    {
        [undoView_ setHidden:YES];
        [doneView_ setHidden:NO];
        [separtorView_ setHidden:NO];
        
        UILabel *nameLabel = (UILabel *)[doneView_ viewWithTag:0x99];
        UILabel *dateLabel = (UILabel *)[doneView_ viewWithTag:0x98];
        nameLabel.text = todo_.actName;
        dateLabel.text = [NSDate formatMonthOrDaySince1970WithDate:todo_.actDate];
    }
    else if([todo_ isTask])
    {
        [undoView_ setHidden:NO];
        [doneView_ setHidden:YES];
        [separtorView_ setHidden:YES];
        
        UIButton *detailButton_ = (UIButton *)[undoView_ viewWithTag:0x99];
        UIButton *finishButton_ = (UIButton *)[undoView_ viewWithTag:0x98];
        UIButton *ignoreButton_ = (UIButton *)[undoView_ viewWithTag:0x97];
        
        if ([todo_.taskCommentCount intValue]>0) {
            
            
            NSString *taskCommentCount = todo_.taskCommentCount;
            int count = [todo_.taskCommentCount intValue];
            if (count >99)
                taskCommentCount = @"99+";
//            countLabel.text = taskCommentCount;
//            [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss_active"] forState:UIControlStateNormal];
            
            [detailButton_ setTitle:taskCommentCount forState:UIControlStateNormal];
        }
        else
        {
            [detailButton_ setImage:[UIImage imageNamed:@"todo_discuss"] forState:UIControlStateNormal];
            [detailButton_ setTitle:ASLocalizedString(@"KDTodoListCell_disscus")forState:UIControlStateNormal];
        }
        
        if([todo_.status isEqualToString:@"30"])
            [finishButton_ setTitle:ASLocalizedString(@"KDTodoListCell_flag_success")forState:UIControlStateNormal];
        else
            [finishButton_ setTitle:ASLocalizedString(@"KDTodoListCell_flag_fail")forState:UIControlStateNormal];
        [ignoreButton_ setTitle:ASLocalizedString(@"KDCommentCell_delete")forState:UIControlStateNormal];
        
        [detailButton_ setHidden:NO];
        [finishButton_ setHidden:NO];
        [ignoreButton_ setHidden:NO];
        
        CGSize size = CGSizeMake((self.bounds.size.width-2*KD_TODO_BG_SPACE-1.0f)/3.0, KD_TODO_FOOT_HEIGHT-1);
        
        detailButton_.frame = CGRectMake(0, 0, size.width, size.height);
        ignoreButton_.frame = CGRectMake(2*size.width, 0, size.width, size.height);
        finishButton_.frame = CGRectMake(size.width, 0, size.width, size.height);
        
        //标记完成以及未完成
        [finishButton_ setImage:[UIImage imageNamed:@"task_mark"] forState:UIControlStateNormal];
        
        //删除按钮
        [ignoreButton_ setImage:[UIImage imageNamed:@"task_delete"] forState:UIControlStateNormal];
    }
    
    
    NSString *text = nil;
    if([todo_ isTask])
    {
        text =[[NSString stringWithFormat:@"%@:%@",ASLocalizedString(@"KDCreateTaskViewController_content"),todo_.content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [contentView_ setText:text];
        
        dateLabel_.text = [NSDate formatMonthOrDaySince1970WithDate:todo_.createDate];
        NSLog(@"%@",dateLabel_.text);
        titleView_.text = @"";
        [titleView_ setHidden:NO];
    }
    else
    {
        text =[[NSString stringWithFormat:@"%@:%@",todo_.contentHead,todo_.content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [contentView_ setText:text];
        
        dateLabel_.text = [NSDate formatMonthOrDaySince1970WithDate:todo_.updateDate];
        
        text = [todo_.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [titleView_ setText:text];
        
        [titleView_ setHidden:NO];
    }
    
    
    
    nameLabel_.text = todo_.fromUser.screenName;
    userAvatarView_.avatarDataSource = todo_.fromUser;
}



- (void)didTapOnAvatar:(UIButton *)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:todo_.fromUser sender:sender];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    // Configure the view for the selected state
    if ([todo_.fromType isEqual:@"task"])
        highlightedView_.backgroundColor = highlighted?[UIColor colorWithRed:240/255.f green:241/255.f blue:242/255.f alpha:1.0]:[UIColor clearColor];
}

#pragma mark - set methods
- (void)setTodo:(KDTodo *)todo
{
    if(todo_ != todo){
//        [todo_ release];
        todo_ = todo;// retain];
    }
    
    [self update];
}

+ (CGFloat)messageInteractiveCellHeight:(KDTodo *)todo
{
    UIFont *font = [UIFont systemFontOfSize:17.0];
    CGFloat height = 0.0;

    NSString *text = [NSString stringWithFormat:@"%@:%@",todo.contentHead.length==0 ? ASLocalizedString(@"KDCreateTaskViewController_content"):todo.contentHead,todo.content];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGSize size = CGSizeMake(ScreenFullWidth - 2*KD_TODO_BG_SPACE - 2*KD_TODO_CONTENT_SPACING, CGFLOAT_MAX);
    
    CGSize displaySize = [KDExpressionLabel sizeWithString:text constrainedToSize:size withType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression textAlignment:NSTextAlignmentLeft textColor:MESSAGE_TOPIC_COLOR textFont:font];
    height += displaySize.height;
    
    font = [UIFont systemFontOfSize:16.0];
    text = todo.title;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    displaySize = [KDExpressionLabel sizeWithString:text constrainedToSize:size withType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression textAlignment:NSTextAlignmentLeft textColor:MESSAGE_NAME_COLOR textFont:font];
    
    if([todo isTask])
        height += KD_TODO_BG_TOP + KD_TODO_CONTENT_TOP_MARGIN + KD_TODO_CONTENT_BOTTOM_MARGIN + KD_TODO_FOOT_HEIGHT + CONTENT_MARGIN + AVARTAR_SIZE;
    else
        height += displaySize.height + KD_TODO_BG_TOP + KD_TODO_CONTENT_TOP_MARGIN + KD_TODO_CONTENT_BOTTOM_MARGIN + KD_TODO_FOOT_HEIGHT + CONTENT_MARGIN + AVARTAR_SIZE + TITLE_MARGIN;
    
    return height;
    
}
#pragma mark - KDExpressionLabelDelegate
- (void)expressionLabel:(KDExpressionLabel *)label didClickUrl:(NSString *)urlString
{
    [[KDWeiboAppDelegate getAppDelegate] openWebView:urlString];
}
- (void)expressionLabel:(KDExpressionLabel *)label didClickUserWithName:(NSString *)userName{}
- (void)expressionLabel:(KDExpressionLabel *)label didClickTopicWithName:(NSString *)topicName{}
@end