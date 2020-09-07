//
//  KDExtendStatusDetailView.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDExtendStatusDetailView.h"
#import "KDStatusPhotoRenderView.h"
#import "KDExpressionLabel.h"
#import "KDWeiboAppDelegate.h"

#define KD_TAG_EXTENDSTAUTS_SOURCECONTENT          110
#define KD_TAG_EXTENDSTATUS_FORWARDCONTENT         111
#define KD_TAG_EXTENDSTATUS_PHOTOVIEW              112
#define KD_TAG_EXTENDSTATUS_DIVIDERView            113
#define KD_TAG_EXTENDSTATUS_BACKGROUNDVIEW         114

#define KD_EXTENDSTATUS_FONTSIZE                   14.0f

#define KD_EXTENDSTATUS_H_PADDING                  5.0f

@interface KDExtendStatusDetailView ()
{
    KDExtendStatus *status_;
    id<KDExtendStatusDetailViewDelegate> delegate_;
    BOOL copyForward_;
}

- (void)setUp;

@end

void clickUrl(NSString *url)
{
    KDWeiboAppDelegate *appDelegate = [KDWeiboAppDelegate getAppDelegate];
    [appDelegate openWebView:url];
}

@implementation KDExtendStatusDetailView

@synthesize status = status_;
@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        copyForward_ = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHiddenAction) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (void)dealloc {
//    [status_ release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    //[super dealloc];
}

- (void)setStatus:(KDExtendStatus *)status {
//    [status retain];
//    [status_ release];
    status_ = status;
    
    [self setUp];
}

- (void)setUp {
    //source content label
    KDExpressionLabel *sourceLable = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
    if(!sourceLable) {
        sourceLable = [[KDExpressionLabel alloc] initWithFrame:CGRectMake(KD_EXTENDSTATUS_H_PADDING, 0.0f, self.frame.size.width - 2 * KD_EXTENDSTATUS_H_PADDING, 1.0f) andType:KDExpressionLabelType_URL urlRespondFucIfNeed:clickUrl] ;//autorelease];
        sourceLable.tag = KD_TAG_EXTENDSTAUTS_SOURCECONTENT;
        sourceLable.backgroundColor = [UIColor clearColor];
        sourceLable.font = [UIFont systemFontOfSize:KD_EXTENDSTATUS_FONTSIZE];
        [self addSubview:sourceLable];
    }
    
    sourceLable.text = [NSString stringWithFormat:@"%@:%@", status_.senderName, status_.content];
    
    //if has forward status  (another sina micro blog)
    
    //divier image
    UIImageView *divider = (UIImageView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_DIVIDERView];
    if(!divider && status_.forwardedContent) {
        divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_separator.png"]];// autorelease];
//        divider = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_page_cell_separator_bg"]] autorelease];
        divider.tag = KD_TAG_EXTENDSTATUS_DIVIDERView;
        [self addSubview:divider];
    }
    
    //转发内容
    KDExpressionLabel *forwardContentLabel = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
    if(!forwardContentLabel && status_.forwardedContent) {
        forwardContentLabel = [[KDExpressionLabel alloc] initWithFrame:CGRectMake(KD_EXTENDSTATUS_H_PADDING, 0.0f, self.frame.size.width - 2 *KD_EXTENDSTATUS_H_PADDING, 1.0f) andType:KDExpressionLabelType_URL urlRespondFucIfNeed:clickUrl];// autorelease];
        forwardContentLabel.tag = KD_TAG_EXTENDSTATUS_FORWARDCONTENT;
        forwardContentLabel.backgroundColor = [UIColor clearColor];
        forwardContentLabel.font = [UIFont systemFontOfSize:KD_EXTENDSTATUS_FONTSIZE];
        [self addSubview:forwardContentLabel];
    }
    
    forwardContentLabel.text = [NSString stringWithFormat:@"%@:%@", status_.forwardedSenderName, status_.forwardedContent];
    
    if(!status_.forwardedContent) {
        if(divider) [divider removeFromSuperview];
        if(forwardContentLabel) [forwardContentLabel removeFromSuperview];
    }
    
    KDStatusPhotoRenderView *photoRenderView = (KDStatusPhotoRenderView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_PHOTOVIEW];
    if(!photoRenderView && status_.compositeImageSource) {
        photoRenderView = [KDStatusPhotoRenderView photoRenderView];
        photoRenderView.tag = KD_TAG_EXTENDSTATUS_PHOTOVIEW;
        [photoRenderView addTarget:self action:@selector(photoClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoRenderView];
    }
    
    if(status_.compositeImageSource) {
        photoRenderView.imageSource = status_.compositeImageSource;
    }else if(photoRenderView) {
        [photoRenderView removeFromSuperview];
    }
    
    UILongPressGestureRecognizer *gest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    gest.minimumPressDuration = 0.35;
    [self addGestureRecognizer:gest];
//    [gest release];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    UIMenuController *menuViewController = [UIMenuController sharedMenuController];
    if([menuViewController isMenuVisible]) return;
    
    CGPoint touchPoint = [gesture locationInView:self];
    
    UILabel *forwardContentLabel = (UILabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
    UILabel *sourceLable = (UILabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
    
    if(forwardContentLabel && CGRectContainsPoint(forwardContentLabel.frame, touchPoint)) {
        copyForward_ = YES;
        forwardContentLabel.backgroundColor = [UIColor lightGrayColor];
        [menuViewController setTargetRect:CGRectMake(forwardContentLabel.frame.size.width * 0.5f, 0.0f, 0.0f, 0.0f) inView:forwardContentLabel];
    }else if(sourceLable && CGRectContainsPoint(sourceLable.frame, touchPoint)) {
        copyForward_ = NO;
        sourceLable.backgroundColor = [UIColor lightGrayColor];
        [menuViewController setTargetRect:CGRectMake(sourceLable.frame.size.width * 0.5f, 0.0f, 0.0f, 0.0f) inView:sourceLable];
    }else
        return;
    
    [self becomeFirstResponder];
    
    [menuViewController setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)copy:(id)sender {
    if(copyForward_) {
        KDExpressionLabel *forwardContentLabel = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
        if(forwardContentLabel)
            [[UIPasteboard generalPasteboard] setString:forwardContentLabel.text];
    }else {
        KDExpressionLabel *sourceLable = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
        if(sourceLable)
            [[UIPasteboard generalPasteboard] setString:sourceLable.text];
    }
}

- (void)menuHiddenAction {
    if(copyForward_) {
        KDExpressionLabel *forwardContentLabel = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
        if(forwardContentLabel)
            [forwardContentLabel setBackgroundColor:[UIColor clearColor]];
    }else {
        KDExpressionLabel *sourceLable = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
        if(sourceLable)
            [sourceLable setBackgroundColor:[UIColor clearColor]];
    }
}


- (CGFloat)adaptionHeight {
    CGFloat height = 0.0f;
    
    //TODO:calculate height
    
    //top padding
    height += 5.0f;
    
    //source content
    UILabel *sourceLabel = (UILabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
    if(sourceLabel) {
        CGSize sourceSize = [sourceLabel.text sizeWithFont:sourceLabel.font constrainedToSize:CGSizeMake(sourceLabel.frame.size.width, MAXFLOAT)];
        height += sourceSize.height;
    }
    
    //may need space
    
    //divider
    height += 2.0f;
    
    //forward content
    UILabel *forwardLabel = (UILabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
    if(forwardLabel) {
        CGSize forwardSize = [forwardLabel.text sizeWithFont:forwardLabel.font constrainedToSize:CGSizeMake(forwardLabel.frame.size.width, MAXFLOAT)];
        height += forwardSize.height;
    }
    
    //may need space
    
    //image source
    KDStatusPhotoRenderView *photoView = (KDStatusPhotoRenderView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_PHOTOVIEW];
    if(photoView) {
        height += photoView.frame.size.height;
    }
    
    //bottom padding
    height += 5.0f;
    
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat originY = 0.0f;
    
    //top padding
    originY += 8.0f;
    
    //source label
    KDExpressionLabel *sourceLabel = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTAUTS_SOURCECONTENT];
    if(sourceLabel) {
        CGSize sourceLabelSize = [sourceLabel.text sizeWithFont:sourceLabel.font constrainedToSize:CGSizeMake(sourceLabel.frame.size.width, MAXFLOAT)];
        sourceLabel.frame = CGRectMake(KD_EXTENDSTATUS_H_PADDING, originY, sourceLabelSize.width, sourceLabelSize.height);
        
        originY += sourceLabelSize.height;
    }
    
    //may need space
    originY +=3;
    //divider image view
    UIImageView *dividerView = (UIImageView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_DIVIDERView];
    if(dividerView) {
        dividerView.frame = CGRectMake(1.0f, originY, self.frame.size.width - 2.0f, 2.0f);
        originY += 2.0f;
    }
    
    //may need space
    
    //forwarded label
    KDExpressionLabel *forwardLabel = (KDExpressionLabel *)[self viewWithTag:KD_TAG_EXTENDSTATUS_FORWARDCONTENT];
    if(forwardLabel) {
        CGSize forwardLabelSize = [forwardLabel.text sizeWithFont:forwardLabel.font constrainedToSize:CGSizeMake(forwardLabel.frame.size.width, MAXFLOAT)];
        forwardLabel.frame = CGRectMake(KD_EXTENDSTATUS_H_PADDING, originY, forwardLabelSize.width, forwardLabelSize.height);
        originY +=forwardLabelSize.height;
    }
    
    //may need space
    originY+=5;
    //photo view
    KDStatusPhotoRenderView *photoView = (KDStatusPhotoRenderView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_PHOTOVIEW];
    if(photoView) {
        photoView.frame = CGRectMake(KD_EXTENDSTATUS_H_PADDING, originY, self.frame.size.width - 2 * KD_EXTENDSTATUS_H_PADDING, 100.0f);
        originY += 100.0f;
    }
    
    //bottom space
    originY += 5.0f;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, originY);
    
    UIImageView *background = (UIImageView *)[self viewWithTag:KD_TAG_EXTENDSTATUS_BACKGROUNDVIEW];
    if(!background) {
        UIImage *sinaIcon = [UIImage imageNamed:@"extend_status_bg"];
//        sinaIcon = [sinaIcon stretchableImageWithLeftCapWidth:sinaIcon.size.width * 0.1f topCapHeight:sinaIcon.size.height * 0.1f];
        sinaIcon = [sinaIcon stretchableImageWithLeftCapWidth:sinaIcon.size.width * 0.5f topCapHeight:sinaIcon.size.height * 0.5f];
        background = [[UIImageView alloc] initWithFrame:self.bounds];// autorelease];
        [background setImage:sinaIcon];
        [self insertSubview:background atIndex:0];
    }
    
    [self.superview setNeedsLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)photoClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(extendStautsDetailView:showImageGallery:)]) {
        [delegate_ extendStautsDetailView:self showImageGallery:status_.compositeImageSource];
    }
}

- (void)statusPhotoRenderView:(KDStatusPhotoRenderView *)photoRenderView didFinishLoadImage:(UIImage *)image {
    [self setNeedsLayout];
}

@end
