//
//  BubbleDataInternal.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "RecordDataModel.h"
#import "GroupDataModel.h"

@interface BubbleDataInternal : NSObject

@property (nonatomic, strong) GroupDataModel* group;
@property (nonatomic, strong) RecordDataModel* record;

@property (nonatomic, copy) NSString *header;
@property (nonatomic, assign) BOOL personNameLabelHidden;

@property (nonatomic) CGRect contentLabelFrame;//内容显示区域Frame
@property (nonatomic) CGSize bubbleLabelSize;//气泡区域Size
@property (nonatomic) float cellHeight;//行高
@property (nonatomic) float cellHeight1;//行高

@property (nonatomic) CGRect replyContentLabelFrame;//消息回复内容frame
@property (nonatomic) CGRect replyLineFrame;//消息回复分割线frame
@property (nonatomic) CGRect viewOrgBtnFrame;


/**
 *  从其他页面进入聊天页面时需要跳转到的行数
 */
@property (nonatomic, assign) NSUInteger scrollToIndexRow;

@property (nonatomic, assign) BOOL bDisplayed; // 显示过

@property (nonatomic, assign) int checkMode; // 勾选模式，－1为非勾选模式，0为未勾选，1为已勾选
@property (nonatomic, assign) int muliteSelectMode; // 多选模式，0为删除模式，1为转发模式

-(BubbleDataInternal *)initWithRecord:(RecordDataModel *)record andGroup:(GroupDataModel *)group andChatMode:(ChatMode)chatMode;
@end
