//
//  KDMessageCell.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 12-11-6.
//
//

#import "KDMMessageCell.h"

@interface KDMMessageCell()

@property(nonatomic,retain)KDStatusView *statusView;
@end

@implementation KDMMessageCell {
    BOOL shouldDisplayTimeStamp_;
}
@synthesize avatarView = avatarView_;
@synthesize message = message_;
@synthesize nameLabel = nameLabel_;
@synthesize statusView = statusVeiw_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        KWIAvatarV *theAvatarView = [KWIAvatarV viewForUrl:nil size:40];
        [self  addSubview:theAvatarView];
        self.avatarView = theAvatarView;
      
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
        label.font = [UIFont systemFontOfSize:14];
        label.lineBreakMode = UILineBreakModeMiddleTruncation;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        self.nameLabel = label;
        [label release];
    
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(KDDMMessage *)message shouldDisplayTimeStamp:(BOOL) should {
    self.message = message;
    if (self.message) {
        [self.avatarView downloadImageWithUrl:message.sender.thumbnailImageURL];
        self.nameLabel.text = self.message.sender.screenName;
        shouldDisplayTimeStamp_ = should;
        KDLayouter *layouter = [KDDMMessageLayouter layouter:self.message constrainedWidth:0 shouldDisplayTimeStamp:should];
        self.statusView = [layouter statusView];
        [self addSubview:statusVeiw_];
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    CGRect frame;
    if (shouldDisplayTimeStamp_) {
        frame = CGRectOffset(self.avatarView.bounds, 10, 32);
    }else {
        frame = CGRectOffset(self.avatarView.bounds, 10, 0);
    }
    self.avatarView.frame = frame;

    frame.origin.y = CGRectGetMaxY(frame);
    frame.size = self.nameLabel.frame.size;
    self.nameLabel.frame = frame;
    
    
    frame = self.statusView.frame;
    frame.origin.x = CGRectGetMaxX(self.avatarView.frame) +10;
    self.statusView.frame = frame;
    
}
- (KDDMMessage *)message {
    return message_;
}
- (void)dealloc {
    
    KD_RELEASE_SAFELY(avatarView_);
    KD_RELEASE_SAFELY(statusVeiw_);
    KD_RELEASE_SAFELY(message_);
    KD_RELEASE_SAFELY(nameLabel_);
    [super dealloc];
}
@end
