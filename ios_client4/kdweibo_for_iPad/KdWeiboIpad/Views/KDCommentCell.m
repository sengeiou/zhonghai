//
//  KDCommentCell.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-8.
//
//

#import "KDCommentCell.h"
#import "KWIAvatarV.h"
#import "KDStatusView.h"
#import "KDManagerContext.h"
#import "iToast.h"
#import "KWIPeopleVCtrl.h"

@implementation KDCommentCell {
    
    KWIAvatarV *avatarView_;
    
    KDStatusView *statusView_;
    UIButton *deleteBtn_;
    UIButton *commentBtn_;
    UIImageView *separatorImageView_;
}
@synthesize comment = comment_;

+(KDCommentCell *)cell {
    KDCommentCell *cell = [[KDCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return [cell autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        avatarView_ = [[KWIAvatarV viewForUrl:nil size:40] retain];
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
        [avatarView_ addGestureRecognizer:rgzr];
        [rgzr release];
        
        [self addSubview:avatarView_];
        
        deleteBtn_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [deleteBtn_ setBackgroundImage:[UIImage imageNamed:@"delBtn.png"] forState:UIControlStateNormal];
        [deleteBtn_ addTarget:self action:@selector(deleteBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn_ sizeToFit];
        [self addSubview:deleteBtn_];
        
        commentBtn_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [commentBtn_ setBackgroundImage:[UIImage imageNamed:@"replyBtn.png"] forState:UIControlStateNormal];
        [commentBtn_ addTarget:self action:@selector(commentBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [commentBtn_ sizeToFit];
        [self addSubview:commentBtn_];
        
        separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentCellBorder.png"]];
        [self addSubview:separatorImageView_];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = avatarView_.frame;
    frame.origin.x = 20;
    frame.origin.y = 20;
    avatarView_.frame = frame;
    
    frame = statusView_.frame;
    frame.origin.x = CGRectGetMaxX(avatarView_.frame) +15;
    frame.origin.y = 10;
    statusView_.frame = frame;
    
    frame = commentBtn_.frame;
    frame.origin.x = self.bounds.size.width-frame.size.width - 14;
    frame.origin.y = self.bounds.size.height-frame.size.height - 10;
    commentBtn_.frame = frame;
    
    if (!deleteBtn_.hidden) {
        frame = deleteBtn_.frame;
        frame.origin.x = CGRectGetMinX(commentBtn_.frame)-24-CGRectGetWidth(frame);
        frame.origin.y = CGRectGetMinY(commentBtn_.frame);
        deleteBtn_.frame = frame;
    }
     frame = self.bounds;
   frame.origin.y = CGRectGetHeight(frame) - 1;
   frame.size.height = 1;
   separatorImageView_.frame = frame;

}
- (void)setComment:(KDCommentStatus *)comment {
    if (comment_ == comment) {
        return;
    }
    [comment_ release];
    comment_ = [comment retain];
    
    [avatarView_ downloadImageWithUrl:comment.author.thumbnailImageURL];
   
    KDLayouter *layouter = [KDCommentCellLayouter layouter:comment constrainedWidth:0];
    statusView_ = [[layouter statusView] retain];
    [self addSubview:statusView_];
    
    if ([[KDManagerContext globalManagerContext].userManager isCurrentUserId:comment.author.userId]) {
        deleteBtn_.hidden = NO;
    }
    [self bringSubviewToFront:commentBtn_];
    [self bringSubviewToFront:deleteBtn_];
    
}

- (void)deleteBtnTapped:(id)sender {
    NSString *msg;
    if (10 < self.comment.text.length) {
        msg = [NSString stringWithFormat:@"%@...", [self.comment.text substringWithRange:NSMakeRange(0, 10)]];
    } else {
        msg = self.comment.text;
    }
    
    UIAlertView *alertV = [[[UIAlertView alloc] initWithTitle:@"删除回复"
                                                      message:[NSString stringWithFormat:@"确认删除“%@”吗？", msg]
                                                     delegate:self
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"删除", nil] autorelease];
    [alertV show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
           deleteBtn_.enabled = NO;
            KDQuery *query = [KDQuery queryWithName:@"commentId" value:self.comment.statusId];
            [query setProperty:self.comment.statusId forKey:@"commentId"];
            
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                if([response isValidResponse]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWComment.remove" object:self.comment];
                    deleteBtn_.enabled = YES;
                } else {
                    if (![response isCancelled]) {
                        [[iToast makeText:@"删除失败"] show];
                         deleteBtn_ .enabled = YES;
                    }
                }
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:commentDestory" query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
            break;
    }
}

- (void)commentBtnTapped:(id)sender {
    NSDictionary *info = @{@"comment":self.comment};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWComment.addComment"
                                                        object:self
                                                      userInfo:info];
    
}

- (void)avatarTapped:(UIGestureRecognizer *)grzr {
    
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.comment.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (void)dealloc {
    KD_RELEASE_SAFELY(statusView_);
    KD_RELEASE_SAFELY(avatarView_);
    KD_RELEASE_SAFELY(deleteBtn_);
    KD_RELEASE_SAFELY(commentBtn_);
    KD_RELEASE_SAFELY(separatorImageView_);
    KD_RELEASE_SAFELY(comment_);
    [super dealloc];
}

@end
