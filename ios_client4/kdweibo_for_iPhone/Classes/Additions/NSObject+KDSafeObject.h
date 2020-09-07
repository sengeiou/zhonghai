//
//  NSObject+KDSafeObject.h
//  Pods
//
//  Created by Joyingx on 2017/1/3.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (KDSafeObject)

NSString *kd_safeString(NSObject *string);
NSMutableString *kd_safeMutableString(NSObject *mutableString);
NSArray *kd_safeArray(NSObject *array);
NSMutableArray *kd_safeMutableArray(NSObject *mutableArray);
NSDictionary *kd_safeDictionary(NSObject *dictionary);
NSMutableDictionary *kd_safeMutableDictionary(NSObject *mutableDictionary);
NSNumber *kd_safeNumber(NSObject *number);

BOOL kd_safeBool(NSObject *number);
NSInteger kd_safeInteger(NSObject *number);
int kd_safeInt(NSObject *number);
short kd_safeShort(NSObject *number);
long kd_safeLong(NSObject *number);
long long kd_safeLongLong(NSObject *number);
double kd_safeDouble(NSObject *number);
float kd_safeFloat(NSObject *number);

@end
