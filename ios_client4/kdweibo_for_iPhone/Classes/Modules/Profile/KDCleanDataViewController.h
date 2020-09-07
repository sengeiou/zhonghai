//
//  KDCleanDataViewController.h
//  kdweibo
//
//  Created by wenjie_lee on 15/7/22.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDCleanDataViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    KDUInt64 sizeOfDownloads;
    KDUInt64 sizeOfPictures;
    KDUInt64 sizeOfAudios;
    KDUInt64 sizeOfVideos;
    KDUInt64 sizeOfXTAudios;
    KDUInt64 sizeOfSDWebImages;
    KDUInt64 sizeOfDownloadsFile;
    struct {
        unsigned int pausedCalculateCacheSize:1;
        unsigned int finishedCalculation:1;
    }profileControllerFlags_;
}

@end
