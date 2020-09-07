//
//  KDABPersonDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
#import "KDABPerson.h"

@protocol KDABPersonDAO <NSObject>
@required

- (void)saveABPersons:(NSArray *)persons type:(KDABPersonType)type clear:(BOOL)clear
             database:(FMDatabase *)fmdb rollback:(BOOL *)rollback;
- (BOOL)updateABPersonFavoritedState:(KDABPerson *)person database:(FMDatabase *)fmdb;
- (NSArray *)queryABPersonsByType:(KDABPersonType)type limit:(NSUInteger)limit database:(FMDatabase *)fmdb;

- (NSArray *)queryABPersonsByUserId:(NSString *)userId database:(FMDatabase *)fmdb;

- (BOOL)removeAllABPersonsWithType:(KDABPersonType)type database:(FMDatabase *)fmdb;
- (BOOL)removeABPerson:(KDABPerson *)person type:(KDABPersonType)type database:(FMDatabase *)fmdb;

@end