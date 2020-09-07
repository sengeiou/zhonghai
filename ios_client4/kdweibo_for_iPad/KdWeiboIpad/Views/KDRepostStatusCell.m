//
//  KDRepostStatusCell.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-9.
//
//

#import "KDRepostStatusCell.h"
#import "KWIAvatarV.h" 
#import "KDManagerContext.h"
#import "KDStatusView.h"
@implementation KDRepostStatusCell{
    
        
        KWIAvatarV *avatarView_;
        
        KDStatusView *statusView_;
        UIImageView *separatorImageView_;
    
}
@synthesize repostedStatus = repostedStatus_;

+(KDRepostStatusCell *)cell {
    KDRepostStatusCell *cell = [[KDRepostStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return [cell autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        avatarView_ = [[KWIAvatarV viewForUrl:nil size:40] retain];
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
        [avatarView_ addGestureRecognizer:rgzr];
        [rgzr release];
        
        [self addSubview:avatarView_];
    
        
        separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentCellBorder.png"]];
        [self addSubview:separatorImageView_];

        
    }
    return self;
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
    
    frame = self.bounds;
    frame.origin.y = CGRectGetHeight(frame) - 1;
    frame.size.height = 1;
    separatorImageView_.frame = frame;
    
}

- (void)setRepostedStatus:(KDStatus *)repostedStatus{
    if (repostedStatus_ == repostedStatus) {
        return;
    }
    [repostedStatus_ release];
    repostedStatus_ = [repostedStatus retain];
    
    [avatarView_ downloadImageWithUrl:repostedStatus.author.thumbnailImageURL];
    
    KDLayouter *layouter = [KDRepostStatusLayouter layouter:repostedStatus constrainedWidth:0];
    statusView_ = [[layouter statusView] retain];
    [self addSubview:statusView_];
    
    if ([[KDManagerContext globalManagerContext].userManager isCurrentUserId:repostedStatus.author.userId]) {
        
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
