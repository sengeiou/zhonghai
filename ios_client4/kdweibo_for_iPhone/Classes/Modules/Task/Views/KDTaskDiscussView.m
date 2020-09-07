//
//  KDTaskDiscussView.m
//  kdweibo
//
//  Created by bird on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskDiscussView.h"
#import "KDCommentStatus.h"
#import "ChatBubbleCell.h"
#import "UIView+Blur.h"
#import "KDTaskHeaderView.h"
#import "KDDefaultViewControllerContext.h"
#import "KDVideoPlayerController.h"

#define KD_DM_THREAD_LOAD_MORE_BTN_TAG  0x6

@interface KDTaskDiscussView()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ChatBubbleCellDelegate, KDThumbnailViewDelegate2, KDThumbnailViewDelegate>
@end
@implementation KDTaskDiscussView

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubViews];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<KDTaskDiscussViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegate;
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews
{
    self.backgroundColor = [UIColor clearColor];
    
    CGRect frame = self.bounds;
    frame.size.height -= 44.0 + KD_DM_CHAT_INPUT_VIEW_HEIGHT;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        frame.size.height -= 20.f;
    }
	UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
//    tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, KD_DM_CHAT_INPUT_VIEW_HEIGHT, 0.0f);
    tableView_ = tableView;// retain];
    tableView_.clipsToBounds = NO;
    
	tableView.delegate = self;
	tableView.dataSource = self;
    
    tableView.backgroundColor = [UIColor kdBackgroundColor1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
	[self addSubview:tableView];
    

}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(tableView_);
    //[super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - 
#pragma mark - NO_DATS_TIPS methods
- (void) setBackgroud:(BOOL)isLoad {
    
    if (!isLoad) {
        backgroundView_.hidden = YES;
        return;
    }
    
    if (!backgroundView_) {
        
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        [backgroundView_ setUserInteractionEnabled:YES];
        backgroundView_.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 155, self.bounds.size.width,25.0f)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0f];
        label.textColor = MESSAGE_NAME_COLOR;
        label.text = ASLocalizedString(@"NO_DATA_TASK_DISSCUSS_ToDo");
        
        [backgroundView_ addSubview:label];
        
        [tableView_ addSubview:backgroundView_];
    }
    backgroundView_.hidden = NO;
    
}

#pragma mark - 
#pragma mark - KDDMChatInputView methods

- (void)changeTableViewHeightToFitDMChatInputView:(KDDMChatInputView *)dmChatInputView headerView:(KDTaskHeaderView *)headerView animated:(BOOL)animated
{
    CGFloat visibleHeight = dmChatInputView.frame.origin.y - [dmChatInputView extendViewHeight] - CGRectGetHeight(headerView.frame) - kd_StatusBarAndNaviHeight - kd_BottomSafeAreaHeight;
    CGSize contentSize = tableView_.contentSize;
    CGFloat originY = tableView_.frame.origin.y;
    CGFloat nY = CGRectGetHeight(headerView.frame);
    
    if(contentSize.height < visibleHeight) {
        nY = CGRectGetHeight(headerView.frame);
    }else if(contentSize.height < tableView_.frame.size.height) {
        nY = visibleHeight - contentSize.height + nY;
    }else {
        nY = visibleHeight - tableView_.frame.size.height + nY ;
    }
    
    nY = MIN(nY, CGRectGetHeight(headerView.frame));
    
    if(originY != nY) {
        [UIView animateWithDuration:0.25f animations:^(void) {
            CGRect f = tableView_.frame;
            
            f.origin.y = nY;
            
            tableView_.frame = f;
        }];
    }

}
#pragma mark -
#pragma mark - HeadView methods
- (void)moreMessagesButtonVisible:(BOOL)visible {
    
    if(tableView_.tableHeaderView == nil){
        CGRect rect = CGRectMake(0.0, 0.0, tableView_.bounds.size.width, 48.0);
        UIView *containerView = [[UIView alloc] initWithFrame:rect];
        
        // more button
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake((rect.size.width - 240.0) * 0.5, (rect.size.height - 32.0) * 0.5, 240.0, 32.0);
        moreBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        moreBtn.tag = KD_DM_THREAD_LOAD_MORE_BTN_TAG;
        
        [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [moreBtn setTitle:NSLocalizedString(@"DM_THREAD_LOAD_MORE", @"") forState:UIControlStateNormal];
        
        UIImage *bgImage = [UIImage imageNamed:@"dm_thread_more_btn_bg.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:0.5*bgImage.size.width topCapHeight:0.5*bgImage.size.height];
        [moreBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        
        [moreBtn addTarget:self action:@selector(loadOlderMessages) forControlEvents:UIControlEventTouchUpInside];
        
        [containerView addSubview:moreBtn];
        
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tableView_.tableHeaderView = containerView;
//        [containerView release];
    }
    tableView_.tableHeaderView.hidden = !visible;
    
    [self showloading:NO];
}

- (void)showloading:(BOOL)loading {
    // if more messages button not exists now, return directly.
    if(tableView_.tableHeaderView == nil) return;
    
    BOOL enabled = NO;
    NSString *btnTitle = nil;
    if(loading){
        btnTitle = ASLocalizedString(@"RecommendViewController_Load");
        
    }else {
        enabled = YES;
        btnTitle = NSLocalizedString(@"COMMENT_THREAD_LOAD_MORE", @"");
    }
    
    UIButton *moreBtn = (UIButton *)[tableView_.tableHeaderView viewWithTag:KD_DM_THREAD_LOAD_MORE_BTN_TAG];
    [moreBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    moreBtn.enabled = enabled;
}

#pragma mark - 
#pragma mark - User Action methods
- (void) loadOlderMessages
{
    [self showloading:YES];
    [delegate_ getCommentsFromNetWork];
}
- (void) didTapOnThumbnailView:(KDThumbnailView *)thumbnailView {

    if (delegate_) {
        
        [delegate_ setImageDataSource:thumbnailView.imageDataSource];
        
        [delegate_ thumbnailViewDidTaped:[NSArray arrayWithObject:thumbnailView.thumbnailView]];
    }
}

- (void)didTapOnAttachmentView:(UIButton *)btn {
    CGPoint point = [btn convertPoint:btn.frame.origin toView:tableView_];
    NSIndexPath *indexPath = [tableView_ indexPathForRowAtPoint:point];
    if(indexPath != nil){
        KDStatus *status = [[delegate_ getMessages] objectAtIndex:indexPath.row];
   
        [delegate_ attachmentViewWithSource:status];
    }
}
#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([delegate_ getMessages] != nil) ? [[delegate_ getMessages] count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    KDStatus<ChatBubbleCellDataSource> *current = [[delegate_ getMessages] objectAtIndex:index];
    
    NSTimeInterval interval = -1;
    if (index >= 1) {
        KDStatus *previous = nil;
        
        for(NSInteger i = index - 1; i >= 0 ; i--) {
            KDStatus *msg = [[delegate_ getMessages] objectAtIndex:i];
            if([[msg propertyForKey:@"kddmmessage_is_need_stamp"] boolValue]) {
                previous = msg;
                break;
            }
        }
        
        if(previous)
            interval = [current.createdAt timeIntervalSince1970] - [previous.createdAt timeIntervalSince1970];
    }
    
    return [ChatBubbleCell directMessageHeightInCell:current interval:interval];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KDStatus<ChatBubbleCellDataSource> *msg = [[delegate_ getMessages] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"ChatBubbleCell";
    //    ChatBubbleCell *cell = (ChatBubbleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ChatBubbleCell *cell = nil;
    if (cell == nil) {
        cell = [[ChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.delegate = self;
        
        cell.detailsView.thumbnailView2.delegate = self;
        cell.detailsView.thumbnailView.delegate = self;
        
        [cell.detailsView.thumbnailView addTarget:self action:@selector(didTapOnThumbnailView:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.detailsView.attachmentIndicatorView.indicatorButton addTarget:self action:@selector(didTapOnAttachmentView:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.message = msg;
    cell.detailsView.thumbnailView2.status = msg;
    if(!tableView.dragging && !tableView.decelerating){
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        
        // load the thumbnail if need
        KDThumbnailView2 *thumbnailView = cell.detailsView.thumbnailView2;
        if(!thumbnailView.hasThumbnail && !thumbnailView.loadThumbnail){
//            thumbnailView.status = msg;
            [thumbnailView setLoadThumbnail:YES];
        }
        
        if(!cell.detailsView.thumbnailView.hasThumbnail && !cell.detailsView.thumbnailView.loadThumbnail){
            [cell.detailsView.thumbnailView setLoadThumbnail:YES];
        }
    }
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if(menuController.isMenuVisible){
        [menuController setMenuVisible:NO];
    }
}

- (void)loadImageSourceIfNeed {
    [KDAvatarView loadImageSourceForTableView:tableView_];
    
    NSArray *cells = [tableView_ visibleCells];
	if(cells != nil){
        for(ChatBubbleCell *cell in cells){
            
            KDThumbnailView2 *thumbnailView = cell.detailsView.thumbnailView2;
            if(!thumbnailView.hasThumbnail && !thumbnailView.loadThumbnail){
                [thumbnailView setLoadThumbnail:YES];
            }
            
            if(!cell.detailsView.thumbnailView.hasThumbnail && !cell.detailsView.thumbnailView.loadThumbnail){
                [cell.detailsView.thumbnailView setLoadThumbnail:YES];
            }

        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self loadImageSourceIfNeed];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageSourceIfNeed];
}
#pragma mark - CahtBubbleCellDelegate Methods
- (void)didTapWarnningImageInChatBubbleCell:(ChatBubbleCell *)cell {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel") destructiveButtonTitle:nil otherButtonTitles:ASLocalizedString(@"DM_AUDIO_RESEND"), ASLocalizedString(@"KDAttachmentMenuCell_del"), nil];
    sheet.destructiveButtonIndex = 0x01;
    curBubbleCell_ = cell;
    [sheet showInView:self];
//    [sheet release];
}
#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(curBubbleCell_) {
        KDCommentStatus *msg = [(ChatBubbleCell *)curBubbleCell_ message];
        
        if(msg) {
            if(0x00 == buttonIndex) {
                //重新发送
                
                KDCommentState state = KDCommentStateSending|KDCommentStateUnsend;
                msg.messageState = state;
                [tableView_ reloadData];
                
                if ([delegate_ respondsToSelector:@selector(postCommentToNetWork:)]) {
                    [delegate_ postCommentToNetWork:msg];
                }
                
            }else if(0x01 == buttonIndex)
            {
                [[delegate_ getMessages] removeObject:msg];
                [tableView_ reloadData];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    curBubbleCell_ = nil;
    UIWindow *keyWindow = [KDWeiboAppDelegate getAppDelegate].window;
    [keyWindow makeKeyAndVisible];
    
}
#pragma mark -
#pragma mark KDThumbnailView delegate method
- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView userInfo:(id)userInfo
{
    KDStatus *status = thumbnailView.status;
    if ([status hasVideo]) {
        NSArray *attachments = status.attachments;

        UIViewController *rootViewController =  [[[KDWeiboAppDelegate getAppDelegate] window] rootViewController];

        KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
        videoController.attachments = attachments;
        videoController.dataId = status.statusId;
        
        [rootViewController presentViewController:videoController animated:YES completion:nil];
//        [videoController release];
    }
}
- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail {
    
    KDCompositeImageSource *compositeImageSource = thumbnailView.imageDataSource;
    KDDMMessage *message = compositeImageSource.entity;
    if (message != nil) {
        NSUInteger index = [[delegate_ getMessages] indexOfObject:message];
        if(NSNotFound != index){
            NSArray *visibleRows = [tableView_ indexPathsForVisibleRows];
            NSIndexPath *target = [NSIndexPath indexPathForRow:index inSection:0x00];
            
            BOOL found = NO;
            for(NSIndexPath *indexPath in visibleRows){
                if([indexPath compare:target] == NSOrderedSame){
                    found = YES;
                    break;
                }
            }
            
            if(found){
                [tableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:target] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}
#pragma mark - 
#pragma mark - 外部调用
- (void)hideNoTips
{
    [self setBackgroud:NO];
}
- (void)olderMessageLoaded
{
    CGPoint offset = CGPointMake(0.0, tableView_.contentSize.height);
    [self reloadData];
    offset.y = tableView_.contentSize.height - offset.y;
    [tableView_ setContentOffset:offset];

}
- (void)reloadData
{
    if ([[delegate_ getMessages] count] ==0)
        [self setBackgroud:YES];
    else
        [self setBackgroud:NO];
    
    [tableView_ reloadData];
}
- (void) scrollToBottom {
    if ([delegate_ getMessages] != nil && [[delegate_ getMessages] count] > 1) {
        NSUInteger index = [[delegate_ getMessages] count] - 1;
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0x00];
        [tableView_ scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
- (void)newMessageInsertedAtIndexPaths:(NSArray *)paths
{
    if ([paths count]==0)
        return;
/*
    [tableView_ beginUpdates];
    [tableView_ insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    [tableView_ endUpdates];
 */
        
    [tableView_ reloadData];
    [tableView_ scrollToRowAtIndexPath:[paths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:NO];

}
- (void)setTableOffset:(CGPoint)point
{
    CGRect rect = tableView_.frame;
    rect.origin.y += point.y;
    rect.size.height -= point.y;
    
    tableView_.frame = rect;
    
    /*
    UIEdgeInsets insets = tableView_.contentInset;
    insets.top = point.y;
    
    [tableView_ setContentInset:insets];
     */
}
@end
