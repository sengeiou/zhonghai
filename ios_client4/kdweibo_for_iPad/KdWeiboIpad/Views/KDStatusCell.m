//
//  KDStatusCell.m
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-6.
//
//

#import "KDStatusCell.h"

@implementation KDStatusCell
@synthesize avatarView = avatarView_;
@synthesize status = status_;
@synthesize statusView  = statusView_;
@synthesize nameLabel = nameLabel_;
@synthesize layouter = layouter_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        KDLayouterFatherView *view = [[KDLayouterFatherView alloc] initWithFrame:CGRectZero];
        [self  addSubview:view];
        self.statusView = view;
        [view release];
        
        KWIAvatarV *theAvatarView = [KWIAvatarV viewForUrl:nil size:48];
        [self  addSubview:theAvatarView];
        self.avatarView = theAvatarView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        label.font = [UIFont systemFontOfSize:14];
        label.lineBreakMode = UILineBreakModeMiddleTruncation;
        label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:label];
        self.nameLabel = label;
        [label release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStatus:(KDStatus *)status {
    if (status_ != status) {
        [status_ release];
        status_ = [status retain];
        [avatarView_ downloadImageWithUrl:status.author.thumbnailImageURL];
        nameLabel_.text =status.author.screenName;
        [self.statusView reset];
        KDLayouter *layouter = [status propertyForKey:KD_STATUS_LAYOUTER_PROPERTY_KEY];
        if (layouter) {
            self.statusView.layouter = layouter;
            self.layouter = layouter;
        }
        [self setNeedsLayout];
    }
    
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectOffset(self.avatarView.bounds, 10, 10);
    CGRect frame = self.avatarView.frame;
    frame.origin.x = frame.origin.x + frame.size.width + 10;
    frame.size = self.layouter.frame.size;
    self.statusView.frame = frame;
    frame = self.avatarView.frame;
    frame.origin.y = frame.origin.x + CGRectGetHeight(frame);
    frame.size.height = 20;
    
    self.nameLabel.frame = frame;
}
- (void)dealloc {
    KD_RELEASE_SAFELY(status_);
    KD_RELEASE_SAFELY(avatarView_);
    KD_RELEASE_SAFELY(statusView_);
    KD_RELEASE_SAFELY(layouter_);
    KD_RELEASE_SAFELY(nameLabel_);
    [super dealloc];
}
@end
