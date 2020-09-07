//
//  KDStatusCellForDetailView.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-13.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDStatusCellForDetailView.h"

#import "TwitterText.h"
#import "NSDate+Additions.h"
#import "KDCommentStatus.h"
#import "KDStatusContentDetailView.h"
#import "KDThumbnailView2.h"
#import "KDAttachmentIndicatorView.h"
#import "KDThumbnailView.h"
#import "KDDocumentIndicatorView.h"
#import "KDDefaultViewControllerContext.h"


#define KD_TAG_STATUSCELL_USERNAMELABEL           210
#define KD_TAG_STATUSCELL_TIMELINELABEL           211
#define KD_TAG_STATUSCELL_CORETEXTVIEW            212
#define KD_TAG_STATUSCELL_SEPERATORVIEW           213
#define KD_TAG_STATUSCELL_THUMBNAILVIEW           214
#define KD_TAG_STATUSCELL_MULTIPHOTONOTICEVIEW    215
#define KD_TAG_STATUSCELL_DOCUMENTATION           216
#define KD_TAG_STATUSCELL_AVATAR                  217

#define KD_STATUSCELL_FONTSIZE              14.0f

#define KD_STATUSCELL_V_PADDING             10.0f
#define KD_STATUSCELL_V_SPACING             5.0f
#define KD_STATUSCELL_H_PADDING             8.0f

@interface KDStatusCellForDetailView ()<KDDocumentIndicatorViewDelegate>

- (void)setUp;
- (void)setUpUserNameLabel;
- (void)setUpTimeLineLabel;
- (void)setUpCoreTextView;
- (void)setUpBackgroundView;
- (void)setUpThumbnailView;
- (void)setupMultiPhotoNoticeView;
- (void)setUpDocumentationView;

@end

@implementation KDStatusCellForDetailView

@synthesize status = status_;
@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIView *backgroundView = [UIView strokeCellSeparatorBgView];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundView = backgroundView;
        
    }
    return self;
}

- (void)dealloc {
//    [status_ release];
    status_ = nil;
    
    //[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setStatus:(KDStatus *)status {
//    [status retain];
//    [status_ release];
    status_ = status;
    [self setUp];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [self layoutFrame];
}

- (void)setUp {
    [self setUpUserAvatarView];
    [self setUpUserNameLabel];
    [self setUpTimeLineLabel];
    [self setUpCoreTextView];
    
    if(status_.compositeImageSource && status_.compositeImageSource.imageSources.count > 0) {
        [self setUpThumbnailView];
    }
    
    if(status_.attachments.count > 0 && ![status_ hasVideo]) {
        [self setUpDocumentationView];
    }
    
}

- (void)setUpUserAvatarView {
   KDUserAvatarView *userAvatarView = (KDUserAvatarView *)[self viewWithTag:KD_TAG_STATUSCELL_AVATAR];
    if(!userAvatarView) {
        userAvatarView= [KDUserAvatarView avatarView];
        userAvatarView.tag = KD_TAG_STATUSCELL_AVATAR;
        [self.contentView addSubview:userAvatarView];
    }
    userAvatarView.avatarDataSource = status_.author;
}

- (void)setUpUserNameLabel {
    UILabel *userNameLabel = (UILabel *)[self viewWithTag:KD_TAG_STATUSCELL_USERNAMELABEL];
    if(!userNameLabel) {
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];// autorelease];
        userNameLabel.tag = KD_TAG_STATUSCELL_USERNAMELABEL;
        userNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:userNameLabel];
    }
    
    userNameLabel.text = status_.author.screenName;
}

- (void)setUpTimeLineLabel {
    
    UILabel *timeLineLabel = (UILabel *)[self viewWithTag:KD_TAG_STATUSCELL_TIMELINELABEL];
    if(!timeLineLabel) {
        timeLineLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;//autorelease];
        timeLineLabel.tag = KD_TAG_STATUSCELL_TIMELINELABEL;
        timeLineLabel.font = [UIFont systemFontOfSize:13.0f];
        timeLineLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLineLabel];
    }
    
    timeLineLabel.text = [status_ createdAtDateAsString];
}

- (void)setUpCoreTextView {
    KDStatusContentDetailView *contentView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCELL_CORETEXTVIEW];
    if(!contentView) {
        contentView = [[KDStatusContentDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 2 * KD_STATUSCELL_H_PADDING, 0.0f) andMode:KDStatusContentDetailViewCompleteMode andType:KDStatusContentDetailViewTypeReply];
        contentView.tag = KD_TAG_STATUSCELL_CORETEXTVIEW;
        contentView.delegate = self.delegate;
        contentView.backgroundColor = [UIColor clearColor];
        contentView.font = [UIFont systemFontOfSize:KD_STATUSCELL_FONTSIZE];
        [self addSubview:contentView];
//        [contentView release];
    }
    
    [contentView setStatus:status_];
}

- (void)setUpBackgroundView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_separator.png"]] ;//autorelease];
    [self setBackgroundView:imageView];
}

- (void)setUpThumbnailView {
    int count = (int)[ status_.compositeImageSource.imageSources count];
    KDThumbnailView2 *thumbnail = (KDThumbnailView2 *)[self viewWithTag:KD_TAG_STATUSCELL_THUMBNAILVIEW];
    if(!thumbnail) {
        thumbnail = [KDThumbnailView2 thumbnailViewWithStatus:status_];
        thumbnail.delegate = delegate_;
        thumbnail.tag = KD_TAG_STATUSCELL_THUMBNAILVIEW;
        
        [thumbnail addTarget:self action:@selector(didTapOnThumbnailView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:thumbnail];
    }
    
    [thumbnail setImageDataSource:self.status.compositeImageSource withType:SDWebImageScaleMiddle];
    
    CGSize size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:status_.compositeImageSource showAll:(count > 1)];
    thumbnail.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
}

- (void)setupMultiPhotoNoticeView {
    UIView *multiView = [self viewWithTag:KD_TAG_STATUSCELL_MULTIPHOTONOTICEVIEW];
    if(!multiView) {
        multiView = [[UIView alloc] initWithFrame:CGRectZero] ;//autorelease];
        multiView.tag = KD_TAG_STATUSCELL_MULTIPHOTONOTICEVIEW;
        [self addSubview:multiView];
        
        UIImageView *noticeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumbnail_multi_v2.png"]];
        [multiView addSubview:noticeImage];
//        [noticeImage release];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumbnail_arrow_v2.png"]];
        [multiView addSubview:arrow];
//        [arrow release];
        
        multiView.frame = CGRectMake(0.0f, 0.0f, noticeImage.frame.size.width + arrow.image.size.width + 10.0f, noticeImage.frame.size.height + 10.0f);
        noticeImage.frame = CGRectMake(5.0f, (multiView.frame.size.height - noticeImage.frame.size.height) * 0.5, noticeImage.frame.size.width, noticeImage.frame.size.height);
        arrow.frame = CGRectMake(CGRectGetMaxX(noticeImage.frame) + 5.0f, CGRectGetMaxY(noticeImage.frame) - arrow.image.size.height, arrow.image.size.width, arrow.image.size.height);
        
        //        UITapGestureRecognizer *recog = [UITapGestureRecognizer alloc] initWithTarget:self action:@selector(<#selector#>)
    }
}

- (void)setUpDocumentationView {
    KDDocumentIndicatorView *documentIndicatorView = (KDDocumentIndicatorView *)[self viewWithTag:KD_TAG_STATUSCELL_DOCUMENTATION];
    
    if(!documentIndicatorView) {
        documentIndicatorView =[[KDDocumentIndicatorView alloc] initWithFrame:CGRectZero];// autorelease];
        documentIndicatorView.tag = KD_TAG_STATUSCELL_DOCUMENTATION;
        documentIndicatorView.delegate = self;
        
        [self addSubview:documentIndicatorView];
    }
    
    [documentIndicatorView setDocuments:status_.attachments];
}

- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView {
    if(thumbnailView && delegate_ && [delegate_ respondsToSelector:@selector(didTapOnThumbnailView:userInfo:)]) {
        [delegate_ didTapOnThumbnailView:thumbnailView userInfo:nil];
    }
}

- (void)attachmentViewClicked:(id)sender {
    if([delegate_ respondsToSelector:@selector(statusDetailView:clickedAttachmentForStatus:)]) {
        [delegate_ statusDetailView:nil clickedAttachmentForStatus:status_];
    }
}


- (void)layoutFrame {
    CGFloat originY = 0.0f;
    
    //top padding
    originY += KD_STATUSCELL_V_PADDING;
    CGFloat originX = 0;
    KDUserAvatarView *avatar = (KDUserAvatarView *)[self viewWithTag:KD_TAG_STATUSCELL_AVATAR];
    if (avatar) {
        avatar.frame = CGRectMake(10, originY, 38, 38);
        originX = CGRectGetMaxX(avatar.frame) + 15;
    }

    //time line label
    UILabel *timeLineLabel = (UILabel *)[self viewWithTag:KD_TAG_STATUSCELL_TIMELINELABEL];
    if(timeLineLabel) {
       // CGSize timeLineSize = [timeLineLabel.text sizeWithFont:timeLineLabel.font];
        [timeLineLabel sizeToFit];
        timeLineLabel.backgroundColor = [UIColor redColor];
        CGSize timeLineSize = timeLineLabel.bounds.size;
        timeLineLabel.frame = CGRectMake(self.frame.size.width - KD_STATUSCELL_H_PADDING - timeLineSize.width, originY, timeLineSize.width, timeLineSize.height);
    }
    
    //user name label
    UILabel *userNameLabel = (UILabel *)[self viewWithTag:KD_TAG_STATUSCELL_USERNAMELABEL];
    if(userNameLabel) {
        CGSize userNameSize = [userNameLabel.text sizeWithFont:userNameLabel.font];
        if(userNameSize.width > self.frame.size.width - 2 * KD_STATUSCELL_H_PADDING - timeLineLabel.bounds.size.width - KD_STATUSCELL_H_PADDING)
            userNameSize.width = self.frame.size.width - timeLineLabel.frame.size.width - 3 * KD_STATUSCELL_H_PADDING;
        userNameLabel.frame = CGRectMake(originX, originY, userNameSize.width, userNameSize.height);
        
        originY += userNameSize.height;
        
        //spacing
        originY += KD_STATUSCELL_V_SPACING;
    }
    
    //core text view
    KDStatusContentDetailView *contentView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCELL_CORETEXTVIEW];
    if(contentView) {
        [contentView sizeToFit];
        contentView.frame = CGRectMake(KD_STATUSCELL_H_PADDING, originY, self.frame.size.width - 2 * KD_STATUSCELL_H_PADDING, contentView.frame.size.height);
        
        originY += contentView.frame.size.height;
    }
    
    
    //thunbnail view
    int count = (int)[status_.compositeImageSource.imageSources count];
    if (count == 1) {
        KDThumbnailView *thumbnail = (KDThumbnailView *)[self viewWithTag:KD_TAG_STATUSCELL_THUMBNAILVIEW];
        if(thumbnail) {
            originY += KD_STATUSCELL_V_SPACING;
            
            thumbnail.frame = CGRectMake(KD_STATUSCELL_H_PADDING, originY, thumbnail.frame.size.width, thumbnail.frame.size.height);
            
            UIView *multiView = [self viewWithTag:KD_TAG_STATUSCELL_MULTIPHOTONOTICEVIEW];
            if(multiView) {
                multiView.frame = CGRectMake(CGRectGetMaxX(thumbnail.frame), CGRectGetMaxY(thumbnail.frame) - multiView.frame.size.height, multiView.frame.size.width, multiView.frame.size.height);
            }
            
            originY += thumbnail.frame.size.height;
        }
    } else if(count > 1) {
        KDThumbnailView2 *thumbnail = (KDThumbnailView2 *)[self viewWithTag:KD_TAG_STATUSCELL_THUMBNAILVIEW];
        if(thumbnail) {
            
            originY += KD_STATUSCELL_V_SPACING;
            thumbnail.status = self.status;
            thumbnail.frame = CGRectMake(KD_STATUSCELL_H_PADDING, originY, thumbnail.frame.size.width, thumbnail.frame.size.height);
            
            UIView *multiView = [self viewWithTag:KD_TAG_STATUSCELL_MULTIPHOTONOTICEVIEW];
            if(multiView) {
                multiView.frame = CGRectMake(CGRectGetMaxX(thumbnail.frame), CGRectGetMaxY(thumbnail.frame) - multiView.frame.size.height, multiView.frame.size.width, multiView.frame.size.height);
            }
            
            originY += thumbnail.frame.size.height;
        }
    }
    
    //documentation view
    KDDocumentIndicatorView *documentationView = (KDDocumentIndicatorView *)[self viewWithTag:KD_TAG_STATUSCELL_DOCUMENTATION];
    if(documentationView) {
        originY += KD_STATUSCELL_V_SPACING;
        
        documentationView.frame = CGRectMake(KD_STATUSCELL_H_PADDING, originY, self.frame.size.width - 2 * KD_STATUSCELL_H_PADDING, [KDDocumentIndicatorView heightForDocumentsCount:status_.attachments.count]);
        
        originY += documentationView.frame.size.height;
    }
    
    // bottom padding
    originY += KD_STATUSCELL_V_PADDING;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, originY);
    
//    UIImageView *separatorView = (UIImageView *)[self viewWithTag:KD_TAG_STATUSCELL_SEPERATORVIEW];
//    if(!separatorView) {
//        separatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        UIImage *image = [UIImage imageNamed:@"home_page_cell_separator_bg.png"];
//        [separatorView setImage:[image stretchableImageWithLeftCapWidth:image.size.width * 0.5f topCapHeight:image.size.height * 0.5f]];
//        separatorView.tag = KD_TAG_STATUSCELL_SEPERATORVIEW;
//        [self addSubview:separatorView];
//        [separatorView release];
//    }
//    separatorView.frame = CGRectMake(KD_STATUSCELL_H_PADDING, self.frame.size.height - 1.0f, self.frame.size.width - 2 * KD_STATUSCELL_H_PADDING, 1.0);
}

- (void)loadThumbnailViewIfExists {
    KDThumbnailView2 *thumb = (KDThumbnailView2 *)[self viewWithTag:KD_TAG_STATUSCELL_THUMBNAILVIEW];
    if(thumb && thumb.imageDataSource) {
        [thumb setLoadThumbnail:YES];
    }
}

#pragma mark - KDDocumentIndicatorViewDelegate Methods
- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showProgressModalViewController:attachment inStatus:status_ sender:self];
}

- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div
{
    [[KDDefaultViewControllerContext defaultViewControllerContext] showAttachmentViewController:status_ sender:self];
}

@end
