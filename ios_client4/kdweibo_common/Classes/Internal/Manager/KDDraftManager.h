//
//  KDDraftManager.h
//  kdweibo_common
//
//  Created by Tan Yingqi on 14-1-6.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDDraft.h"

@interface KDDraftManager : NSObject

+ (KDDraftManager *)shareDraftManager;
- (void)deleteDrafts:(NSArray *)draftArray completionBlock:(void (^)(id result))block;
@end
