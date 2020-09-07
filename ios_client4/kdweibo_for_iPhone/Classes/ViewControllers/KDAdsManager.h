//
//  KDAdsManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDAdDetailModel.h"
#import "KDAdsClient.h"

typedef void(^KDqueryAdsBlock)(void);
@interface KDAdsManager : NSObject

+ (instancetype)sharedInstance;
/**
 *  查询广告
 *
 *  @param block   查询回调
 *  @param adsType 广告类型
 */
- (void)queryAdsWithBlock:(KDqueryAdsBlock)block adsType:(KDAdsLocationType)adsType;

/**
 *  清除缓存在本地的广告
 */
- (void)clearLocalAdsWithAdsType:(KDAdsLocationType)adsType;

- (NSArray *)queryAdsFromFilePathWithAdsType:(KDAdsLocationType)adsType;

- (void)showAdvertisementOnView:(UIView *)container  timeout:(NSTimeInterval)timeout  completetion:(dispatch_block_t)complete;
@end
