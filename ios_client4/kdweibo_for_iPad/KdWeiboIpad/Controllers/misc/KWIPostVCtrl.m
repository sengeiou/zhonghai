//
//  KWIPostVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIPostVCtrl.h"

#import "NSObject+KWDataExt.h"
#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"
#import "iToast.h"
#import "SBJson.h"
#import "UIImage+Resize.h"
#import "NSCharacterSet+Emoji.h"
#import "KDActivityIndicatorView.h"


#import "KWIRootVCtrl.h"
#import "KWIMentionSelectorVCtrl.h"
#import "KWIRootVCtrl.h"


#import"KDCommonHeader.h"
#import "KDDraft.h"
#import "KDGroupStatus.h"
#import "KDCommentStatus.h"
#import "KDGroup.h"

@interface KWIPostVCtrl () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextViewDelegate>
{
    KDActivityIndicatorView *activityView_;
}

@property (retain, nonatomic) IBOutlet UIView *contentV;
@property (retain, nonatomic) IBOutlet UITextView *txtV;
@property (retain, nonatomic) IBOutlet UIView *maskV;
@property (retain, nonatomic) IBOutlet UIView *quotedV;
@property (retain, nonatomic) IBOutlet UITextView *qTxtV;

@property (retain, nonatomic) IBOutlet UIView *toolbarV;
@property (retain, nonatomic) IBOutlet UIButton *imgBtn;
@property (retain, nonatomic) IBOutlet UIButton *galleryBtn;
@property (retain, nonatomic) IBOutlet UIButton *mentionBtn;
@property (retain, nonatomic) IBOutlet UIButton *topicBtn;
@property (retain, nonatomic) IBOutlet UIButton *emotionBtn;
@property (retain, nonatomic) NSArray *btns;

@property (retain, nonatomic) IBOutlet UILabel *lbStatus;
@property (retain, nonatomic) IBOutlet UILabel *lbStatusWithGroup;
@property (retain, nonatomic) IBOutlet UILabel *lbComment;
@property (retain, nonatomic) IBOutlet UILabel *lbRepost;
@property (retain, nonatomic) IBOutlet UIButton *postStatusBtn;
@property (retain, nonatomic) IBOutlet UIButton *postWithGroupBtn;
@property (retain, nonatomic) IBOutlet UIButton *postCommentBtn;
@property (retain, nonatomic) IBOutlet UIButton *postRepostBtn;



@property (retain, nonatomic) UIImage *img;
//@property (retain, nonatomic) UIImagePickerController *imgPkrVCtrl;
@property (retain, nonatomic) UIImagePickerController *cameraVCtrl;
@property (retain, nonatomic) UIImagePickerController *galleryVCtrl;
@property (retain, nonatomic) UIPopoverController *imgPkrCtnVCtrl;

@property (retain, nonatomic) IBOutlet UIView *thumbCtnV;
@property (retain, nonatomic) IBOutlet UIImageView *thumbV;
@property (retain, nonatomic) IBOutlet UILabel *textCountV;

@property (retain, nonatomic, readonly) KWIMentionSelectorVCtrl *followingsVCtrl;

@property (retain, nonatomic) NSString *curObjId;

@property (nonatomic, retain)KDDraft *draft;

@end

@implementation KWIPostVCtrl
{
    CGRect _ctnFrameDef;
    CGRect _ctnFrameOut;
    CGRect _txtFrameDef;
    CGRect _txtFrameQ;
    
    NSArray *_ctrlBtns;
    
    UIPopoverController *_poper;
    //KWIMentionSelectorVCtrl *_followingsVCtrl;
    
    UIButton *_curSendBtn;
    IBOutlet UIButton *_closeBtn;
    //NSString *_curObjectId;
    
    //__block KWGroup *_group;
    
    NSUInteger _lastKbTop;
}

@synthesize contentV;
@synthesize txtV;
@synthesize maskV;
@synthesize quotedV;
@synthesize qTxtV;
@synthesize imgBtn;
@synthesize galleryBtn;
@synthesize mentionBtn;
@synthesize topicBtn;
@synthesize emotionBtn;
@synthesize toolbarV;
@synthesize lbStatus;
@synthesize lbStatusWithGroup;
@synthesize lbComment;
@synthesize postStatusBtn;
@synthesize postWithGroupBtn;
@synthesize postCommentBtn;
@synthesize postRepostBtn;
@synthesize lbRepost;

@synthesize img = _img;
@synthesize btns = _btns;
//@synthesize imgPkrVCtrl = _imgPkrVCtrl;
@synthesize imgPkrCtnVCtrl = _imgPkrCtnVCtrl;
@synthesize cameraVCtrl = _cameraVCtrl;
@synthesize galleryVCtrl = _galleryVCtrl;
@synthesize thumbCtnV;
@synthesize thumbV;
@synthesize textCountV;
@synthesize followingsVCtrl = _followingsVCtrl;
@synthesize curObjId = _curObjId;
@synthesize draft = draft_;

+ (KWIPostVCtrl *)vctrl
{
    return [[[self alloc] initWithNibName:self.description bundle:nil] autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        
        BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
        if (isKeyboardChangeKeyAvailable) {
            [dnc addObserver:self selector:@selector(_onKeyboardShown:) name:UIKeyboardDidChangeFrameNotification object:nil];
        }
        
         [dnc addObserver:self selector:@selector(_onFollowingsSelected:) name:@"KWISimpleFollowingsSelected" object:self.followingsVCtrl];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self _adjustFramesForCurrentOrientation];
    
    _txtFrameDef = self.txtV.frame;
    _txtFrameQ = _txtFrameDef;
    _txtFrameQ.size.height -= 55;
    
    self.txtV.delegate = self;
    
    //[self.maskV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_maskTapped)] autorelease]];
    
    self.btns = [NSArray arrayWithObjects:self.imgBtn, self.galleryBtn, self.mentionBtn, self.topicBtn, self.emotionBtn, nil];
    
      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.enabled = YES;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.enabled = YES;
    }
    
    [self textViewDidChange:nil];
}

- (void)viewDidUnload
{
    BOOL isKeyboardChangeKeyAvailable = (NULL != &UIKeyboardDidChangeFrameNotification);
    if (isKeyboardChangeKeyAvailable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self setContentV:nil];
    [self setTxtV:nil];
    [self setMaskV:nil];
    [self setLbStatus:nil];
    [self setLbComment:nil];
    [self setPostStatusBtn:nil];
    [self setPostCommentBtn:nil];
    [self setLbRepost:nil];
    [self setPostRepostBtn:nil];
    [self setQuotedV:nil];
    [self setQTxtV:nil];
    [self setImgBtn:nil];
    [self setToolbarV:nil];
    [self setGalleryBtn:nil];
    [self setMentionBtn:nil];
    [self setTopicBtn:nil];
    [self setEmotionBtn:nil];
    [self setThumbCtnV:nil];
    [self setThumbV:nil];
    [self setTextCountV:nil];
    [self setLbStatusWithGroup:nil];
    [self setPostWithGroupBtn:nil];
    [_closeBtn release];
    _closeBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  
    [_img release];
    [_btns release];
    //[_imgPkrVCtrl release];
    [_imgPkrCtnVCtrl release];
  
    [_followingsVCtrl release];
    [lbStatusWithGroup release];
    [postWithGroupBtn release];
    [_closeBtn release];
    
    KD_RELEASE_SAFELY(draft_);
    [super dealloc];
}

- (void)_adjustFramesForCurrentOrientation
{
    _ctnFrameDef = self.contentV.frame;
    _ctnFrameDef.origin.x = CGRectGetMidX(KWIRootVCtrl.curInst.view.bounds) - CGRectGetMidX(self.contentV.bounds);
    
    if ([UIDevice isPortrait]) {
        _ctnFrameDef.origin.y = CGRectGetMidY(KWIRootVCtrl.curInst.view.bounds) - CGRectGetMidY(self.contentV.bounds);
    } else {
        _ctnFrameDef.origin.y = 100;
    }
    
    _ctnFrameOut = _ctnFrameDef;
    _ctnFrameOut.origin.y  = -CGRectGetHeight(_ctnFrameDef);
}

- (void)newStatus
{
//    if (nil != self.curObjId) {
//        self.curObjId = nil;
//    }
    [self _reset];

    self.lbStatus.hidden = NO;
    self.postStatusBtn.hidden = NO;
    _curSendBtn = self.postStatusBtn;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.hidden = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.hidden = NO;
    }
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    self.draft = draft;
    
    [self _show];
}

- (void)newStatusWithGroup:(KDGroup *)group
{
//    if (![self.curObjId isEqualToString:group.id_]) {
//        [self _reset];
//        self.curGroup = group;
//        self.curObjId = group.id_;
//    }
    [self _reset];
 
    self.lbStatusWithGroup.hidden = NO;
    self.lbStatusWithGroup.text = [NSString stringWithFormat:@"给\"%@\"写微博", group.name];
    self.postWithGroupBtn.hidden = NO;
    _curSendBtn = self.postWithGroupBtn;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.hidden = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.hidden = NO;
    }
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    self.draft = draft;
    self.draft.groupId = group.groupId;

    [self _show];
}

- (void)newMention:(KDUser *)user
{
    //[self newStatus];
    //self.txtV.text = [NSString stringWithFormat:@"@%@ ", user.name];
    [self _reset];

    self.lbStatus.hidden = NO;
    self.postStatusBtn.hidden = NO;
    _curSendBtn = self.postStatusBtn;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.hidden = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.hidden = NO;
    }
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeNewStatus];
    draft.content = [NSString stringWithFormat:@"@%@ ", user.username];
    self.draft = draft;
    [self _show];
}

// 回复微博
- (void)replyStatus:(KDStatus *)status
{
    //[self _reset];
    [self _reset];

    self.lbComment.hidden = NO;
    self.postCommentBtn.hidden = NO;     
    _curSendBtn = self.postCommentBtn;
    
    //self.irtStatus = status;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.hidden = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.hidden = NO;
    }
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForStatus];
    draft.commentForStatusId = status.statusId;
    draft.originalStatusContent = [NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text];
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    self.draft = draft;
    [self _show];
}

//回复 回复
- (void)replyComment:(KDCommentStatus *)comment status:(KDStatus *)status
{
//    if (![self.curObjId isEqualToString:comment.status.id_]) {
//        [self _reset];
//        self.curObjId = comment.status.id_;
//    }
    [self _reset];

    self.lbComment.hidden = NO;
    self.lbComment.text = @"回复评论";
    self.postCommentBtn.hidden = NO; 
    _curSendBtn = self.postCommentBtn;
    
   // self.irtComment = comment;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imgBtn.hidden = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.galleryBtn.hidden = NO;
    }
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeCommentForComment];
    draft.commentForStatusId = status.statusId;
    draft.commentForCommentId = comment.statusId;
        
    draft.originalStatusContent = [NSString stringWithFormat:@"回复%@的评论: %@", comment.author.screenName, comment.text];
       
    if(status.groupId && status.groupName) {
        draft.groupId = status.groupId;
        draft.groupName = status.groupName;
    }
    self.draft = draft;
    [self _show];
}

// 转发微博
- (void)repostStatus:(KDStatus *)status{

    [self _reset];

    self.lbRepost.hidden = NO;
    self.postRepostBtn.hidden = NO;
    self.postRepostBtn.enabled = YES;
    self.quotedV.hidden = NO;
    self.txtV.frame = _txtFrameQ;
    
    KDDraft *draft = [KDDraft draftWithType:KDDraftTypeForwardStatus];
    draft.commentForStatusId = status.statusId;
    
    if([status hasForwardedStatus]) {
        draft.commentForStatusId = status.forwardedStatus.statusId;
        
        NSString *text = [NSString stringWithFormat:@"//@%@:%@", status.author.username, status.text];
        draft.content = text;
        
        draft.originalStatusContent = [NSString stringWithFormat:@"%@:%@", status.forwardedStatus.author.username, status.forwardedStatus.text];
    } else
        draft.originalStatusContent = [NSString stringWithFormat:@"%@:%@", status.author.screenName, status.text];
    
    if([status isKindOfClass:[KDGroupStatus class]]) {
        draft.groupId = status.groupId;
        draft.groupName = [[status.groupName copy] autorelease];
    }
    
    self.draft = draft;
    
    
    [self _show];
}

- (void)_show
{
    
    self.txtV.text = self.draft.content;
    if (draft_.originalStatusContent) {
         self.quotedV.hidden = NO;
         self.qTxtV.text = draft_.originalStatusContent;
    }
    
    NSUInteger i = 0;
    
    for (UIButton *btn in self.btns) {
        if (!btn.hidden) {
            CGRect frame = btn.frame;
            frame.origin.x = 20 + 56 * i;
            btn.frame = frame;
            i++;
        }
    }
    self.txtV.selectedRange = NSMakeRange(0, 0);
    [self.txtV becomeFirstResponder];
    // check for saved text
    [self textViewDidChange:self.txtV];
    
    [UIView animateWithDuration:0.25
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         self.view.alpha = 1;
                         self.contentV.frame = _ctnFrameDef;
                     } 
                     completion:nil];
}

- (void)_reset
{
    //self.lbComment.hidden = YES;
    //self.postCommentBtn.hidden = YES;
    //self.postCommentBtn.enabled = NO;
    //self.lbStatus.hidden = YES;
    //self.postStatusBtn.hidden = YES; 
    //self.postStatusBtn.enabled = NO;
    //self.lbRepost.hidden = YES;
    //self.postRepostBtn.hidden = YES;
    //self.postRepostBtn.enabled = NO;
    
    self.txtV.text = @"";
    self.txtV.frame = _txtFrameDef;
    self.textCountV.text = @"140";
    self.textCountV.alpha = 0;
    
    self.imgBtn.hidden = YES;
    self.galleryBtn.hidden = YES;
    self.thumbV.image = nil;
    self.thumbCtnV.hidden = YES;
    self.img = nil;
    
    self.curObjId = nil;
    
    //self.irtStatus = nil;
    //self.irtComment = nil;
    self.quotedV.hidden = YES;
    
    self.view.alpha = 0.0;
    self.contentV.frame = _ctnFrameOut;
    self.view.hidden = NO;
    self.view.frame = KWIRootVCtrl.curInst.view.bounds;
}

- (void)dismiss
{
    [self.txtV resignFirstResponder];
    
    [UIView animateWithDuration:0.25
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         self.view.alpha = 0;
                         self.contentV.frame = _ctnFrameOut;
                     } 
                     completion:^(BOOL finished){
                         self.view.hidden = YES;    
                         
                         self.lbComment.hidden = YES;
                         self.postCommentBtn.hidden = YES;
                         self.postCommentBtn.enabled = NO;
                         self.lbStatus.hidden = YES;
                         self.postStatusBtn.hidden = YES; 
                         self.postStatusBtn.enabled = NO;
                         self.lbRepost.hidden = YES;
                         self.postRepostBtn.hidden = YES;
                         self.postRepostBtn.enabled = NO;
                         self.lbStatusWithGroup.hidden = YES;
                         self.postWithGroupBtn.hidden = YES;
                         self.postWithGroupBtn.enabled = NO;
                         
                         //self.txtV.text = @"";
                         //self.txtV.frame = _txtFrameDef;
                         
                         //self.thumbV.image = nil;
                         //self.thumbCtnV.hidden = YES;
                         //self.img = nil;                         
                         //self.imgBtn.hidden = YES;
                         //self.galleryBtn.hidden = YES;
                         
                         self.quotedV.hidden = YES;                         
                     }];
}

- (void)_maskTapped
{
    [self dismiss];
}

- (IBAction)_postStatusBtnTapped:(id)sender 
{
    //[self _sendStatus];
    [self send];
}

- (IBAction)_postStatusWithGroupBtnTapped:(id)sender 
{
    //[self _sendStatusWithGroup];
    [self send];
}

- (IBAction)_postCommentBtnTapped:(id)sender
{
    //[self _sendComment];
    [self send];
}

- (IBAction)_postRepostBtnTapped:(id)sender 
{
   // [self _sendRepost];
    [self send];
}

//- (void)_handleStatusPostErr:(NSError *)err
//{
//    if ([@"ResponseWithError" isEqualToString:err.domain] && 500 == err.code) {
//        NSString *msg = nil;
//        if (err.userInfo) {
//            msg = [[[err.userInfo objectForKey:@"raw_resp"] JSONValue] objectForKey:@"message"];
//        }
//        
//        if (!msg) {
//            msg = @"发送微博失败，服务器端出错";
//        }
//
//        [[iToast makeText:msg] show];
//    } else {
//        [err KWIGeneralProcess];
//    }
//}

- (KDActivityIndicatorView *)activityView {
    if(!activityView_) {
        activityView_ = [[KDActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 80)];
        activityView_.center = self.txtV.center;
         [self.contentV addSubview:activityView_];
    }
    return activityView_;
}
- (void)showActivtyIndicator {
    
   [[self activityView] show:YES info:@"发送中..."];
    
}

- (void)hideActivityIndicator {
    if (activityView_) {
        [activityView_ hide:YES];
        [activityView_ removeFromSuperview];
        KD_RELEASE_SAFELY(activityView_);
    }
}
- (void)send {
	if(draft_.type == KDDraftTypeForwardStatus) {
        if (![self.txtV hasText]) {
            self.txtV.text = @"转发微博";
        }
    }
    
    if (![self.txtV hasText]){
        return;
    }
    [self lockUI];
    [self showActivtyIndicator];
    
    NSString *text = self.txtV.text;
    draft_.content = text;
    
    BOOL postToGroup = (draft_.groupId != nil) ? YES : NO;
    
    NSString *actionPath = nil;
    NSString *promptMessage = nil;
    NSString *successMessage = nil;
    __block NSString *errorMessage = nil;
    void (^successBlock)(id obj) = nil;
    if (draft_.type == KDDraftTypeNewStatus) {
        if (draft_.image) {  //发文字和图片
            actionPath = postToGroup ? @"/group/statuses/:upload" : @"/statuses/:upload";
            
        } else {  //仅文字
            actionPath = postToGroup ? @"/group/statuses/:update" : @"/statuses/:update";
        }
       // promptMessage = @"新微博发送中…";
        errorMessage = @"新微博发送失败。";
        successMessage = @"微博发送成功.";
        successBlock = ^(id obj) {
            if (draft_.image) {
                NSArray *array = (NSArray *)obj;
                KDStatus *postedStatus = (KDStatus *)[array objectAtIndex:0];
                UIImage *image = draft_.image;
                NSData *data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                [[KDCache sharedCache] storeImageData:data forURL:postedStatus.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreview];
                
                data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                [[KDCache sharedCache] storeImageData:data forURL:postedStatus.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreviewBlur];
                
                data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
                [[KDCache sharedCache] storeImageData:data forURL:postedStatus.compositeImageSource.thumbnailImageURL imageType:KDCacheImageTypeThumbnail];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPostVCtrl.newStatus" object:nil];
            
        };
    } else if (draft_.type == KDDraftTypeForwardStatus) {
        actionPath = postToGroup ? @"/group/statuses/:repost" : @"/statuses/:repost";
        
        promptMessage = @"转发微博发送中…";
        errorMessage = @"转发微博发送失败。";
        successMessage = @"转发微博发送成功";
        successBlock = ^(id obj) {
            NSArray *array = (NSArray *)obj;
            KDStatus *status = (KDStatus *)[array objectAtIndex:0];
            NSDictionary *uinf = [NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPostVCtrl.newStatus" object:nil userInfo:uinf];
        };
        
    } else if (draft_.type == KDDraftTypeCommentForStatus || draft_.type == KDDraftTypeCommentForComment) {
        if (draft_.image) {
            actionPath = postToGroup ? @"/group/statuses/:uploadComment" : @"/statuses/:uploadComment";
        }else {
            actionPath = postToGroup ? @"/group/statuses/:comment" : @"/statuses/:comment";
        }
        
        if (draft_.type == KDDraftTypeCommentForStatus) {
            promptMessage = @"回复微博发送中…";
            errorMessage = @"回复微博发送失败。";
            successMessage = @"回复微博发送成功。";
            
        } else {
            promptMessage = @"回复评论发送中…";
            errorMessage = @"回复评论发送失败。";
            successMessage = @"回复评论发送成功。";
        }
        
        successBlock = ^(id obj) {
            NSArray *array = (NSArray *)obj;
            KDCommentStatus *status = (KDCommentStatus *)[array objectAtIndex:0];
            if (draft_.image) {
                UIImage *image = draft_.image;
                NSData *data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                [[KDCache sharedCache] storeImageData:data forURL:status.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreview];
                
                data = [image asJPEGDataWithQuality:kKDJPEGBlurPreviewImageQuality];
                [[KDCache sharedCache] storeImageData:data forURL:status.compositeImageSource.bigImageURL imageType:KDCacheImageTypePreviewBlur];
                
                data = [image asJPEGDataWithQuality:kKDJPEGThumbnailQuality];
                [[KDCache sharedCache] storeImageData:data forURL:status.compositeImageSource.thumbnailImageURL imageType:KDCacheImageTypeThumbnail];
            }
            NSDictionary *uinf = [NSDictionary dictionaryWithObjectsAndKeys:status, @"comment", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPostVCtrl.newComment" object:nil userInfo:uinf];
        };
    }
    
    KDQuery *query = [KDQuery query];
    [query setProperty:draft_ forKey:@"draft"];
    
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        BOOL isPosted = [response isValidResponse];
        if (isPosted) {
            DLog(@"send success.....");
            if (successBlock != nil) {
                successBlock(results);
                [[iToast makeText:successMessage] show];
            }
            
        } else {
            // show error message
            NSDictionary *info = [response responseAsJSONObject];
            if (info != nil) {
                NSString *message = [info stringForKey:@"message"];
                NSInteger code = [info integerForKey:@"code"];
                if (message != nil && [message rangeOfString:@"微博已删除"].location != NSNotFound) {
                    errorMessage = NSLocalizedString(@"ORIGIN_STATUS_DELETED_WHEN_REPOSE", @"");
                    isPosted = YES;
                    
                } else if (code == 40005) {
                    errorMessage = NSLocalizedString(@"NO_IDENTICAL_STATUS_IN_TRHEE_MIN", @"");
                    isPosted = YES;
                }
            }
            
            [[iToast makeText:errorMessage] show];
        }
        [self hideActivityIndicator];
        [self dismiss];
        //[self _reset];
        [self unlockUI];
        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
            id<KDDraftDAO> draftDAO = [[KDWeiboDAOManager globalWeiboDAOManager] draftDAO];
            if (isPosted) {
                [draftDAO removeDraftWithId:self.draft.draftId database:fmdb];
                
            } else {
                [draftDAO saveDraft:self.draft database:fmdb];
            }
            return nil;
            
        } completionBlock:nil];
       
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:actionPath query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}
/*
- (void)_sendRepost
{
    [self lockUI];
    KWEngine *api = [KWEngine sharedEngine];
    [api repostStatus:self.quotedStatus.id_ 
                 text:[self _getProcessedText]
            onSuccess:^(NSDictionary *dict) {
                NSDictionary *uinf = [NSDictionary dictionaryWithObjectsAndKeys:[KWStatus statusFromDict:dict], @"status", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPostVCtrl.newStatus" object:nil userInfo:uinf];
                //[self clear];
                [self _reset];
                [self dismiss];
                [self unlockUI];
                [[iToast makeText:@"转发成功"] show];
            } 
              onError:^(NSError *error) {
                  [self _handleStatusPostErr:error];
                  //_curSendBtn.enabled = YES;
                  [self unlockUI];
              }];
    
//    [self dismiss];
//    [self _reset];    
//    [self unlockUI];
}
*/
- (IBAction)_cameraBtnTapped:(id)sender
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [KWIRootVCtrl.curInst presentViewController:self.cameraVCtrl animated:YES completion:nil];
    } else {
        [self presentModalViewController:self.cameraVCtrl animated:YES];
    }
}

- (IBAction)_imgBtnTapped:(id)sender 
{
    if (!self.imgPkrCtnVCtrl) {
        self.imgPkrCtnVCtrl = [[[UIPopoverController alloc] initWithContentViewController:self.galleryVCtrl] autorelease];
    }    
    
    self.imgPkrCtnVCtrl.delegate = self;
    [self.imgPkrCtnVCtrl presentPopoverFromRect:[self.view convertRect:self.galleryBtn.frame 
                                                              fromView:self.toolbarV] 
                                         inView:self.view 
                       permittedArrowDirections:UIPopoverArrowDirectionAny 
                                       animated:YES];
    
}

- (void)_configImg
{
    if (nil == self.img) {
        return;
    }
    
    CGRect frame = self.thumbV.frame;
    frame.size.width = self.img.size.width * (frame.size.height / self.img.size.height);   
    self.thumbV.frame = frame;
    self.thumbV.image = self.img;
    
    CGRect ctnFrame = self.thumbCtnV.frame;
    ctnFrame.size.width = frame.size.width + 25;
    self.thumbCtnV.frame = ctnFrame;
    self.thumbCtnV.hidden = NO;
    
    CGRect textFrm = _txtFrameDef;
    textFrm.size.height -= ctnFrame.size.height;
    self.txtV.frame = textFrm;
    
    _curSendBtn.enabled = YES;
}

- (void)_onKeyboardShown:(NSNotification *)note
{
    CGRect kbFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbFrame = [UIApplication.sharedApplication.keyWindow.rootViewController.view convertRect:kbFrame fromView:nil];
    _lastKbTop = kbFrame.origin.y;
    
    [self _adjustFramesForKeyboardTop:_lastKbTop];
}

- (void)_adjustFramesForKeyboardTop:(NSUInteger)kbTop
{
    CGFloat contentTop = MIN(kbTop - 320, CGRectGetMinY(_ctnFrameDef));
    CGRect frame = self.contentV.frame;
    frame.origin.y = contentTop;
    [UIView animateWithDuration:0.1 
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState  
                     animations:^{
                         self.contentV.frame = frame;
                     } 
                     completion:nil];
}

//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
//    [popoverController release];
//}

- (IBAction)_removeImgBtnTapped:(id)sender 
{
    self.txtV.frame = _txtFrameDef;
    self.thumbCtnV.hidden = YES;
    self.img = nil;    
    self.thumbV.image = nil;
    
    // trigger text count check
    [self textViewDidChange:self.txtV];
}

/*- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger len = textView.text.length + text.length - range.length;
    return len <= 140;
}*/

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = [self _getProcessedText];
    
    // convert all url into a placeholder with length 10
    // use same regx pattern as the one in API
    NSRegularExpression *urlRegx= [NSRegularExpression regularExpressionWithPattern:@"(http[s]?://[\\p{Graph}]*)"
                                                                            options:0 
                                                                              error:nil];    
    NSMutableArray *matchedUrls = [NSMutableArray array];
    [urlRegx enumerateMatchesInString:text
                              options:0
                                range:NSMakeRange(0, text.length)
                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                               [matchedUrls addObject:[text substringWithRange:result.range]];
                           }];
    for (NSString *url in matchedUrls) {
        text = [text stringByReplacingOccurrencesOfString:url withString:@"01234567890123456789"];
    }
    
    unsigned int len = 0;
    for (unsigned int i = 0; i < text.length; i++) {
        len += (128 > [text characterAtIndex:i])?1:2;
    }
    
    // or if there are only one ascii char it will be count as 0
    len = ceil(len/2.0);
    
    self.textCountV.text = [NSString stringWithFormat:@"%d", 140 - len];
    self.textCountV.alpha = len / 140.0;
    
    if (140 >= len) {
        self.textCountV.textColor = [UIColor darkTextColor];
    } else {
        self.textCountV.textColor = [UIColor redColor];
    }
    
    BOOL allowEmptyTxt = NO;    
//    if (self.quotedStatus || self.img) {
//        allowEmptyTxt = YES;
//    }
    
    _curSendBtn.enabled = (allowEmptyTxt || (0 < len)) && (140 >= len);
}

- (IBAction)_mentionBtnTapped:(id)sender 
{
    _poper = [[UIPopoverController alloc] initWithContentViewController:self.followingsVCtrl];
    [_poper presentPopoverFromRect:[self.view convertRect:self.mentionBtn.frame 
                                                              fromView:self.toolbarV] 
                                         inView:self.view 
                       permittedArrowDirections:UIPopoverArrowDirectionAny 
                                       animated:YES];
}

- (IBAction)_topicBtnTapped:(id)sender 
{
    NSString *toInsert = @"#请输入话题#";
    if (140 - toInsert.length >= self.txtV.text.length) {
        [self.txtV insertText:toInsert];
        self.txtV.selectedRange = [self.txtV.text rangeOfString:@"请输入话题"
                                                        options:NSBackwardsSearch];
        
        // trigger text count check
        [self textViewDidChange:self.txtV];
    }
}

- (KWIMentionSelectorVCtrl *)followingsVCtrl
{
    if (nil == _followingsVCtrl) {
        _followingsVCtrl = [[KWIMentionSelectorVCtrl vctrl] retain];
    }
    return _followingsVCtrl;
}

- (void)_onFollowingsSelected:(NSNotification *)note
{
    KDUser *user = [note.userInfo objectForKey:@"user"];
    [self.txtV insertText:[NSString stringWithFormat:@"@%@ ", user.screenName]];
    [_poper dismissPopoverAnimated:YES];
    
    // trigger text count check
    [self textViewDidChange:self.txtV];
}

- (IBAction)_onCloseBtnTapped:(id)sender 
{
    [self dismiss];
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _adjustFramesForCurrentOrientation];
    [self _adjustFramesForKeyboardTop:_lastKbTop];
}

- (UIImagePickerController *)cameraVCtrl
{
    if (!_cameraVCtrl) {
        _cameraVCtrl = [[UIImagePickerController alloc] init];
        _cameraVCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        _cameraVCtrl.allowsEditing = NO;
        _cameraVCtrl.delegate = self;
        _cameraVCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    return _cameraVCtrl;
}

- (UIImagePickerController *)galleryVCtrl
{
    if (!_galleryVCtrl) {
        _galleryVCtrl = [[UIImagePickerController alloc] init];
        _galleryVCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _galleryVCtrl.allowsEditing = NO;
        _galleryVCtrl.delegate = self;
    }
    
    return _galleryVCtrl;
}

- (void)lockUI
{
    //self.view.userInteractionEnabled = NO;    
    _curSendBtn.enabled = NO;
    _closeBtn.enabled = NO;
    toolbarV.userInteractionEnabled = NO;
}

- (void)unlockUI
{
    //self.view.userInteractionEnabled = YES;
    _curSendBtn.enabled = YES;
    _closeBtn.enabled = YES;
    toolbarV.userInteractionEnabled = YES;
}

- (NSString *)_getProcessedText
{
    NSString *text = self.txtV.text;
    NSRange emojiRange = [text rangeOfCharacterFromSet:[NSCharacterSet emojiCharacterSet]];    
    while (emojiRange.length) {
        // add space before and after placeholder char, or texts between two emoji will be replaced too.
        text = [text stringByReplacingCharactersInRange:emojiRange withString:@"  "];
        emojiRange = [text rangeOfCharacterFromSet:[NSCharacterSet emojiCharacterSet]];
    }
    
    return text;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    static const float SIZE_LIMIT = 1280.0;
    CGFloat scale = 1.0;
    CGFloat longerEdge = MAX(pickedImg.size.width, pickedImg.size.height);
    scale = longerEdge / SIZE_LIMIT;
    CGSize targetSize;
    if (1 < scale) {
        targetSize = CGSizeMake(pickedImg.size.width / scale, pickedImg.size.height / scale);
    } else {
        targetSize = pickedImg.size;
    }
    
    // resize even if no need to change size, just to get correct orientation
    self.img = [pickedImg resizedImage:targetSize interpolationQuality:kCGInterpolationHigh];
    self.draft.image = self.img;
    
    if (picker == self.galleryVCtrl) {
        [self.imgPkrCtnVCtrl dismissPopoverAnimated:YES];
        self.imgPkrCtnVCtrl = nil;
        self.galleryVCtrl = nil;
    } else {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [KWIRootVCtrl.curInst dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissModalViewControllerAnimated:YES];
        }
        
        self.cameraVCtrl = nil;
    }
    
    // to make UIImagePickerController able to release
    [self performSelector:@selector(_configImg) withObject:nil afterDelay:0];
}
@end
