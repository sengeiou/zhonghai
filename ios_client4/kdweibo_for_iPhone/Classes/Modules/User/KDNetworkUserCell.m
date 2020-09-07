//
//  NetworkUserCell.m
//  TwitterFon
//
//  Created by apple on 10-11-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"

#import "KDNetworkUserCell.h"
#import "KDStatus.h"
#import "UIViewAdditions.h"

@implementation KDNetworkUserCell

- (void) _setupNetworkUserCell {
	statusLabel_ = [[UILabel alloc]initWithFrame:CGRectMake(62,34,238,12)];
    statusLabel_.backgroundColor = [UIColor clearColor];
	statusLabel_.font = [UIFont systemFontOfSize:12];
	statusLabel_.textColor = [UIColor grayColor];
    statusLabel_.highlightedTextColor = [UIColor whiteColor];
    
    [self.contentView addSubview:statusLabel_];
    
//    cellAccessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3"]];
//    cellAccessoryImageView_.highlightedImage = [UIImage imageNamed:@"smallTriangle.png"];
//    [super.contentView addSubview:cellAccessoryImageView_];
    
    self.separatorView.hidden = YES;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self _setupNetworkUserCell];
        [self setBackgroundView:[UIView strokeCellSeparatorBgView]];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
//    cellAccessoryImageView_.frame = CGRectMake(self.bounds.size.width - cellAccessoryImageView_.image.size.width -15, (self.bounds.size.height - cellAccessoryImageView_.image.size.height)/2.0, cellAccessoryImageView_.image.size.width, cellAccessoryImageView_.image.size.height);
    
}
- (void) setUser:(KDUser *)user {
    [super setUser:user];
    
    statusLabel_.text= (user.latestStatus != nil) ? user.latestStatus.text : @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    statusLabel_.highlighted = selected;
//    cellAccessoryImageView_.highlighted = selected;
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(statusLabel_);
//    //KD_RELEASE_SAFELY(cellAccessoryImageView_);
    //[super dealloc];
}

@end
