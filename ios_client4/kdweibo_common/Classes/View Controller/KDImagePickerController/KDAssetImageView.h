//
//  KDAssetImageView.h
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAssetImageView : UIImageView

@property (nonatomic ,retain) NSIndexPath *cellIndexPath;
@property (nonatomic, retain) NSURL *assetURL;

@end
