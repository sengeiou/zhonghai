//
//  XTContactDataModel.h
//  XT
//
//  Created by Gil on 13-7-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _ContactDataType{
    ContactDataFirst            = 0,
    ContactDataSecond           = 1 << 0,
    ContactDataThird            = 1 << 1,
    ContactDataFav              = 1 << 2,
    ContactDataRecent           = 1 << 3,
    ContactDataPublic           = 1 << 4,
    ContactDataGroup            = 1 << 5,
    ContactDataNoDataPrompt     = 1 << 6,
    ContactDataFavPrompt        = 1 << 7,
    ContactDataRecentPrompt     = 1 << 8,
    ContactDataPublicPrompt     = 1 << 9,
    ContactDataOrg              = 1 << 10,
    ContactDataNewCoworker      = 1 << 11,
    ContactDataParticipant      = 1 << 12
}ContactDataType;

@interface XTContactDataModel : NSObject

@property (nonatomic, assign) ContactDataType type;
@property (nonatomic, assign) BOOL canOpen;
@property (nonatomic, strong) NSArray *datas;

- (id)initWithType:(ContactDataType)type canOpen:(BOOL)canOpen datas:(NSArray *)datas;
+ (id)dataWithType:(ContactDataType)type canOpen:(BOOL)canOpen datas:(NSArray *)datas;

@end


@interface XTContactFirstDataModel : NSObject

@property (nonatomic, assign) ContactDataType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int count;

- (id)initWithType:(ContactDataType)type title:(NSString *)title count:(int)count;
+ (id)dataWithType:(ContactDataType)type title:(NSString *)title count:(int)count;

@end


@interface XTContactSecondDataModel : NSObject

@property (nonatomic, assign) ContactDataType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL fold;

- (id)initWithType:(ContactDataType)type title:(NSString *)title fold:(BOOL)fold;
+ (id)dataWithType:(ContactDataType)type title:(NSString *)title fold:(BOOL)fold;

@end
