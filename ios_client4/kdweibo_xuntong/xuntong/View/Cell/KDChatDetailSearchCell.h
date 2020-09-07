//
//  KDChatDetailSearchCell.h
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

typedef NS_ENUM(NSUInteger, KDChatDetailSearchType) {
    KDChatDetailSearchType_File,
    KDChatDetailSearchType_Picture,
    KDChatDetailSearchType_App, // 群应用消息
    KDChatDetailSearchType_Message,
};

typedef void(^KDChatDetailSearchBlock)(KDChatDetailSearchType type);

@interface KDChatDetailSearchCell : KDTableViewCell

@property (nonatomic, strong) KDChatDetailSearchBlock actionBlock;

@end
