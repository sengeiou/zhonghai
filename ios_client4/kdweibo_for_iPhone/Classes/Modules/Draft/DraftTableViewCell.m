//
//  DraftViewControllerCell.m
//  TwitterFon
//
//  Created by kingdee on 11-6-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DraftTableViewCell.h"
#import "KDDraft.h"
#import "ResourceManager.h"

@interface DraftTableViewCell ()

@property (nonatomic, retain) UILabel *creationDateLabel;
@property (nonatomic, retain) UILabel *draftTypeLabel;

@property (nonatomic, retain) UILabel *contentLabel;
@property (nonatomic, retain) UIImageView *imageAttachmentImageView;
@property (nonatomic, retain) UIImageView *videoAttachmentImageView;

@property (nonatomic, retain) UIImageView *forwardImageView;
@property (nonatomic, retain) UILabel *forwardContentLabel;

@property (nonatomic, retain) UIImageView *separatorImageView;

@end


@implementation DraftTableViewCell

@dynamic draft;

@synthesize creationDateLabel=creationDateLabel_;
@synthesize draftTypeLabel=draftTypeLabel_;

@synthesize contentLabel=contentLabel_;
@synthesize imageAttachmentImageView=imageAttachmentImageView_;

@synthesize forwardImageView=forwardImageView_;
@synthesize forwardContentLabel=forwardContentLabel_;

@synthesize separatorImageView=separatorImageView_;
@synthesize sendingProgress=sendingProgress_;

- (void) setupDraftCell {
    // draft type label
    draftTypeLabel_ = [[UILabel alloc]initWithFrame:CGRectZero];
    draftTypeLabel_.backgroundColor = [UIColor clearColor];
    draftTypeLabel_.font = [UIFont boldSystemFontOfSize:16];
    
    [self.contentView addSubview:draftTypeLabel_];
    
    sendingLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    sendingLabel.backgroundColor = [UIColor clearColor];
    sendingLabel.font = [UIFont boldSystemFontOfSize:12];
    sendingLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:sendingLabel];
    
    [self setIsSending:NO];
    
    sendingProgress_ = [[KDProgressIndicatorView alloc]initWithFrame:CGRectZero];
    sendingProgress_.backgroundColor = [UIColor clearColor];
    sendingProgress_.hidden = YES;
    [self.contentView addSubview:sendingProgress_];
    
    // creation date label
    creationDateLabel_ = [[UILabel alloc]initWithFrame:CGRectZero];
    creationDateLabel_.backgroundColor = [UIColor clearColor];
    creationDateLabel_.textAlignment = NSTextAlignmentRight;
    creationDateLabel_.font = [UIFont systemFontOfSize:11];
    creationDateLabel_.textColor = UIColorFromRGB(0x5d6772);
    
    [self.contentView addSubview:creationDateLabel_];
    
    // content label
    contentLabel_ = [[UILabel alloc]initWithFrame:CGRectZero];
    contentLabel_.backgroundColor = [UIColor clearColor]; 
    contentLabel_.font = [UIFont systemFontOfSize:13];
    contentLabel_.textColor = UIColorFromRGB(0x1c232a);
    contentLabel_.numberOfLines = 0;
    
    [self.contentView addSubview:contentLabel_];
           
    // image attachement background image view
    UIImage *image = [UIImage imageNamed:@"phote_icon_v2.png"];
    imageAttachmentImageView_ = [[UIImageView alloc]initWithImage:image];
    imageAttachmentImageView_.hidden = YES;
    [imageAttachmentImageView_ sizeToFit];
    
    [self.contentView addSubview:imageAttachmentImageView_];
    
    _videoAttachmentImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_icon_v2.png"]];
    _videoAttachmentImageView.hidden = YES;
    [_videoAttachmentImageView sizeToFit];
    
    [self.contentView addSubview:_videoAttachmentImageView];
    
    // forward content background image view
    forwardImageView_ = [[UIImageView alloc] initWithImage:[ResourceManager repostImage]];
    forwardImageView_.hidden = YES;
    
    [self.contentView addSubview:forwardImageView_];
    
    // forward content label
    forwardContentLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    forwardContentLabel_.backgroundColor = [UIColor clearColor];
    forwardContentLabel_.textColor = UIColorFromRGB(0x1c232a);
    forwardContentLabel_.font = [UIFont systemFontOfSize:13];
    forwardContentLabel_.numberOfLines = 20;
    forwardContentLabel_.hidden = YES;
    
    [self.contentView addSubview:forwardContentLabel_];
    
    //groupName Label
    groupNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    groupNameLabel_.backgroundColor = [UIColor clearColor];
    groupNameLabel_.textColor = [UIColor darkGrayColor];
    groupNameLabel_.font = [UIFont systemFontOfSize:10.0f];
//    groupNameLabel_.numberOfLines =
    
    [self.contentView addSubview:groupNameLabel_];
    
    [self.contentView bringSubviewToFront:sendingProgress_];
    
    // seprator image view
    separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_separator.png"]];
    [self.contentView addSubview:separatorImageView_];
    
    self.contentView.backgroundColor = [ResourceManager defaultRowBackGroudColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        draft_ = nil;
        
        [self setupDraftCell];
    }
    
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    CGFloat offsetX = 10.0;
    CGFloat pw = (super.contentView.bounds.size.width - 2*offsetX) * 0.5;
    
    CGRect rect = CGRectMake(offsetX, 5.0, pw, 18.0);
    draftTypeLabel_.frame = rect;
    
    rect.origin.x = rect.origin.x + rect.size.width;
    sendingLabel.frame = rect;
    
//    rect.origin.x = rect.origin.x + rect.size.width + 10.0f;
//    sendingProgress_.frame = rect;
    
    rect = creationDateLabel_.bounds;
    rect.origin = CGPointMake(super.contentView.bounds.size.width - rect.size.width - 10.0, 8.0);
    creationDateLabel_.frame = rect;
    
    rect = _videoAttachmentImageView.bounds;
    rect.origin = CGPointMake(creationDateLabel_.frame.origin.x - rect.size.width - 5.0, 8.0);
    imageAttachmentImageView_.frame = rect;
    _videoAttachmentImageView.frame = rect;
    
    contentLabel_.frame = [draft_ textBoundsByType:0];
    separatorImageView_.frame = CGRectMake(0,self.bounds.size.height-2, 320, 2);
    
    if (draft_.commentForStatusId != nil) {
        CGRect rcRepost = [draft_ textBoundsByType:1];
        forwardImageView_.frame = rcRepost;
        
        rcRepost=CGRectOffset(rcRepost,10,10);
        rcRepost.size.height-=20;
        rcRepost.size.width-=20;
        forwardContentLabel_.frame=rcRepost;
    }
    
    if(draft_.groupId && draft_.groupId.length > 0) {
        CGSize size = [groupNameLabel_.text sizeWithFont:[UIFont systemFontOfSize:10.0f]];
        groupNameLabel_.frame = CGRectMake(offsetX + 8.0f, self.bounds.size.height - 10.0f - size.height, size.width, size.height);
    }
}

- (NSString *) draftTypeAsString {
    NSString *title = nil;
    
    if(draft_.groupId && draft_.groupId.length > 0)
        title = ASLocalizedString(@"DraftTableViewCell_tips_1");
    else
        title = @"";
    
    switch (draft_.type) {
        case KDDraftTypeNewStatus:
            title = [NSString stringWithFormat:@"%@%@", title, ASLocalizedString(@"DraftTableViewCell_tips_2")];
            break;
            
        case KDDraftTypeForwardStatus:
            title = ASLocalizedString(@"DraftTableViewCell_tips_3");
            break;
            
        case KDDraftTypeCommentForStatus:
            title = [NSString stringWithFormat:@"%@%@", title, ASLocalizedString(@"DraftTableViewCell_tips_4")];
            break;
            
        case KDDraftTypeCommentForComment:
            title = [NSString stringWithFormat:@"%@%@", title, ASLocalizedString(@"DraftTableViewCell_tips_4")];
            break;
            
        default:
            break;
    }
    
    return title;
}

- (void) refresh {
    creationDateLabel_.text = [draft_ getCreationDateAsString];
    [creationDateLabel_ sizeToFit];
    
    draftTypeLabel_.text = [self draftTypeAsString];
    contentLabel_.text = draft_.content;
    imageAttachmentImageView_.hidden = ![draft_ hasImages] || [draft_ hasVideo];
    _videoAttachmentImageView.hidden = ![draft_ hasVideo];
    
    if(draft_.commentForStatusId && draft_.originalStatusContent) {
        forwardImageView_.hidden = NO;
        forwardContentLabel_.hidden = NO;
        
        NSString *text = nil;
        
        if(draft_.originalStatusContent.length <= 60)
            text = draft_.originalStatusContent;
        else {
            text = [NSString stringWithFormat:@"%@...", [draft_.originalStatusContent substringToIndex:59]];
        }
        
        forwardContentLabel_.text = text;
        
    } else {
        forwardImageView_.hidden = YES;
        forwardContentLabel_.hidden = YES;
    }
    
    if(draft_.groupId) {
        groupNameLabel_.text = [NSString stringWithFormat:@"%@: %@", ASLocalizedString(@"DraftTableViewCell_tips_5"), draft_.groupName];
        
    } else {
        groupNameLabel_.text = nil;
    }
    
    [self setNeedsLayout];
}

- (void) setDraft:(KDDraft *)draft {
    if(draft_ != draft){
//        [draft_ release];
        draft_ = draft;// retain];
        [self refresh];
    }
}

- (KDDraft *) draft {
    return draft_;
}

- (void)setIsSending:(BOOL)isSending
{
    _isSending = isSending;
    sendingLabel.hidden = !isSending;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(draft_);
    //KD_RELEASE_SAFELY(_videoAttachmentImageView);
    //KD_RELEASE_SAFELY(creationDateLabel_);
    //KD_RELEASE_SAFELY(draftTypeLabel_);
    
    //KD_RELEASE_SAFELY(contentLabel_);
    //KD_RELEASE_SAFELY(imageAttachmentImageView_);
    
    //KD_RELEASE_SAFELY(forwardImageView_);
    //KD_RELEASE_SAFELY(forwardContentLabel_);
    
    //KD_RELEASE_SAFELY(groupNameLabel_);
    
    //KD_RELEASE_SAFELY(separatorImageView_);
    
    //[super dealloc];
}
 
@end

