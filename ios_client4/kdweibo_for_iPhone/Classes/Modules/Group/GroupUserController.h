//
//  GroupUserController.h
//  TwitterFon
//
//  Created by  on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NetworkUserController.h"
#import "KDGroup.h"

@interface GroupUserController : NetworkUserController {
@private    
    KDGroup *group;
}

@property (nonatomic, retain) KDGroup *group;

@end
