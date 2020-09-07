//
//  KDAuthViewController.h
//  kdweibo
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDAnimationAvatarView.h"

#import "EMPDelegate.h"
#import "MCloudDelegate.h"
#import "EMPServerClient.h"
#import "XTOpenSystemClient.h"
#import "KDInputView.h"

@class KDUser;
@class KDQuery;
@class KDActivityIndicatorView;
@class AuthDeviceUnauthorizedDataModel;

typedef NS_ENUM(NSInteger, KDLoginViewType) {
    KDLoginViewTypeUndefine = 0,
    KDLoginViewTypePhoneNumInput,
    KDLoginViewTypePhoneLoginPwd,
    KDLoginViewTypePwdInput,
    KDLoginViewTypeEmailInput
};

@interface KDAuthViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, KDRequestWrapperDelegate> {
 @private
    
    UIImageView *avatarView_;
    KDInputView *userNameTextField_;
    KDInputView *passwordTextField_;
    
    UIButton *signInBtn_;
    UIButton *forgetPasswordBtn_;
    UIButton *signUpBtn_;
    UIButton *opBtn_;
    UILabel *_nameLabel;
    
    UIView *contentView_;
    
    UIView *userListMaskView_;
    UITableView *tableView_;
    KDActivityIndicatorView *activityView_;
    UIView *blockView_;
    
    UITapGestureRecognizer *tapGestureRecognizer_;
    
    NSMutableArray *userList_;
    BOOL isPickedUser_;
    
    KDQuery *thirdPartAuthorizeQuery_;
    
    BOOL activityVisible_;
    
    struct {
        unsigned int initialized:1;
        unsigned int navigationBarHidden:1;
        unsigned int disableInputFieldsAnimation:1;
        unsigned int signedUsersPickerVisible:1;
        unsigned int shouldShowKeyBoard:1;
    }authViewControllerFlags_;
    
    KDLoginViewType loginType_;
    
    NSString *_iosURL;
    
    EMPServerClient *_clientServer;//login 接口
    MCloudClient *_clientCloud;//auth | validate | bindLicence | deviceLicenceApply 接口
    AuthDeviceUnauthorizedDataModel *_authDeviceUnauthorizedDataModel;
}
@property (nonatomic, retain) XTOpenSystemClient *openClient;
//A.wang 邮箱验证
@property (nonatomic, retain) XTOpenSystemClient *emailCodeClient;
@property (nonatomic, assign) id<EMPLoginDelegate> delegate;//登录代理
@property (nonatomic, assign) BOOL hidePwd;

- (id)initWithLoginViewType:(KDLoginViewType)type;
- (void)invitedByPersonChannelWithToken:(NSString *)token toCompany:(NSString *)eid;
@end
