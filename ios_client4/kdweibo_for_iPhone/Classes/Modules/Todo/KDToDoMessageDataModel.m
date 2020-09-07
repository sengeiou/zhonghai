//
//  KDToDoMessageDataModel.m
//  kdweibo
//
//  Created by janon on 15/4/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDToDoMessageDataModel.h"
#import "NSDictionary+Additions.h"

#define KD_IS_NULL_JSON_OBJ(obj) ((obj) == nil || [NSNull null] == (obj))

@implementation KDToDoMessageDataModel

-(CGFloat)caculateHeight
{
    if (!_caculateHeight)
    {
        _caculateHeight = 0;
    }
    return _caculateHeight;
}

-(BOOL)shouldChangeToCellTypeShow
{
    if (!_shouldChangeToCellTypeShow)
    {
        _shouldChangeToCellTypeShow = NO;
    }
    return _shouldChangeToCellTypeShow;
}

-(void)setModel:(NSString *)model
{
    _model = model;
    
    if ([model isEqualToString:@"4"])    //可操作消息的类型
    {
        _cellType = KDToDoCellType_Operate_Hide;
    }
    else
    {
        _cellType = KDToDoCellType_NotOperateAble;
    }
}

-(void)setParam:(MessageParamDataModel *)param
{
    _param = param;
    
    if (param.paramString != nil && ![param.paramString isKindOfClass:[NSNull class]]) {
        NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[param.paramString dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers error:nil];
        self.list = [tempDic objectForKey:@"list"];
    }
    else
    {
        self.list = nil;
    }
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id fromUserId = [dict objectForKey:@"fromUserId"];
        id sendTime = [dict objectForKey:@"sendTime"];
        id msgType = [dict objectForKey:@"msgType"];
        id status = [dict objectForKey:@"status"];
        id msgLen = [dict objectForKey:@"msgLen"];
        id content = [dict objectForKey:@"content"];
        id direction = [dict objectForKey:@"direction"];
        id nickname = [dict objectForKey:@"nickname"];
        id msgId = [dict objectForKey:@"msgId"];
//        id XTMsgId = [dict objectForKey:@"msgId"];
        id sourceMsgId = [dict objectForKey:@"sourceMsgId"];
        id todoStatus = [dict objectForKey:@"todoStatus"];
        id isOriginalPic = [dict objectForKey:@"isOriginalPic"];
        id fromClientId = [dict objectForKey:@"fromClientId"];
        id clientMsgId = [dict objectForKey:@"clientMsgId"];
        id score = [dict objectForKey:@"score"];
        
        id fromUserPhoto = [dict objectForKey:@"fromUserPhoto"];
        id fromUserName = [dict objectForKey:@"fromUserName"];
//        id fromUserOrgId = [dict objectForKey:@"fromUserOrgId"];
//        id fromUserOrgName = [dict objectForKey:@"fromUserOrgName"];
        
        if (![fromUserId isKindOfClass:[NSNull class]] && fromUserId)
        {
            self.fromUserId = fromUserId;
        }
        if (![sendTime isKindOfClass:[NSNull class]] && sendTime)
        {
            self.sendTime = sendTime;
        }
        if (![msgType isKindOfClass:[NSNull class]] && msgType)
        {
            self.msgType = [msgType intValue];
        }
        if (![status isKindOfClass:[NSNull class]] && status)
        {
            self.status = [status intValue];
        }
        if (![msgLen isKindOfClass:[NSNull class]] && msgLen)
        {
            self.msgLen = [msgLen intValue];
        }
        if (![content isKindOfClass:[NSNull class]] && content)
        {
            self.content = content;
        }
        if (![direction isKindOfClass:[NSNull class]] && direction)
        {
            self.msgDirection = [direction intValue];
        }
        if (![nickname isKindOfClass:[NSNull class]] && nickname)
        {
            self.nickname = nickname;
        }
        if (![msgId isKindOfClass:[NSNull class]] && msgId)
        {
            self.msgId = msgId;
        }
        if (![sourceMsgId isKindOfClass:[NSNull class]] && sourceMsgId)
        {
            self.sourceMsgId = sourceMsgId;
        }
        if (![todoStatus isKindOfClass:[NSNull class]] && todoStatus)
        {
            self.todoStatus = todoStatus;
        }
        else
            self.todoStatus = nil;
        if (![isOriginalPic isKindOfClass:[NSNull class]] && isOriginalPic)
        {
            self.isOriginalPic = isOriginalPic;
        }
        else
            self.isOriginalPic = @"0";

        
        if (![clientMsgId isKindOfClass:[NSNull class]] && clientMsgId)
        {
            self.clientMsgId = clientMsgId;
        }
        
        if (![score isKindOfClass:[NSNull class]] && score)
        {
            self.score = score;
        }
        
        if (![fromUserPhoto isKindOfClass:[NSNull class]] && fromUserPhoto)
        {
            self.fromUserPhoto = fromUserPhoto;
        }
        if (![fromUserName isKindOfClass:[NSNull class]] && fromUserName)
        {
            self.fromUserName = fromUserName;
        }
//        if (![fromUserOrgId isKindOfClass:[NSNull class]] && fromUserOrgId)
//        {
//            self.fromUserOrgId = fromUserOrgId;
//        }
//        if (![fromUserOrgName isKindOfClass:[NSNull class]] && fromUserOrgName)
//        {
//            self.fromUserOrgName = fromUserOrgName;
//        }
    
        id param = [dict objectForKey:@"param"];
        if (![param isKindOfClass:[NSNull class]] && param != nil)
        {
            self.iNotifyType = [[param objectNotNSNullForKey:@"notifyType"] intValue];
            self.strNotifyDesc = [param objectNotNSNullForKey:@"notifyDesc"];
            self.strEmojiType = [param objectNotNSNullForKey:@"emojiType"];
            self.bImportant = [[param objectNotNSNullForKey:@"important"] boolValue];
            
            MessageParamDataModel *paramDM = [[MessageParamDataModel alloc] initWithDictionary:param type:self.msgType];
            self.param = paramDM;
            
            NSArray *list = [param objectForKey:@"list"];
            NSDictionary *dic = [list firstObject];
            id XTMsgId = [dic objectForKey:@"msgid"];
            id appid = [dic objectForKey:@"appid"];
            id date = [dic objectForKey:@"date"];
            id name = [dic objectForKey:@"name"];
            id row = [dic objectForKey:@"row"];
            id text = [dic objectForKey:@"text"];
            id title = [dic objectForKey:@"title"];
            id url = [dic objectForKey:@"url"];
            id model = [param objectForKey:@"model"];
            
            if (![list isKindOfClass:[NSNull class]] && list)
            {
                self.list = list;
            }
            
            if (![XTMsgId isKindOfClass:[NSNull class]] && XTMsgId)
            {
                self.XTMsgId = XTMsgId;
            }
            
            if (![appid isKindOfClass:[NSNull class]] && appid)
            {
                self.appid = appid;
            }
            
            if (![date isKindOfClass:[NSNull class]] && date)
            {
                self.date = date;
            }
            
            if (![name isKindOfClass:[NSNull class]] && name)
            {
                self.name = name;
            }
            
            if (![row isKindOfClass:[NSNull class]] && row)
            {
                self.row = row;
            }
            
            if (![text isKindOfClass:[NSNull class]] && text)
            {
                self.text = text;
            }
            
            if (![title isKindOfClass:[NSNull class]] && title)
            {
                self.title = title;
            }
            
            if (![url isKindOfClass:[NSNull class]] && url)
            {
                self.url = url;
            }
            
            if (![model isKindOfClass:[NSNull class]] && model)
            {
                self.model = [NSString stringWithFormat:@"%@", model];
                
                if ([model intValue] == 4)   //可操作的消息的类型
                {
                    self.cellType = KDToDoCellType_Operate_Hide;
                }
            }
        }
        
        id tempAppId = [param objectNotNSNullForKey:@"appid"];
        if (![tempAppId isKindOfClass:[NSNull class]] && tempAppId)
        {
            self.appid = tempAppId;
        }
        
        id tempTitle = [param objectNotNSNullForKey:@"title"];
        if (![tempTitle isKindOfClass:[NSNull class]] && tempTitle)
        {
            self.title = tempTitle;
        }
        
        id tempName = [param objectNotNSNullForKey:@"name"];
        if (![tempName isKindOfClass:[NSNull class]] && tempName) {
            self.name = tempName;
        }
        
    }
    return self;
}

#pragma mark - caculateCellHeight
-(void)adjustModelForCellTypeShow:(NSString *)string
{
    self.shouldChangeToCellTypeShow = YES;
    self.caculateHeight = [self caculateCellHeight:string];
}

-(void)adjustModelForCellTypeHide
{
    self.shouldChangeToCellTypeShow = NO;
    self.caculateHeight = 0;
}

-(CGFloat)caculateCellHeight:(NSString *)string
{
    CGSize textSize = {[UIScreen mainScreen].bounds.size.width - 34 ,10000.0};
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    //return size.height >= 80.0f ? size.height : 80.0f;//如果算出来的行高小于80直接用80代替
    return size.height;
}

-(CGFloat)caculateCellHeightForNormalCellWithString:(NSString *)string
{
    NSArray *tempArray = [string componentsSeparatedByString:@"\n"];
    
    if (tempArray.count == 1) {
        CGSize textSize = {[UIScreen mainScreen].bounds.size.width - 94, 500};
        CGRect frame = [string boundingRectWithSize:textSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:FS4} context:nil];
        return frame.size.height  + 104.0f;
    }
    else if (tempArray.count == 2) {
        NSString *tempString = [tempArray lastObject];
        CGSize textSize = {[UIScreen mainScreen].bounds.size.width - 94, 500};
        CGRect frame = [tempString boundingRectWithSize:textSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:FS4} context:nil];
        return 104 + 2* frame.size.height;
    }
    else if (tempArray.count == 3) {
        NSString *tempString = [tempArray lastObject];
        CGSize textSize = {[UIScreen mainScreen].bounds.size.width - 94, 10000.0};
        CGRect frame = [tempString boundingRectWithSize:textSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:FS4} context:nil];
        return 104+3*frame.size.height;
    }
    else if (tempArray.count >= 4)   //分出来的数组个数可能大于4
    {
        return 68.0f + 104.0f;
    }
    else {
        return 0.0f;
    }
}

#pragma mark - description
-(NSString *)description
{
    return [NSString stringWithFormat:@"\n\n\nXTMsgId = %@\nmsgId =%@\nfromUserId = %@\nsendTime = %@\nmsgType = %d\nmsgLen = %d\ncontent = %@\nstatus = %d\nmsgDirection = %d\nmsgRequestState = %d\nnickname = %@\ngroupId = %@\niNotifyType = %d\nstrNotifyDesc = %@\nstrEmojiType = %@\nsourceMsgId = %@\nreadState = %@\ntodoStatus = %@\nappid = %@\ndate = %@\nname = %@\nrow = %@\ntext = %@\ntitle = %@\nurl = %@\nmodel = %@\nlist = %@\nparam = %@\n\n\n", self.XTMsgId,self.msgId, self.fromUserId, self.sendTime, self.msgType, self.msgLen, self.content, self.status, self.msgDirection, self.msgRequestState, self.nickname, self.groupId, self.iNotifyType, self.strNotifyDesc, self.strEmojiType, self.sourceMsgId, self.readState, self.todoStatus,self.appid, self.date, self.name, self.row, self.text, self.title, self.url,self.model,self.list,self.param.paramString];
}

#pragma mark - setText
-(void)setText:(NSString *)text
{
   
    if (![text isKindOfClass:[NSNull class]] && text) {
         _text = text;
        self.normalCellHeight = [self caculateCellHeightForNormalCellWithString:text];
    }else
        self.normalCellHeight = 0.0f;
    
}
-(BOOL)isEqual:(id)object
{
    KDToDoMessageDataModel *model = object;
    return [self.title isEqualToString:model.title];
}

@end

//代办删除消息
@implementation HasMsgDelDateModel

- (id)init {
    self = [super init];
    if (self) {
        _msgLastDelUpdateTime = [[NSString alloc] init];
        _count = 0;
        _list = [[NSMutableArray alloc] init];
        _needDelUndoMsgIds = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id msgLastDelUpdateTime = [dict objectForKey:@"msgLastDelUpdateTime"];
        id count = [dict objectForKey:@"count"];
        id list = [dict objectForKey:@"list"];
        id needDelUndoMsgIds = [dict objectForKey:@"needDelUndoMsgIds"];
        if (![msgLastDelUpdateTime isKindOfClass:[NSNull class]] && msgLastDelUpdateTime)
        {
            self.msgLastDelUpdateTime = msgLastDelUpdateTime;
        }
        if (![count isKindOfClass:[NSNull class]] && count) {
            self.count = [count intValue];
        }
        
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            for (id each in list) {
                DeleteMsgDateModel *deleteMsgModel = [[DeleteMsgDateModel alloc] initWithDictionary:each];
                [self.list addObject:deleteMsgModel];
            }
        }
        if (![needDelUndoMsgIds isKindOfClass:[NSNull class]] && needDelUndoMsgIds && [needDelUndoMsgIds isKindOfClass:[NSArray class]]) {
            for (id each in needDelUndoMsgIds) {
                DeleteUndoMsgDateModel *deleteUndoMsgModel = [[DeleteUndoMsgDateModel alloc] initWithDictionary:each];
                [self.needDelUndoMsgIds addObject:deleteUndoMsgModel];
            }
        }
    }

    return self;
}
@end


    
//代办删除消息
@implementation DeleteMsgDateModel
    
- (id)init {
    self = [super init];
    if (self) {
        _groupId = [[NSString alloc] init];
        _msgId = [[NSString alloc] init];
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id groupId = [dict objectForKey:@"groupId"];
        id msgId = [dict objectForKey:@"messageId"];
        if (![groupId isKindOfClass:[NSNull class]] && groupId)
        {
            self.groupId = groupId;
        }
        if (![msgId isKindOfClass:[NSNull class]] && msgId) {
            self.msgId = msgId;
        }
    }
     return self;
}

@end

//代办删除消息
@implementation DeleteUndoMsgDateModel

- (id)init {
    self = [super init];
    if (self) {
        _groupId = [[NSString alloc] init];
        _msgId = [[NSString alloc] init];
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id groupId = [dict objectForKey:@"groupId"];
        id msgId = [dict objectForKey:@"messageId"];
        if (![groupId isKindOfClass:[NSNull class]] && groupId)
        {
            self.groupId = groupId;
        }
        if (![msgId isKindOfClass:[NSNull class]] && msgId) {
            self.msgId = msgId;
        }
    }
    return self;
}

@end

