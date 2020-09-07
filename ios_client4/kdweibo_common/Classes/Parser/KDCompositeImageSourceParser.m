//
//  KDCompositeImageSourceParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCompositeImageSourceParser.h"

#import "KDCompositeImageSource.h"
#import "KDImageSource.h"
#import "NSString+Additions.h"
@implementation KDCompositeImageSourceParser

- (KDCompositeImageSource *)parse:(NSArray *)body {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    KDImageSource *obj = nil;
    for(NSDictionary *item in body){
        obj = [[KDImageSource alloc] init];
        obj.fileName = [item stringForKey:@"fileName"];
        obj.fileType = [item stringForKey:@"contentType"];
        obj.thumbnail = [item stringForKey:@"thumbnail_pic"];
        obj.middle = [item stringForKey:@"bmiddle_pic"];
        obj.original = [item stringForKey:@"original_pic"];
        obj.fileId = [item stringForKey:@"fileId"];
        
        if (obj.middle) {
            obj.noRawUrl = [obj.middle stringByAppendingString:@"?original"];
        }
        [items addObject:obj];
//        [obj release];
    }
    return [[KDCompositeImageSource alloc] initWithImageSources:items];// autorelease];
}

@end
