//
//  KWIPeopleCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIPeopleCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

#import "NSError+KWIExt.h"

#import "KWIPeopleVCtrl.h"
#import "KWIAvatarV.h"

#import "KDUser.h"
#import "KDCommonHeader.h"

@interface KWIPeopleCell ()

@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UILabel *jobtitleV;
@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UIButton *followBtn;
@property (retain, nonatomic) IBOutlet UIButton *unfollowBtn;

@end

@implementation KWIPeopleCell

@synthesize usernameV;
@synthesize jobtitleV;
@synthesize avatarV = _avatarV;
@synthesize followBtn;
@synthesize unfollowBtn;

@synthesize data = _data;

+ (KWIPeopleCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:@"KWIPeopleCell" bundle:nil] autorelease];
    KWIPeopleCell *cell = (KWIPeopleCell *)tmpVCtrl.view; 
    
    //cell.avatarV.layer.cornerRadius = 4;
    //cell.avatarV.layer.masksToBounds = YES;
    
    return cell;
}

- (void)dealloc {
    [_data release];
    
    [usernameV release];
    [jobtitleV release];
    [_avatarV release];
    [followBtn release];
    [unfollowBtn release];
    [super dealloc];
}

#pragma mark -
- (void)setData:(KDUser *)data
{
    [_data release];
    _data = [data retain];

    self.usernameV.text = data.username;
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:data.profileImageUrl size:40];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    NSString *jobstr = nil;
    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
    KDUserManager *userManager = [[KDManagerContext globalManagerContext]userManager];
    if ([communityManager isCompanyDomain]) {
        if (_data.department.length >0 && _data.jobTitle.length >0) {
            jobstr = [NSString stringWithFormat:@"%@ / %@", _data.department, _data.jobTitle];
        }else {
            jobstr = @"";
        }
        self.jobtitleV.text = [jobstr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /"]];
    }else {
        self.jobtitleV.text = _data.companyName;
    }
    NSString *currentUserId = userManager.currentUserId;
    if (![currentUserId isEqualToString:_data.userId]) {

        KDQuery *query = [KDQuery query];
        [[query setParameter:@"user_a" stringValue:currentUserId]
         setParameter:@"user_b" stringValue:_data.userId];
        
        __block KWIPeopleCell *pvc = [self retain];
        KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
            if([response isValidResponse]) {
                if (results != nil) {
                    if ([(NSNumber *)results boolValue]) {
                        pvc.unfollowBtn.hidden = NO;
                    }else {
                         pvc.followBtn.hidden = NO;
                    }
                }
            } else {
                if (![response isCancelled]) {
                }
            }

            [pvc release];
        };
        
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/friendships/:exists" query:query
                                     configBlock:nil completionBlock:completionBlock];
    }
}

- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (void)_handleFriendshipResponse:(KDResponseWrapper *)response withResults:(id)results {
    if([response isValidResponse]) {
        if (results != nil) {
            self.data = results;
            self.followBtn.hidden = YES;
            
            self.unfollowBtn.enabled = YES;
            self.unfollowBtn.hidden = NO;
            // update current user info into database
            [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                [userDAO saveUser:self.data database:fmdb];
                
                return nil;
                
            } completionBlock:nil];
        }
    } else {
        if (![response isCancelled]) {
            self.followBtn.enabled = YES;
        }
    }
}
- (IBAction)_onFollowBtnTapped:(id)sender 
{
    self.followBtn.enabled = NO;

    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.data.userId];
    
    __block KWIPeopleCell *pvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                pvc.data = results;

                pvc.followBtn.hidden = YES;
                pvc.unfollowBtn.enabled = YES;
                pvc.unfollowBtn.hidden = NO;
                // update current user info into database
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveUser:pvc.data database:fmdb];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
        }
        else {
            if (![response isCancelled]) {
                pvc.followBtn.enabled = YES;
            }
        }
        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:create" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (IBAction)_onUnfollowBtnTapped:(id)sender 
{
    self.unfollowBtn.enabled = NO;
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.data.userId];
    
    __block KWIPeopleCell *pvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                pvc.data = results;
                
                pvc.unfollowBtn.hidden = YES;
                pvc.followBtn.enabled = YES;
                pvc.followBtn.hidden = NO;

                // update current user info into database
                [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                    id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                    [userDAO saveUser:pvc.data database:fmdb];
                    
                    return nil;
                    
                } completionBlock:nil];
            }
        }
        else {
            if (![response isCancelled]) {
                pvc.followBtn.enabled = YES;
            }
        }
        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/friendships/:destroy" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

@end
