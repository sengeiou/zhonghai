//
//  KDAppHeaderViewDataSource.h
//  kdweibo
//
//  Created by 王 松 on 13-12-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

static NSString * const ImageNames[] = {@"app_intro.png"};
#define ImageCount sizeof(ImageNames) / sizeof(NSString*)

#import <Foundation/Foundation.h>

#import "KDTileView.h"

@interface KDAppHeaderViewDataSource : NSObject <KDTileViewDataSource>

@end
