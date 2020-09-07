//
//  KDLocationData.m
//  kdweibo
//
//  Created by Tan yingqi on 13-1-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLocationData.h"

@interface NSString (locationData)

- (NSString *)composeAddress:(NSArray *)component;
@end

@implementation NSString (locationData)


//将省市和地址结合起来
- (NSString *)composeAddress:(NSArray *)component{
    NSMutableString *result = [NSMutableString stringWithString:self];
    if (component.count >0) {
        //
        NSRange aRange ;
        NSUInteger start = 0;
        NSString *subString;
        for (NSString * aStr in component) {
            subString = [result substringFromIndex:start];
            if (aStr.length >0) {
                aRange = [subString rangeOfString:aStr];
                if (aRange.location == NSNotFound||aRange.location != 0) {
                    [result insertString:aStr atIndex:start];
                }
                 start+=aStr.length;
            }
        }
        
    }
    return result;
}
@end
@implementation KDLocationData
@synthesize coordinate = coordinate_;
@synthesize name = name_;
@synthesize address = address_;
@synthesize province = province_;
@synthesize city = city_;
@synthesize district = district_;
@synthesize street = street_;
@synthesize longAddress = longAddress_;
@synthesize selfIMG = _selfIMG;

+ (KDLocationData *)locationDataByCoordiante:(CLLocationCoordinate2D)coordinate {
    KDLocationData *data = [[KDLocationData alloc] init] ;//autorelease];
    
    data.coordinate = coordinate;
    return data;
}


+ (KDLocationData *)locationDataByMapPOI:(AMapPOI *)poi {
    KDLocationData *data = [[KDLocationData alloc] init] ;//autorelease];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    data.coordinate = coordinate;
    data.name = poi.name;
    data.address = poi.address;
    return data;
}

+(KDLocationData *)locationDataByDictionary:(NSDictionary *)dic{
    KDLocationData *data = [[KDLocationData alloc] init];
    NSDictionary * location = dic[@"location"];
    NSString * name  = dic[@"title"];
    NSString * address = dic[@"address"];
    if (location && name && address) {
        data.name = name;
        data.address = address;
        double latitude = [location[@"lat"] doubleValue];
        double longitude = [location[@"lng"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        data.coordinate = coordinate;
        return data;
    }
    return nil;
}

//为没有省市的地址加上省市
- (NSString *)longAddress {
    if (!longAddress_) {
        //
        if (address_.length >0) {
            if (province_.length >0) {
                NSMutableArray *compse = [NSMutableArray array];
                if (!KD_IS_BLANK_STR(province_) ) {
                    [compse addObject:province_];
                }
                if (!KD_IS_BLANK_STR(city_) ) {
                    [compse addObject:city_];
                    if (!KD_IS_BLANK_STR(district_) ) {
                        [compse addObject:district_];
                    }
                }
                longAddress_ = [[address_ composeAddress:compse] copy];
            }else {
                longAddress_ = [address_ copy];
            }
        }else {
            NSMutableString *aString = [NSMutableString string];
            if (province_.length >0) {
                [aString appendString:province_];
            }
            if (city_.length >0) {
                [aString appendString:city_];
            }
            if (district_.length > 0) {
                [aString appendString:district_];
            }
            if (street_.length >0) {
                [aString appendString:street_];
            }
            address_ = [aString copy];
        }
    }
    return longAddress_;
}

//- (NSArray *)sortedArrayByCurrentLocation:(NSArray *)array {
//    NSArray *sortedArray = nil;
////    if([array count] >= 2) {
////        sortedArray = [array sortedArrayUsingComparator: ^(KDLocationData *obj1, KDLocationData * obj2) {
////
//////            if ([obj1 integerValue] > [obj2 integerValue]) {
//////                return (NSComparisonResult)NSOrderedDescending;
//////            }
//////
//////            if ([obj1 integerValue] < [obj2 integerValue]) {
//////                return (NSComparisonResult)NSOrderedAscending;
//////            }
//////            return (NSComparisonResult)NSOrderedSame;
////
////            CLLocationCoordinate2D c = self.coordinate;
////            CLLocationCoordinate2D c1 = obj1.coordinate;
////            CLLocationCoordinate2D c2 = obj2.coordinate;
////            double deltx1 = fabs(c.latitude-c1.latitude);
////            double delty1 = fabs(c.longitude-c1.longitude);
////            double deltx1_m = deltx1*deltx1;
////            double delty1_m = delty1*delty1;
////
////            double deltx2 = fabs(c.latitude-c2.latitude);
////            double delty2 = fabs(c.longitude-c2.longitude);
////
////            double deltx2_m = deltx2 *deltx2;
////            double delty2_m = delty2 *delty2;
////            if (deltx1_m+delty1_m >deltx2_m+delty2_m) {
////                return (NSComparisonResult)NSOrderedDescending;
////            }
////            if (deltx1_m+delty1_m < deltx2_m+delty2_m) {
////                return (NSComparisonResult)NSOrderedAscending;
////            }
////            return (NSComparisonResult)NSOrderedSame;
////
////        }];
////    }else {
////        sortedArray = array;
////    }
////    return sortedArray;
//
//}
- (void)sortedArrayByCurrentLocation:(NSArray *)array
                     completionBlock:(void (^)(NSArray *))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *sortedArray = nil;
        if([array count] >= 2) {
            sortedArray = [array sortedArrayUsingComparator: ^(KDLocationData *obj1, KDLocationData * obj2) {
                
                CLLocationCoordinate2D c = self.coordinate;
                CLLocationCoordinate2D c1 = obj1.coordinate;
                CLLocationCoordinate2D c2 = obj2.coordinate;
                double deltx1 = fabs(c.latitude-c1.latitude);
                double delty1 = fabs(c.longitude-c1.longitude);
                double deltx1_m = deltx1*deltx1;
                double delty1_m = delty1*delty1;
                
                double deltx2 = fabs(c.latitude-c2.latitude);
                double delty2 = fabs(c.longitude-c2.longitude);
                
                double deltx2_m = deltx2 *deltx2;
                double delty2_m = delty2 *delty2;
                if (deltx1_m+delty1_m >deltx2_m+delty2_m) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if (deltx1_m+delty1_m < deltx2_m+delty2_m) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
                
            }];
        }else {
            sortedArray = array;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(){
            block(sortedArray);
        });
        
    });
}


- (NSString *)description {
    return [NSString stringWithFormat:@"=====%f====%f====",self.coordinate.latitude,self.coordinate.longitude];
}

-(void)dealloc {
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(address_);
    //KD_RELEASE_SAFELY(province_);
    //KD_RELEASE_SAFELY(city_);
    //KD_RELEASE_SAFELY(district_);
    //KD_RELEASE_SAFELY(street_);
    //KD_RELEASE_SAFELY(longAddress_);
    //KD_RELEASE_SAFELY(_selfIMG);
    //[super dealloc];
}
@end

