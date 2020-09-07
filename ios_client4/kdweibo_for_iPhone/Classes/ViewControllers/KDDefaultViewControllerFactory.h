//
//  KDDefaultViewControllerFactory.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PostViewController;
@class DMPostController;

@interface KDDefaultViewControllerFactory : NSObject {
@private
    
}

- (PostViewController *) getPostViewController;

@end
