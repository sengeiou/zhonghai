//
//  KDDownloadFile.h
//  kdweibo
//
//  Created by wenjie_lee on 16/8/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDDownloadFile : NSObject



+ (void) downloadsWithData:(NSArray *)data finishBlock:(detectionFinishedBlock)finishBlock;



@end
