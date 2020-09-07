//
//  KDChatDetailMemberCell.h
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

typedef NS_ENUM(NSUInteger, KDChatDetailMemberType) {
    KDChatDetailMemberType_Person,
    KDChatDetailMemberType_Add,
    KDChatDetailMemberType_Delete,
};

typedef void(^KDChatDetailMemberBlock)(KDChatDetailMemberType type, PersonSimpleDataModel *person);

@interface KDChatDetailMemberCell : KDTableViewCell

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, strong) NSMutableArray *personList;
@property (nonatomic, strong) KDChatDetailMemberBlock block;

@end
