//
//  T9SearchFactory.h
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class T9Node;
@interface T9SearchFactory : NSObject
{
    T9Node *_t9;
}

@property (nonatomic, assign) int personTotalCount;

+(T9SearchFactory *)getInstance;

- (NSArray *)search:(NSString *)word;
- (NSArray *)searchWithNames:(NSArray *)words;
- (NSArray *)searchWithPhoneNumber:(NSString *)word;

-(void)reloadData;

@end
