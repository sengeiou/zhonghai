//
//  MJphotoUtils.m
//  kdweibo
//
//  Created by shifking on 15/11/3.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "MJphotoUtils.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@implementation MJphotoUtils

+ (void)browersShowWithGroupId:(NSString *)groupId msgId:(NSString *)msgId sendTime:(NSString *)sendTime {
    
    NSString *index = nil;
    NSArray *messages = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPicturesWithGroupId:groupId toUserId:@"" msgId:msgId sendTime:sendTime index:&index];
    
    NSMutableArray *photos = [NSMutableArray array];
    
    for (int i = 0; i < messages.count; i++)
    {
        RecordDataModel *message = [messages objectAtIndex:i];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [message originalPictureUrl];
        photo.originUrl = [message bigPictureUrl];
#pragma mark modified by Darren in 2014.6.12
        photo.thumbnailPictureUrl = [message thumbnailPictureUrl];
        // photo.placeholder = [[SDWebImageManager sharedManager] diskImageForURL:[message thumbnailPictureUrl]];
        [photos addObject:photo];
    }
    
    if ([photos count] > 0 && [index intValue] < [photos count])
    {
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.photos = photos;
        browser.currentPhotoIndex = [index intValue];
        [browser show];
    }
}

@end
