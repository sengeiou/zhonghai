//
//  KWICommentMPCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/16/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWICommentMPCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"


#import "KWIStatusContent.h"
#import "KWIPeopleVCtrl.h"
#import "KWIAvatarV.h"

#import "KDCommentMeStatus.h"
#import "KDUser.h"

@interface KWICommentMPCell ()

@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIView *inrCtnPh;

@property (retain, nonatomic) KWIStatusContent *inrCtn;

@end

@implementation KWICommentMPCell

@synthesize data = _data;
@synthesize avatarV = _avatarV;
@synthesize usernameV = _usernameV;
@synthesize inrCtnPh = _inrCtnPh;
@synthesize inrCtn = _inrCtn;

+ (KWICommentMPCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:self.description bundle:nil] autorelease];
    KWICommentMPCell *cell = (KWICommentMPCell *)tmpVCtrl.view; 
    
    //cell.avatarV.layer.cornerRadius = 4;
    //cell.avatarV.layer.masksToBounds = YES;
    
    return cell;
}

- (void)dealloc {
    [_avatarV release];
    [_usernameV release];
    [_inrCtnPh release];
    
    [_data release];
    [_inrCtn release];
    
    [super dealloc];
}

#pragma mark -
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        static UIColor *sbg;
        if (nil == sbg) {
            UIImage *sbgimg = [UIImage imageNamed:@"mLiBgOn.png"];
            sbg = [[UIColor colorWithPatternImage:sbgimg] retain];
        }
        self.backgroundColor = sbg;
    } else {        
        self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark -
- (void)setData:(KDCommentMeStatus *)data
{
    [_data release];
    _data = [data retain];
    
    //[self.avatarV setImageWithURL:[NSURL URLWithString:data.author.profile_image_url]];
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:_data.author.profileImageUrl size:48];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    [avatarV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    [self.usernameV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    
    self.usernameV.text = _data.author.username;
    CGRect usernameFrame = self.usernameV.frame;
    usernameFrame.size.width = [_data.author.username sizeWithFont:[UIFont systemFontOfSize:17]].width;
    self.usernameV.frame = usernameFrame;
    
    //self.inrCtn = [KWIStatusContent viewForComment:_data frame:self.inrCtnPh.frame];
    
    self.inrCtn = [KWIStatusContent viewForCommentMeStatus:_data frame:self.inrCtnPh.frame];
    [self.inrCtnPh removeFromSuperview];
    self.inrCtnPh = nil;
    [self addSubview:self.inrCtn];    
    
    CGRect frame = self.frame;
    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
    self.frame = frame;
}

- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}


@end
