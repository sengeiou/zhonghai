//
//  KDParserManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDUserParser.h"
#import "KDStatusParser.h"
#import "KDExtendStatusParser.h"
#import "KDStatusExtraMessageParser.h"
#import "KDCompositeImageSourceParser.h"
#import "KDAttachmentParser.h"
#import "KDDMThreadParser.h"
#import "KDDMMessageParser.h"
#import "KDABPersonParser.h"
#import "KDVoteParser.h"
#import "KDGroupParser.h"
#import "KDCompositeParser.h"
#import "KDTaskParser.h"
#import "KDSignSchemaParser.h"
#import "KDSignInParser.h"

@interface KDParserManager : NSObject

+ (KDParserManager *)globalParserManager;

- (id)parserWithClass:(Class)clazz;

@end
