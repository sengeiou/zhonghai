//
//  KDSignInLocationManager.h
//  kdweibo
//
//  Created by lichao_liu on 11/11/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDLocationData.h"

typedef NS_ENUM(NSInteger,KDMapOperationType) {
    KDMapOperationType_operating,
    KDMapOperationType_success,
    KDMapOperationType_empty,
    KDMapOperationType_error,
    KDMapOperationType_locationOperationDeni
};

typedef void(^KDLocationBlock)(CLLocation *location,KDMapOperationType type);
typedef void(^KDReGeocodeBlock)(KDLocationData *locationData,KDMapOperationType type);
typedef void(^KDPoiSearchBlock)(NSArray *pois,KDMapOperationType type);
@interface KDSignInLocationManager : NSObject
@property (nonatomic, strong) CLLocation  *bestLocation;

- (void)startLocationWithSuccessBlock:(KDLocationBlock)locationSuccessBlock
                         failuedBlock:(KDLocationBlock)failuredBlock;

- (void)startReGeocodeSearchWithLocation:(CLLocation *)location
                            SuccessBlock:(KDReGeocodeBlock)successBlock
                           failuredBlock:(KDReGeocodeBlock)failuredBlock;

- (void)doPoiSearchWithOffset:(CGFloat)offset
                         page:(NSInteger)page
                       radius:(CGFloat)radius
                     location:(CLLocation *)location
                      keyword:(NSString *)keyword
                 successBlock:(KDPoiSearchBlock)successBlock
                failuredBlock:(KDPoiSearchBlock)failuredBlock
              isNeedReGeoCode:(BOOL)needReGeoCode;

- (void)stopOpration;
@end
