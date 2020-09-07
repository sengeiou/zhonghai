//
//  KDCompositeImageSourceParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDCompositeImageSource;

@interface KDCompositeImageSourceParser : KDBaseParser

- (KDCompositeImageSource *)parse:(NSArray *)body;

@end
