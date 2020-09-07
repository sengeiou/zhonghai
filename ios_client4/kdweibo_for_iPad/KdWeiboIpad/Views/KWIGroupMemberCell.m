//
//  KWIGroupMemberCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIGroupMemberCell.h"

#import "UIImageView+WebCache.h"

#import "KWIAvatarV.h"

#import "KDUser.h"

#import "KDcommonHeader.h"
@implementation KWIGroupMemberCell
{
    IBOutlet UILabel *_jobTitleV;
    IBOutlet UILabel *_usernameV;    
    IBOutlet UIButton *_sendDMBtn;
    KWIAvatarV *_avatarV;
}

@synthesize user = _user;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        _avatarV = [[KWIAvatarV viewForUrl:nil size:40] retain];
        [self addSubview:_avatarV];
    }
    return self;
}

+ (KWIGroupMemberCell *)cell
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWIGroupMemberCell *cell = (KWIGroupMemberCell *)[nib objectAtIndex:0];  

    //return [cell initWithUser:user];
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _avatarV.frame = CGRectMake((self.frame.size.height-40)*0.5, (self.frame.size.height-40)*0.5, 40, 40);
}
- (void)setUser:(KDUser *)user {
    if (_user != user) {
        [_user release];
        _user = [user retain];
        
        _usernameV.text = user.username;
        
        [_avatarV downloadImageWithUrl:user.profileImageUrl];
        NSString *jobstr = nil;
        KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
        KDUserManager *userManager = [[KDManagerContext globalManagerContext]userManager];
        if ([communityManager isCompanyDomain]) {
            jobstr = [NSString stringWithFormat:@"%@ / %@", user.department, user.jobTitle];
            _jobTitleV.text = [jobstr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /"]];
        }else {
            _jobTitleV.text = user.companyName;
        }
        if ([userManager.currentUserId isEqualToString:user.userId]) {
            _sendDMBtn.hidden = YES;
        }else {
            _sendDMBtn.hidden = NO;
        }
    }
    
}
- (id)initWithUser:(KDUser *)user
{
    self.user = user;
    
    _usernameV.text = user.username;

    [_avatarV downloadImageWithUrl:user.profileImageUrl];
  
    
    NSString *jobstr = nil;

    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
    KDUserManager *userManager = [[KDManagerContext globalManagerContext]userManager];
    if ([communityManager isCompanyDomain]) {
               jobstr = [NSString stringWithFormat:@"%@ / %@", user.department, user.jobTitle];
                _jobTitleV.text = [jobstr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /"]];
    }else {
         _jobTitleV.text = user.companyName;
    }
    if ([userManager.currentUserId isEqualToString:user.userId]) {
        _sendDMBtn.hidden = YES;
    }else {
        _sendDMBtn.hidden = NO;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_jobTitleV release];
    [_avatarV release];
    [_usernameV release];
    [_sendDMBtn release];
    [super dealloc];
}

- (IBAction)_onMsgBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWThread.new" 
                                                        object:nil 
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:self.user] 
                                                                                           forKey:@"to"]];
}

@end
