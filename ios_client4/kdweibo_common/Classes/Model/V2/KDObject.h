//
//  KDObject.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kKDAvatarPropertyCacheKey;


////////////////////////////////////////////////////////////////////////////////
// The purpose to make more less database query.

enum {
    KDExtraSourceMaskNone = 0, // status without any extra source
    KDExtraSourceMaskImages = 1 << 0, // status with images
    KDExtraSourceMaskDocuments = 1 << 1, // status with documents
};

typedef NSUInteger KDExtraSourceMask;


@interface KDObject : NSObject {
 @private
    // arrays of actual extension elements found for this element, keyed by extension class
    NSMutableDictionary *extensions_;
    
    NSMutableDictionary *userProperties_; 
}


- (NSArray *)objectsForExtensionClass:(Class)theClass;
- (id)objectForExtensionClass:(Class)theClass;
- (void)setObject:(id)object forExtensionClass:(Class)theClass;
- (void)addObject:(id)newObj forExtensionClass:(Class)theClass;
- (void)removeObject:(id)object forExtensionClass:(Class)theClass;

- (void)setProperty:(id)obj forKey:(NSString *)key;
- (id)propertyForKey:(NSString *)key;

@end
