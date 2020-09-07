//
//  KDUserPortraitGroupView.m
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUserPortraitGroupView.h"
#import "UIViewAdditions.h"

#define CONTENT_INTERVAL_MARGIN 10.f
#define USER_AVATAR_SIZE   48.f

@interface KDUserPortraitGroupView()
@property (nonatomic, retain) NSMutableArray *avatarViews;
@end


@implementation KDUserPortraitGroupView
@synthesize users = users_;
@synthesize avatarViews = avatarViews_;
@synthesize delegate = delegate_;
@synthesize editable = editable_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        editable_ = YES;
        avatarLabels_ = [NSMutableArray array] ;//retain];
                         avatarViews_ = [NSMutableArray array];// retain];
                                         users_ = [NSMutableArray array] ;//retain];
                                                   selectedUsers_ = [NSMutableArray array] ;//retain];
        
//        UIImage *bgImg = [UIImage imageNamed:@"todo_bg"];
//        bgImg = [bgImg stretchableImageWithLeftCapWidth:bgImg.size.width/2.0f topCapHeight:bgImg.size.height/2.0f];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.frame];// autorelease];
        backgroundView_.userInteractionEnabled = YES;
        backgroundView_.backgroundColor = [UIColor kdBackgroundColor2];
        [self addSubview:backgroundView_];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float space = (self.frame.size.width - 4*USER_AVATAR_SIZE)/5;
    CGRect rect = CGRectMake(space, CONTENT_INTERVAL_MARGIN, USER_AVATAR_SIZE, USER_AVATAR_SIZE);
    
    for (int i=0;i<[users_ count];i++) {
        
        KDAvatarView *avatarView = [avatarViews_ objectAtIndex:i];
        avatarView.frame = rect;
        avatarView.layer.cornerRadius = 6;
        avatarView.layer.masksToBounds = YES;
        
        UIImageView *finishedView = (UIImageView *)[avatarView viewWithTag:0x99];
        finishedView.frame = CGRectMake(rect.size.width - finishedView.image.size.width, rect.size.height-finishedView.image.size.height, finishedView.image.size.width, finishedView.image.size.height);
        
        rect.origin.y += USER_AVATAR_SIZE +5.0;
        rect.size.height = 15.f;
        
        UILabel *avatarLabel = [avatarLabels_ objectAtIndex:i];
        avatarLabel.frame = rect;
        
        if ((i+1)%4 == 0)
        {
            rect.origin.x = space;
            rect.origin.y += rect.size.height +10.0f;
            rect.size = CGSizeMake(USER_AVATAR_SIZE, USER_AVATAR_SIZE);
        }
        else
        {
            rect.origin.x += USER_AVATAR_SIZE + space;
            rect.origin.y = CGRectGetMinY(avatarView.frame);
            rect.size = CGSizeMake(USER_AVATAR_SIZE, USER_AVATAR_SIZE);
        }
        
    }
    
    addExecuteBtn_.frame = rect;
    CGFloat height = CGRectGetMaxY(rect) + 30.f;
    
    rect = self.frame;
    rect.size.height = height;
    
    self.frame = rect;
    backgroundView_.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
}
 - (void)setUsers:(NSArray *)users
{
    if (users_ != users) {
        
//        [users_ release];
        users_ = nil;
        
        users_ = [NSMutableArray arrayWithArray:users] ;//retain];
        
        [self resetSelectedUsers];
        
        [self removeAllSubViews];
        
        [self initSubViews];
        
    }
}
- (void)setEditable:(BOOL)editable
{
    if (editable != editable_) {
        
        addExecuteBtn_.hidden = !editable;
        editable_ = editable;
        
        for (UIView *v in self.subviews)
        {
            if ([v isKindOfClass:[KDUserAvatarView class]]) {
                
                ((KDUserAvatarView *)v).enabled = editable_;
                
            }
        }
    }
}
- (void)initSubViews
{
    for (int i =0;i<[users_ count];i++) {
        
        KDUser *user = [users_ objectAtIndex:i];
        if (![user isKindOfClass:[KDUser class]])
            user = nil;
        
        KDUserAvatarView *avatarView = [KDUserAvatarView avatarView];
        [avatarView addTarget:self action:@selector(userClicked:) forControlEvents:UIControlEventTouchUpInside];
        avatarView.tag = 10000+i;
        avatarView.avatarDataSource = user;
        [self addSubview:avatarView];
        [avatarViews_ addObject:avatarView];
        
        avatarView.enabled = editable_;
        
        UIImage *finishedImage = [UIImage imageNamed:@"task_edit_finish"];
        UIImageView *finishedImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        finishedImageView.image = finishedImage;
        finishedImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [avatarView addSubview:finishedImageView];
//        [finishedImageView release];
        
        finishedImageView.tag = 0x99;
        finishedImageView.hidden = YES;//![((NSNumber *)[selectedUsers_ objectAtIndex:i]) intValue];
        
        UILabel *avatarLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        avatarLabel.backgroundColor = [UIColor clearColor];
        avatarLabel.textColor = MESSAGE_TOPIC_COLOR;
        avatarLabel.font = [UIFont systemFontOfSize:14.0f];
        avatarLabel.text = user.username;
        avatarLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:avatarLabel];
//        [avatarLabel release];
        
        [avatarLabels_ addObject:avatarLabel];
        
    }
    
    addExecuteBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [addExecuteBtn_ addTarget:self action:@selector(addNewUser:) forControlEvents:UIControlEventTouchUpInside];
    addExecuteBtn_.frame = CGRectZero;
    [addExecuteBtn_ setBackgroundImage:[UIImage imageNamed:@"message_tip_add"] forState:UIControlStateNormal];
    [self addSubview:addExecuteBtn_];
    
    addExecuteBtn_.hidden = !editable_;
}
- (void)removeAllSubViews
{
    for (UIView *v in self.subviews)
    {
        if (v ==backgroundView_)
            continue;
        [v removeFromSuperview];
    }
}
- (void)resetSelectedUsers
{
    if (!selectedUsers_)
        selectedUsers_ = [NSMutableArray array];// retain];
    
    [selectedUsers_ removeAllObjects];
    [avatarViews_ removeAllObjects];
    [avatarLabels_ removeAllObjects];
    
    for (int i =0; i<[users_ count]; i++) {
        [selectedUsers_ addObject:[NSNumber numberWithInt:1]];
    }
}
- (NSMutableArray *)getCurrentUsers
{
    NSMutableArray *users = [NSMutableArray array];
    
    for (int i=0; i<[selectedUsers_ count]; i++) {
        
        int u = [[selectedUsers_ objectAtIndex:i] intValue];
        if (u == 1)
            [users addObject:[users_ objectAtIndex:i]];
    }
    return users;
}
- (void)addNewUser:(id)sender
{
    if (delegate_) {
        if ([delegate_ respondsToSelector:@selector(editorContactsWithUsers:)]) {
            [delegate_ editorContactsWithUsers:[self getCurrentUsers]];
        }
    }
}
- (void)userClicked:(id)sender
{
    /*
    KDAvatarView *avatarView = (KDAvatarView *)sender;
    int tag = avatarView.tag;
    [selectedUsers_ replaceObjectAtIndex:tag withObject:[NSNumber numberWithInt:![((NSNumber *)[selectedUsers_ objectAtIndex:tag]) intValue]]];
    UIImageView *finishedView = (UIImageView *)[avatarView viewWithTag:0x99];
    finishedView.hidden = ![((NSNumber *)[selectedUsers_ objectAtIndex:tag]) intValue];
     */
}
+ (float)heightForUserPortraitGroupView:(NSArray *)users canbeEdit:(BOOL)editable
{
    int count = (int)[users count];
    if (editable)
        count ++;
    
    int rows = (count - 1)/4 + 1;
    
    
    return rows*USER_AVATAR_SIZE +rows*30.0f +2*CONTENT_INTERVAL_MARGIN;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)dealloc
{
    //KD_RELEASE_SAFELY(selectedUsers_);
    //KD_RELEASE_SAFELY(avatarLabels_);
    //KD_RELEASE_SAFELY(avatarViews_);
    //KD_RELEASE_SAFELY(users_);
    //[super dealloc];
}
@end
