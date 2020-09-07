//
//  KWICommentCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWICommentCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

#import "NSDate+RelativeTime.h"
#import "NSObject+KWDataExt.h"
#import "UITextView+SizeUtils.h"
#import "NSError+KWIExt.h"

#import "KWEngine.h"
#import "KWIPeopleVCtrl.h"
#import "KWIStatusContent.h"
#import "KWIAvatarV.h"

#import "KDCommentStatus.h"
#import "KDCommonHeader.h"
#import "iToast.h"
@interface KWICommentCell ()

@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UILabel *inReplyToV;
@property (retain, nonatomic) IBOutlet UIView *inrCtnPh;
@property (retain, nonatomic) KWIStatusContent *inrCtn;
@property (retain, nonatomic) IBOutlet UIButton *replyBtn;
@property (retain, nonatomic) IBOutlet UIButton *delBtn;

@end

@implementation KWICommentCell

@synthesize data = _data;

@synthesize avatarV = _avatarV;
@synthesize usernameV = _usernameV;
@synthesize inReplyToV = _inReplyToV;
@synthesize inrCtnPh = _inrCtnPh;
@synthesize inrCtn = _inrCtn;
@synthesize replyBtn = _replyBtn;
@synthesize delBtn = _delBtn;
@synthesize status = status_;

+ (KWICommentCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:self.description bundle:nil] autorelease];
    KWICommentCell *cell = (KWICommentCell *)tmpVCtrl.view; 
    
    //cell.avatarV.layer.cornerRadius = 4;
    //cell.avatarV.layer.masksToBounds = YES;
    
    return cell;
}

- (void)dealloc {    
    [_avatarV release];
    [_usernameV release];    
    [_inReplyToV release];
    [_inrCtnPh release];
    [_inrCtn release];
    [_replyBtn release];
    
    [_data release];
    
    [_delBtn release];
    [super dealloc];
}


+(CGFloat)optimalHeightByConstrainedWidth:(CGFloat)width comment:(KDCommentStatus*)comment {
    CGFloat height=0;
    height+=36.0f;
    height+=[KWIStatusContent optimalHeightByConstrainedWidth:width - 94 commentStatus:comment];
    return height;
}
#pragma mark -
- (void)setData:(KDCommentStatus *)data
{
    [_data release];
    _data = [data retain];
    
    //[self.avatarV setImageWithURL:[NSURL URLWithString:data.author.profile_image_url]];
    
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:data.author.thumbnailImageURL size:40];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    self.usernameV.text = _data.author.screenName;
    [self.usernameV sizeToFit];
    
    [avatarV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    [self.usernameV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    self.inReplyToV.hidden = YES;
//    if (_data.replyScreenName) {
//        CGRect inReplyFrame = self.inReplyToV.frame;
//        inReplyFrame.origin.x = self.usernameV.frame.origin.x + [_data.author.screenName sizeWithFont:[UIFont systemFontOfSize:17]].width + 10;
//        self.inReplyToV.frame = inReplyFrame;
//        
//        self.inReplyToV.text = [NSString stringWithFormat:@"回复 %@", _data.replyScreenName];
//    } else {
//        self.inReplyToV.hidden = YES;
//    }
    
//    KWEngine *api = [KWEngine sharedEngine];
//    if ([data.author.id_ isEqualToString:api.user.id_] || [data.status.author.id_ isEqualToString:api.user.id_]) {
//        self.delBtn.hidden = NO;
//    }
    
    if ([[KDManagerContext globalManagerContext].userManager isCurrentUserId:self.data.author.userId]) {
        self.delBtn.hidden = NO;
    }
    
    self.inrCtn = [KWIStatusContent viewForComment:_data frame:self.inrCtnPh.frame contentFontSize:14 textInteractionEnabled:YES];
    [self.contentView insertSubview:self.inrCtn atIndex:0];    
    
    [self.inrCtnPh removeFromSuperview];
    self.inrCtnPh = nil;
    CGRect frame = self.frame;
    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
    self.frame = frame;
  
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    CGRect frame = self.frame;
//    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
//    self.frame = frame;
//}
- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (IBAction)_handleReplyBtnTapped:(id)sender 
{
    NSDictionary *info = @{@"comment":self.data,@"status":self.status};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWComment.addComment" 
                                                        object:self 
                                                      userInfo:info];
}

- (IBAction)_onDelBtnTapped:(id)sender 
{
    NSString *msg;
    if (10 < self.data.text.length) {
        msg = [NSString stringWithFormat:@"%@...", [self.data.text substringWithRange:NSMakeRange(0, 10)]];
    } else {
        msg = self.data.text;
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
            self.delBtn.enabled = NO;
//            KWEngine *api = [KWEngine sharedEngine];
//            [api post:[NSString stringWithFormat:@"statuses/comments/destory/%@.json", self.data.id_]
//               params:[NSDictionary dictionaryWithObject:self.data.id_ forKey:@"id"]
//            onSuccess:^(NSDictionary *dict) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"KWComment.remove" object:self.data];
//                self.delBtn.enabled = YES;
//            } 
//              onError:^(NSError *error) {
//                  [error KWIGeneralProcess];
//                  self.delBtn.enabled = YES;
//              }];
            
            
           // commentDestory
            
            
            KDQuery *query = [KDQuery queryWithName:@"commentId" value:self.data.statusId];
            [query setProperty:self.data.statusId forKey:@"commentId"];
            
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                if([response isValidResponse]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWComment.remove" object:self.data];
                        self.delBtn.enabled = YES;
                } else {
                    if (![response isCancelled]) {
                        [[iToast makeText:@"删除失败"] show];
                        self.delBtn.enabled = YES;
                    }
                }
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/statuses/:commentDestory" query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
        break;
    }
}


@end
