//
//  KWIPeopleVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIPeopleVCtrl.h"

#import <QuartzCore/QuartzCore.h>
#import "KDCommonHeader.h"
#import "UIImageView+WebCache.h"

#import "UIDevice+KWIExt.h"
#import "NSError+KWIExt.h"

#import "KWIFollowingsVCtrl.h"
#import "KWIFollowersVCtrl.h"
#import "KWIPeopleStreamVCtrl.h"
#import "KWIFullImgVCtrl.h"
#import "KWIProfileTrendLsVCtrl.h"
#import "KWIAvatarV.h"
#import "KDUser.h"
#import "iToast.h"

@interface KWIPeopleVCtrl ()

@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIView *oprtsV;

@property (retain, nonatomic) IBOutlet UIButton *navFollowingsBtn;
@property (retain, nonatomic) IBOutlet UIButton *navFollowersBtn;
@property (retain, nonatomic) IBOutlet UIButton *navStatusesBtn;
@property (retain, nonatomic) IBOutlet UIButton *navTrendsBtn;
@property (retain, nonatomic) IBOutlet UIButton *followBtn;
@property (retain, nonatomic) IBOutlet UIButton *unfollowBtn;
@property (retain, nonatomic) IBOutlet UIButton *mentionBtn;

@property (retain, nonatomic) IBOutlet UIView *lowerhalfV;
@property (retain, nonatomic) KWIFollowingsVCtrl *followingsVCtrl;
@property (retain, nonatomic) KWIFollowersVCtrl *followersVCtrl;
@property (retain, nonatomic) KWIPeopleStreamVCtrl *peoplestreamVCtrl;
@property (retain, nonatomic) KWIProfileTrendLsVCtrl *trendsVCtrl;

@property (retain, nonatomic) KDUser *data;

@property (retain, nonatomic) KWIFullImgVCtrl *imgVCtrl;

@end

@implementation KWIPeopleVCtrl
{
    IBOutlet DTAttributedTextContentView *_jobInfV;
    UIViewController *_curLowerHalfVCtrl;
    UIButton *_curNavBtn;
    BOOL _isRelationshipConfigured;
    IBOutlet UIImageView *_bgv;
    IBOutlet UIImageView *_hdBgV;
    BOOL _isProfile;
    
    IBOutlet UILabel *_statusesLb;
    IBOutlet UILabel *_followingsLb;
    IBOutlet UILabel *_followersLb;
    IBOutlet UILabel *_trendsLb;    
    IBOutlet UIButton *_followersBtn;
    
    BOOL _isShadowDisabled;
}

@synthesize avatarV = _avatarV;
@synthesize usernameV = _usernameV;
@synthesize oprtsV = _oprtsV;
@synthesize navFollowingsBtn = _navFollowingsBtn;
@synthesize navFollowersBtn = _navFollowersBtn;
@synthesize navStatusesBtn = _navStatusesBtn;
@synthesize navTrendsBtn = _navTrendsBtn;
@synthesize followBtn = _followBtn;
@synthesize unfollowBtn = _unfollowBtn;
@synthesize mentionBtn = _mentionBtn;
@synthesize lowerhalfV = _lowerhalfV;
@synthesize followingsVCtrl = _followingsVCtrl;
@synthesize followersVCtrl = _followersVCtrl;
@synthesize peoplestreamVCtrl = _peoplestreamVCtrl;
@synthesize trendsVCtrl = _trendsVCtrl;
@synthesize data = _data;
@synthesize imgVCtrl = _imgVCtrl;
@synthesize tableView = _tableView;

+ (KWIPeopleVCtrl *)vctrlWithUser:(KDUser *)user
{
    return [[[self alloc] initWithUser_:user] autorelease];
}

+ (KWIPeopleVCtrl *)vctrlForProfile
{
    return [[[self alloc] initForProfile] autorelease];
}

- (id)initWithUser_:(KDUser *)user
{
    self = [super initWithNibName:self.class.description bundle:nil];
    if (self) {
        self.data = user;
        
        if (!_isProfile) {
            NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
            [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
            [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
        }
    }
    return self;
}

- (id)initForProfile
{
    _isProfile = YES;
    KDUser *user = [[[KDUser alloc] init] autorelease];
    KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
    user.userId = userManager.currentUserId;
    // only give user.id_ to force reload to ensure user attrs update between network switching
    self = [self initWithUser_:user];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView release];
    [_avatarV release];
    [_usernameV release];
    
    [_data release];
    [_imgVCtrl release];
    
    [_navFollowingsBtn release];
    [_navFollowersBtn release];
    [_navStatusesBtn release];
    [_lowerhalfV release];
    [_followingsVCtrl release];
    [_followersVCtrl release];
    [_peoplestreamVCtrl release];
    [_followBtn release];
    [_unfollowBtn release];
    [_oprtsV release];
    [_mentionBtn release];
    [_navTrendsBtn release];
    [_jobInfV release];
    [_bgv release];
    [_statusesLb release];
    [_followingsLb release];
    [_followersLb release];
    [_trendsLb release];
    [_hdBgV release];
    [_followersBtn release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_isProfile) {
        [self _configProfileMod];
    } else {
        [self _configBgVForCurrentOrientation];
    }
    
    // make sure only when view have loaded we populate it with data
    // we dont sure of that when we call setData
    if (self.data) {
        if (self.data.createdAt) {
            [self _configure];
        } else {
//            KWEngine *api = [KWEngine sharedEngine];
//            [api get:@"users/show.json" 
//              params:[NSDictionary dictionaryWithObject:self.data.id_ forKey:@"user_id"] 
//           onSuccess:^(NSDictionary *dict) {
//               self.data = [KWUser userFromDict:dict];
//               [self performSelector:@selector(_configure) withObject:nil afterDelay:0.25];
//           }
//             onError:^(NSError *error) {
//                 [error KWIGeneralProcess];
//             }];
            KDQuery *query = nil;
            if (self.data.userId) {
               query  = [KDQuery queryWithName:@"user_id" value:self.data.userId];
            }
            else if (self.data.screenName) {
                query  = [KDQuery queryWithName:@"screen_name" value:self.data.screenName];
            }
            if (query == nil) {
                return;
            }
            
            __block KWIPeopleVCtrl *vc = [self retain];
            KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
                if ([response isValidResponse]) {
                    if (results != nil) {
                        vc.data = results;
                        [vc performSelector:@selector(_configure) withObject:nil afterDelay:0.25];
                        // update current user
                        [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                            id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                            [userDAO saveUser:(KDUser *)results database:fmdb];
                            
                            return nil;
                            
                        } completionBlock:nil];
                    }
                }else {
                    if (![response isCancelled]) {
                        NSString *errorMessage = nil;
                        NSDictionary *jsonObject = [response responseAsJSONObject];
                        if (jsonObject != nil) {
                            NSString *status = [jsonObject stringForKey:@"message"];
                            NSRange range = [status rangeOfString:@"user id or screen_name not found"];
                            if (range.location != NSNotFound) {
                                errorMessage = NSLocalizedString(@"该用户不存在", @"");
                            }
                        }
                        
                        if(errorMessage == nil){
                            errorMessage = NSLocalizedString(@"获取数据错误", @"");
                        }
                       [[iToast makeText:errorMessage] show];
                
                    }

                }
               
                
                // release current view controller
                [vc release];
            };
            
            [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/users/:show" query:query
                                         configBlock:nil completionBlock:completionBlock];
        }
    }
}

-(BOOL)isSelf {
    BOOL result = NO;
    KDUserManager *userManager = [[KDManagerContext globalManagerContext] userManager];
    if ([self.data.userId isEqualToString:userManager.currentUserId]) {
        result = YES;
    }
    return result;
}

- (void)viewDidUnload
{
    [self setAvatarV:nil];
    [self setUsernameV:nil];
    [self setNavFollowingsBtn:nil];
    [self setNavFollowersBtn:nil];
    [self setNavStatusesBtn:nil];
    [self setLowerhalfV:nil];
    [self setFollowBtn:nil];
    [self setUnfollowBtn:nil];
    [self setOprtsV:nil];
    [self setMentionBtn:nil];
    [self setNavTrendsBtn:nil];
    [_jobInfV release];
    _jobInfV = nil;
    self.tableView = nil;
    [_bgv release];
    _bgv = nil;
    [_statusesLb release];
    _statusesLb = nil;
    [_followingsLb release];
    _followingsLb = nil;
    [_followersLb release];
    _followersLb = nil;
    [_trendsLb release];
    _trendsLb = nil;
    [_hdBgV release];
    _hdBgV = nil;
    [_followersBtn release];
    _followersBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)_configure
{
    //KWEngine *api = [KWEngine sharedEngine];
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:self.data.profileImageUrl size:48];
    [avatarV replacePlaceHolder:_avatarV];
    self.avatarV = nil;
    
    for (UIButton *navBtn in [NSArray arrayWithObjects:self.navFollowersBtn, self.navFollowingsBtn, self.navStatusesBtn, self.navTrendsBtn, nil]) {
        navBtn.layer.cornerRadius = 4;
        navBtn.layer.masksToBounds = YES;
        [navBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithHexString:@"c3c3c3"]] forState:UIControlStateNormal];
        [navBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithHexString:@"df9f54"]] forState:UIControlStateSelected];
    }
    NSMutableDictionary *imginfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.data.profileImageUrl, @"thumbnail_pic", [NSString stringWithFormat:@"%@&spec=180", self.data.profileImageUrl], @"original_pic", [NSNumber numberWithInt:0], @"tag", nil];
    
    self.imgVCtrl = [KWIFullImgVCtrl vctrlWithImgs:[NSArray arrayWithObject:imginfo]];
    UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onAvatarTapped:)] autorelease];
    avatarV.userInteractionEnabled = YES;
    [avatarV addGestureRecognizer:tgr];
    
    self.usernameV.text = self.data.username;
    
    NSString *jobInfTpl = @"<span style=\"color:#333; font-size:16px; font-family:'STHeitiSC-Light';\">%@</span>";;
    NSString *jobInfStr;
    
    KDCommunityManager *communityManager = [[KDManagerContext globalManagerContext] communityManager];
    
    if ([communityManager isCompanyDomain]) {
        if (self.data.jobTitle.length) {
            jobInfStr = [NSString stringWithFormat:jobInfTpl, [NSString stringWithFormat:@"%@ / <span style=\"color:#666\">%@</span>", self.data.department, self.data.jobTitle]];
        } else {
            jobInfStr = [NSString stringWithFormat:@"<span style=\"color:#666; font-size:16px; font-family:'STHeitiSC-Light';\">%@</span>", self.data.department];
        }
    } else {
        jobInfStr = [NSString stringWithFormat:jobInfTpl, self.data.companyName];
    }
    NSAttributedString *jobAttrStr = [[[NSAttributedString alloc] initWithHTMLData:[jobInfStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                         baseURL:nil
                                                              documentAttributes:nil] autorelease];
    _jobInfV.attributedString = jobAttrStr;
    if ([self isSelf]) {
        self.oprtsV.hidden = YES;
    }
    

    [self.navFollowingsBtn setTitle:[NSString stringWithFormat:@"%d",self.data.friendsCount] forState:UIControlStateNormal];
    [self.navFollowersBtn setTitle:[NSString stringWithFormat:@"%d",self.data.followersCount] forState:UIControlStateNormal];
    [self.navStatusesBtn setTitle:[NSString stringWithFormat:@"%d",self.data.statusesCount] forState:UIControlStateNormal];
    
     NSString *curUserId = [[[KDManagerContext globalManagerContext] userManager] currentUserId];
    if (!_isRelationshipConfigured) {
        _isRelationshipConfigured = YES;        
        
        if (![self isSelf]) {
            CGRect frame = self.followBtn.frame;
            CGRect nameFrame = self.usernameV.frame;
            frame.origin.x = nameFrame.origin.x + nameFrame.size.width + 10;
            
//            [api get:@"friendships/exists.json" 
//              params:[NSDictionary dictionaryWithObjectsAndKeys:api.user.id_, @"user_a", self.data.id_, @"user_b", nil] 
//           onSuccess:^(NSDictionary *dict) {
//               if ([[dict objectForKey:@"friends"] boolValue]) {
//                   self.unfollowBtn.hidden = NO;
//               } else {
//                   self.followBtn.hidden = NO;
//               }
//           } 
//             onError:^(NSError *error) {
//                 [error KWIGeneralProcess];
//             }];
            
            KDQuery *query = [KDQuery query];
            [[query setParameter:@"user_a" stringValue:curUserId]
             setParameter:@"user_b" stringValue:self.data.userId];
            
            __block KWIPeopleVCtrl *pvc = [self retain];
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
    
//    [api get:@"users/followed_topic_num.json"
//      params:[NSDictionary dictionaryWithObject:api.user.id_ forKey:@"user_id"]
//   onSuccess:^(NSDictionary *result) {
//       [self.navTrendsBtn setTitle:[[result objectForKey:@"followed_topic_num"] stringValue] forState:UIControlStateNormal];
//   } 
//     onError:^(NSError *err) {
//         // silently fail
//     }];
    
   
    
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:curUserId];
    
    __block KWIPeopleVCtrl *pvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                //(pvc -> user).topicsCount = [(NSNumber *)results integerValue];
                [pvc.navTrendsBtn setTitle:[(NSNumber *)results stringValue] forState:UIControlStateNormal];
               
            }
        } else {
            if (![response isCancelled]) {
               
            }
        }
        
        
        // release current view controller
        [pvc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/users/:followedTopicNumber" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
    if (_isProfile) {
        [self onFollowersBtnTapped:_followersBtn];
    } else {
        [self performSelector:@selector(onStatusesBtnTapped:) withObject:self.navStatusesBtn afterDelay:0.2];
    }
}

- (void)_configProfileMod
{
    _bgv.hidden = YES;
    _hdBgV.hidden = YES;
    
    self.navTrendsBtn.hidden = NO;
    _trendsLb.hidden = NO;
    
    unsigned int idx = 0;
    for (UIButton *btn in [NSArray arrayWithObjects:self.navFollowersBtn, self.navFollowingsBtn, self.navStatusesBtn, self.navTrendsBtn, nil]) {
        CGRect btnFrm = btn.frame;
        btnFrm.size.width = 100;
        btnFrm.origin.y -= 10;
        btnFrm.origin.x = 110 * idx + 20;
        btn.frame = btnFrm;
        
        idx++;
    }
    
    CGRect statusesLbFrm = _statusesLb.frame;
    statusesLbFrm.origin.y -= 10;
    statusesLbFrm.origin.x = CGRectGetMidX(self.navStatusesBtn.frame) - CGRectGetWidth(statusesLbFrm) / 2.0;
    _statusesLb.frame = statusesLbFrm;
    
    CGRect followingsLbFrm = _followingsLb.frame;
    followingsLbFrm.origin.y -= 10;
    followingsLbFrm.origin.x = CGRectGetMidX(self.navFollowingsBtn.frame) - CGRectGetWidth(followingsLbFrm) / 2.0;
    _followingsLb.frame = followingsLbFrm;
    
    CGRect followersLbFrm = _followersLb.frame;
    followersLbFrm.origin.y -= 10;
    followersLbFrm.origin.x = CGRectGetMidX(self.navFollowersBtn.frame) - CGRectGetWidth(followersLbFrm) / 2.0;
    _followersLb.frame = followersLbFrm;
    
    CGRect trendsFrm = _trendsLb.frame;
    trendsFrm.origin.y -= 10;
    trendsFrm.origin.x = CGRectGetMidX(self.navTrendsBtn.frame) - CGRectGetWidth(trendsFrm) / 2.0;
    _trendsLb.frame = trendsFrm;
    
    CGRect tableFrm = self.lowerhalfV.frame;
    tableFrm.origin.y -= 10;
    tableFrm.size.height = CGRectGetHeight(self.view.frame) - tableFrm.origin.y;
    self.lowerhalfV.frame = tableFrm;
}

- (IBAction)onFollowingsBtnTapped:(id)sender 
{
    if (_curLowerHalfVCtrl && _curLowerHalfVCtrl == self.followingsVCtrl) {
        return;
    }
    
    [_curLowerHalfVCtrl.view removeFromSuperview];
    
    if (nil == self.followingsVCtrl) {        
        self.followingsVCtrl = [KWIFollowingsVCtrl vctrlForUser:self.data container:self.lowerhalfV frame:self.lowerhalfV.bounds];                
    } else {
        [self.lowerhalfV addSubview:self.followingsVCtrl.view];
    }
    _curLowerHalfVCtrl = self.followingsVCtrl;
    
    [self _configNavBtn:sender];
}

- (IBAction)onFollowersBtnTapped:(id)sender 
{
    if (_curLowerHalfVCtrl && _curLowerHalfVCtrl == self.followersVCtrl) {
        return;
    }
    
    [_curLowerHalfVCtrl.view removeFromSuperview];
    
    if (nil == self.followersVCtrl) {        
        self.followersVCtrl = [KWIFollowersVCtrl vctrlForUser:self.data container:self.lowerhalfV frame:self.lowerhalfV.bounds];                
    } else {
        [self.lowerhalfV addSubview:self.followersVCtrl.view];
    }    
    _curLowerHalfVCtrl = self.followersVCtrl;
    
    //[self performSelector:@selector(_configNavBtn:) withObject:self.navFollowersBtn afterDelay:0.5];
    [self _configNavBtn:sender];
}

- (IBAction)_onTrendsBtnTapped:(id)sender 
{
    if (_curLowerHalfVCtrl && _curLowerHalfVCtrl == self.trendsVCtrl) {
        return;
    }
    
    [_curLowerHalfVCtrl.view removeFromSuperview];
    
    if (nil == self.trendsVCtrl) {        
        self.trendsVCtrl = [KWIProfileTrendLsVCtrl vctrlWithUser:self.data];
        self.trendsVCtrl.view.frame = self.lowerhalfV.bounds;
    }
    
    [self.lowerhalfV addSubview:self.trendsVCtrl.view];
       
    _curLowerHalfVCtrl = self.trendsVCtrl;
    
    //[self performSelector:@selector(_configNavBtn:) withObject:self.navTrendsBtn afterDelay:0.5];
    [self _configNavBtn:sender];
}

- (IBAction)onStatusesBtnTapped:(id)sender 
{
    if (_curLowerHalfVCtrl && _curLowerHalfVCtrl == self.peoplestreamVCtrl) {
        return;
    }
    
    [_curLowerHalfVCtrl.view removeFromSuperview];
    
    if (nil == self.peoplestreamVCtrl) {        
        self.peoplestreamVCtrl = [KWIPeopleStreamVCtrl vctrlForUser:self.data container:self.lowerhalfV frame:self.lowerhalfV.bounds];
        if (_isProfile) {
            [self.peoplestreamVCtrl setProfileMod];
        }
    } else {
        [self.lowerhalfV addSubview:self.peoplestreamVCtrl.view];
    }    
    _curLowerHalfVCtrl = self.peoplestreamVCtrl;
    
    [self _configNavBtn:sender];
}

- (void)_configNavBtn:(UIButton *)btn
{
    if (_curNavBtn) {
        _curNavBtn.selected = NO;
    }
    
    _curNavBtn = btn;
    
    btn.selected = YES;
}

- (IBAction)_unfollowBtnTapped:(id)sender 
{
    self.unfollowBtn.enabled = NO;
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"friendships/destroy.json" 
//       params:[NSDictionary dictionaryWithObject:self.data.id_ forKey:@"user_id"] 
//    onSuccess:^(NSDictionary *dict) {
//        self.unfollowBtn.hidden = YES;
//        
//        self.followBtn.enabled = YES;
//        self.followBtn.hidden = NO;
//    } 
//      onError:^(NSError *error) {
//          [error KWIGeneralProcess];
//          self.followBtn.enabled = YES;
//      }];
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.data.userId];
    
    __block KWIPeopleVCtrl *pvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
    if([response isValidResponse]) {
        if (results != nil) {
            pvc.unfollowBtn.hidden = YES;
            pvc.followBtn.enabled = YES;
            pvc.followBtn.hidden = NO;
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

- (IBAction)_followBtnTapped:(id)sender 
{
    self.followBtn.enabled = NO;
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"friendships/create.json" 
//       params:[NSDictionary dictionaryWithObject:self.data.id_ forKey:@"user_id"] 
//    onSuccess:^(NSDictionary *dict) {
//        self.followBtn.hidden = YES;
//        
//        self.unfollowBtn.enabled = YES;
//        self.unfollowBtn.hidden = NO;        
//    } 
//      onError:^(NSError *error) {
//          [error KWIGeneralProcess];
//          self.followBtn.enabled = YES;
//      }];
    KDQuery *query = [KDQuery queryWithName:@"user_id" value:self.data.userId];
    
    __block KWIPeopleVCtrl *pvc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                pvc.followBtn.hidden = YES;
                pvc.unfollowBtn.enabled = YES;
                pvc.unfollowBtn.hidden = NO;
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

- (IBAction)_onMsgBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWThread.new" 
                                                        object:nil 
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:self.data] 
                                                                                           forKey:@"to"]];
}

- (IBAction)_onMentionBtnTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.newMention" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"user"]];
}

- (void)_onAvatarTapped:(UITapGestureRecognizer *)tgr
{
    [self.imgVCtrl showFromView:tgr.view];
}
                                                  
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            _bgv.image = [UIImage imageNamed:@"profileBgPNoShadow.png"];
        } else {
            _bgv.image = [UIImage imageNamed:@"profileBgP.png"];
        }
    } else {
        _bgv.image = [UIImage imageNamed:@"profileBg.png"];
    }
    
    CGRect frame = _bgv.frame;
    frame.size = _bgv.image.size;
    _bgv.frame = frame;
}

- (void)_onOrientationWillChange:(NSNotification *)note
{
    _bgv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOn
{
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff
{
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}

- (NSString *)userId
{
    return _data.userId;
}
@end
