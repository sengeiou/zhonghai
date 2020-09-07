//
//  KDGroupStatusViewController.h
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-21.
//
//

#import "KDStatusBaseViewController.h"
#import "KDGroup.h"
@interface KDGroupStatusViewController : KDStatusBaseViewController
+(KDGroupStatusViewController *)viewControllerByGroup:(KDGroup *)group;
@property(nonatomic, retain)KDGroup *group;
@end
