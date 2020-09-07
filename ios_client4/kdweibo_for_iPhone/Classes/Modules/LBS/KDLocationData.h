//
//  KDLocationData.h
//  kdweibo
//
//  Created by Tan yingqi on 13-1-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface KDLocationData : NSObject
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *address;
@property(nonatomic,copy) NSString *province; //省
@property(nonatomic,copy) NSString *city; //市
@property(nonatomic,copy) NSString *district;  //区或县
@property(nonatomic,copy) NSString *street;
@property(nonatomic,readonly)NSString *longAddress;  //province + city

@property (nonatomic, retain) UIImage *selfIMG;

+(KDLocationData *)locationDataByMapPOI:(AMapPOI *)poi;

+(KDLocationData *)locationDataByDictionary:(NSDictionary *)dic;

+(KDLocationData *)locationDataByCoordiante:(CLLocationCoordinate2D)coordinate;
- (void)sortedArrayByCurrentLocation:(NSArray *)array
                     completionBlock:(void (^)(NSArray *))block;
@end
