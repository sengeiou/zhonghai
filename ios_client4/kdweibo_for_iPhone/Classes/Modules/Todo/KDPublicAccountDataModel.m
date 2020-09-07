//
//  KDPublicAccountDataModel.m
//  kdweibo
//
//  Created by Gil on 15/3/28.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPublicAccountDataModel.h"

@implementation KDPublicAccountDataModel

//- (id)init {
//	self = [super init];
//	if (self) {
//		self.share = true;
//		self.status = 11;
//	}
//	return self;
//}
//
//- (id)initWithDictionary:(NSDictionary *)dict {
//	self = [super initWithDictionary:dict];
//
//	if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
//		return self;
//	}
//	if (![dict isKindOfClass:[NSDictionary class]]) {
//		return self;
//	}
//	if (self) {
//		id publicmenu = [dict objectForKey:@"menu"];
//		if (![publicmenu isKindOfClass:[NSNull class]] && publicmenu != nil) {
//			if ([publicmenu isKindOfClass:[NSArray class]]) {
//				self.menu = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:publicmenu options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//			}
//			else if ([publicmenu isKindOfClass:[NSString class]]) {
//				self.menu = publicmenu;
//			}
//		}
//
//		id note = [dict objectForKey:@"note"];
//		if (![note isKindOfClass:[NSNull class]] && note) {
//			self.note = note;
//		}
//
//		id subscribe = [dict objectForKey:@"subscribe"];
//		if (![subscribe isKindOfClass:[NSNull class]] && subscribe) {
//			self.subscribe = [subscribe boolValue];
//		}
//
//		id canUnsubscribe = [dict objectForKey:@"canUnsubscribe"];
//		if (![canUnsubscribe isKindOfClass:[NSNull class]] && canUnsubscribe) {
//			self.canUnsubscribe = [canUnsubscribe boolValue];
//		}
//
//		id manager = [dict objectForKey:@"manager"];
//		if (![manager isKindOfClass:[NSNull class]] && manager) {
//			self.manager = [manager boolValue];
//		}
//
//		id share = [dict objectForKey:@"share"];
//		if (![share isKindOfClass:[NSNull class]] && share) {
//			self.share = [share boolValue];
//		}
//
//		id fold = [dict objectForKey:@"fold"];
//		if (![fold isKindOfClass:[NSNull class]] && fold) {
//			self.fold = [fold boolValue];
//		}
//	}
//	return self;
//}

@end
