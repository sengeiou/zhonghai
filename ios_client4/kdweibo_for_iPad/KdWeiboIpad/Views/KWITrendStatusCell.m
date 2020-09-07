//
//  KWITrendStatusCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/4/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITrendStatusCell.h"

#import "UIImageView+WebCache.h"

#import "KDStatus.h"
#import "KWIPeopleVCtrl.h"
#import "KWIStatusContent.h"
#import "KWIPeopleVCtrl.h"
#import "KWIAvatarV.h"

@interface KWITrendStatusCell ()

@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIView *inrCtnPh;
@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) KWIStatusContent *inrCtn;

@end

@implementation KWITrendStatusCell
@synthesize usernameV;
@synthesize inrCtnPh;
@synthesize avatarV = _avatarV;
@synthesize inrCtn = _inrCtn;
@synthesize data = _data;

+ (KWITrendStatusCell *)cellWithStatus:(KDStatus *)status
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWITrendStatusCell *cell = (KWITrendStatusCell *)[nib objectAtIndex:0];    
    
    [cell setStatus:status];
    
    return cell;
}

- (void)setStatus:(KDStatus *)status {
    self.data = status;
    
    self.usernameV.text = status.author.screenName;
    
    //[self.avatarV setImageWithURL:[NSURL URLWithString:status.author.profile_image_url]];
    //self.avatarV.userInteractionEnabled = YES;
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:status.author.profileImageUrl size:40];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    [avatarV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    
    self.inrCtn = [KWIStatusContent viewForStatus:status 
                                            frame:self.inrCtnPh.frame
                                  contentFontSize:14];
    [self.inrCtnPh removeFromSuperview];
    self.inrCtnPh = nil;
    [self addSubview:self.inrCtn];
    
    CGRect frame = self.frame;
    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
    self.frame = frame;
}

- (void)dealloc {
    [_avatarV release];
    [super dealloc];
}

- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}
@end
