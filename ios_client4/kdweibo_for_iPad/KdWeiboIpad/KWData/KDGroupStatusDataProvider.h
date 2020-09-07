//
//  KDGroupStatusDataProvider.h
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-21.
//
//

#import "KDStatusDataProvider.h"
#import "KDGroup.h"
@interface KDGroupStatusDataProvider : KDStatusDataProvider
@property(nonatomic,retain)KDGroup *group;
@end
