//
//  XTChatViewController+ForwardMsg.m
//  kdweibo
//
//  Created by fang.jiaxin on 17/4/27.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "XTChatViewController+ForwardMsg.h"
#import "KDForwardChooseViewController.h"
#import "URL+MCloud.h"

@implementation XTChatViewController (ForwardMsg)

//+(void)load
//{
//    void (^__instanceMethod_swizzling)(Class, SEL, SEL) = ^(Class cls, SEL orgSEL, SEL swizzlingSEL){
//        Method orgMethod = class_getInstanceMethod(cls, orgSEL);
//        Method swizzlingMethod = class_getInstanceMethod(cls, swizzlingSEL);
//        if (class_addMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod))) {
//            
//            class_replaceMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
//        }
//        else
//        {
//            method_exchangeImplementations(orgMethod, swizzlingMethod);
//        }
//        
//    };
//    
//    {
//        __instanceMethod_swizzling([self class], @selector(viewDidAppear:), @selector(viewDidAppear_forward:));
//    }
//}
//
//
//-(void)viewDidAppear_forward:(BOOL)animated
//{
//    [self viewDidAppear_forward:animated];
//    [self forwardMessagesToGroup];
//}

-(XTForwardDataModel *)packgeRecordToForwardData:(BubbleDataInternal *)data
{
    if(data.record.msgType == MessageTypeText)
    {
        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
        forwardDM.forwardType = ForwardMessageText;
        forwardDM.contentString = data.record.content;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if(data.record.msgType == MessageTypePicture)
    {
        NSURL * thumbnailUrl = [data.record thumbnailPictureUrl];
        // bug11515，这样改不知道会影响哪里，或者要不要在这里做一次原图下载的操作
        NSURL * originalUrl = [data.record originalPictureUrl];//[data.record canTransmitUrl];
        BOOL isThumbnailExists = [[SDWebImageManager sharedManager] diskImageExistsForURL:thumbnailUrl];
        BOOL isOriginalExists = (originalUrl!=nil);
        
        MessageShareTextOrImageDataModel *paramObj = data.record.param.paramObject;
        
        if ((isThumbnailExists && isOriginalExists)||paramObj.fileId.length>0)
        {
            XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
            forwardDM.forwardType = ForwardMessagePicture;
            forwardDM.thumbnailUrl = thumbnailUrl;
            forwardDM.originalUrl = originalUrl;
            forwardDM.paramObject = data.record.param;
            forwardDM.dataInternal = data;
            return forwardDM;
        }
    }
    else if(data.record.msgType == MessageTypeFile)
    {
        MessageFileDataModel *file = (MessageFileDataModel *)data.record.param.paramObject;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[file.name,[NSString stringWithFormat:@"%d",ForwardMessageFile],file] forKeys:@[@"message",@"forwardType",@"messageFileDM"]];
        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:dict];
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if (data.record.msgType == MessageTypeLocation)
    {
        MessageTypeLocationDataModel *location = (MessageTypeLocationDataModel*)data.record.param.paramObject;
        XTForwardDataModel *forwardDM = [XTForwardDataModel new];
        forwardDM.forwardType = ForwardMessageLocation;
        forwardDM.file_id = location.file_id;
        forwardDM.address = location.address;
        forwardDM.latitude = location.latitude;
        forwardDM.longitude = location.longitude;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if (data.record.msgType == MessageTypeShortVideo)
    {
        MessageTypeShortVideoDataModel *shortVideo = (MessageTypeShortVideoDataModel*)data.record.param.paramObject;
        XTForwardDataModel *forwardDM = [XTForwardDataModel new];
        forwardDM.forwardType = ForwardMessageShortVideo;
        forwardDM.file_id = shortVideo.file_id;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if (data.record.msgType == MessageTypeCombineForward)
    {
        MessageCombineForwardDataModel *combineData = (MessageCombineForwardDataModel*)data.record.param.paramObject;
        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
        forwardDM.forwardType = ForwardMessageCombine;
        forwardDM.message = data.record.content;
        forwardDM.mergeId = combineData.mergeId;
        forwardDM.title = combineData.title;
        forwardDM.contentString = combineData.content;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if(data.record.msgType == MessageTypeShareNews)
    {
        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
        forwardDM.forwardType = ForwardMessageShareNews;
        forwardDM.message = data.record.content;
        forwardDM.title = data.record.content;
        forwardDM.contentString = data.record.content;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if(data.record.msgType == MessageTypeNews)
    {
        PersonSimpleDataModel *person = [self.group.participant firstObject];
        MessageNewsDataModel *paramObject = (MessageNewsDataModel*)data.record.param.paramObject;
        MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
        NSString *photoUrl = news.name;
        if(photoUrl.length == 0)
            photoUrl = person.photoUrl;
        if(photoUrl.length == 0)
            photoUrl = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
        NSDictionary *dic = @{@"shareType" : @(3),
                                @"appName" : person.personName,
                                @"title" : news.title,
                                   @"content" :[news.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]],
                              @"thumbUrl" : photoUrl,
                                @"webpageUrl" : news.url};
        if(news.appId.length != 0)
        {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [tempDic setObject:news.appId forKey:@"appId"];
            dic = tempDic;
        }
        
        MessageShareNewsDataModel *shareData = [[MessageShareNewsDataModel alloc] initWithDictionary:dic];
        
        MessageParamDataModel *param = [[MessageParamDataModel alloc] init];
        param.type = MessageTypeShareNews;
        param.paramObject = shareData;
        param.paramString = [NSJSONSerialization stringWithJSONObject:dic];
        

        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
        forwardDM.forwardType = ForwardMessageShareNews;
        forwardDM.message = data.record.content;
        forwardDM.title = news.title;
        forwardDM.contentString = news.text;
        forwardDM.paramObject = param;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    else if(data.record.msgType == MessageTypeAttach)
    {
        PersonSimpleDataModel *person = [self.group.participant firstObject];
        MessageAttachDataModel *paramObject = data.record.param.paramObject;
        MessageAttachEachDataModel * attach = [paramObject.attach firstObject];
        
        NSString *photoUrl = nil;;
        if(photoUrl.length == 0)
            photoUrl = person.photoUrl;
        if(photoUrl.length == 0)
            photoUrl = [NSString stringWithFormat:@"%@pubacc/public/images/default_public.png",MCLOUD_IP_FOR_PUBACC];
        
        NSDictionary *dic = @{@"shareType" : @(3),
                              @"appName" : person.personName,
                              @"title" : data.record.content,
                              @"content" :attach.name,
                              @"thumbUrl" : photoUrl,
                              @"webpageUrl" : attach.value};
        
        
        MessageShareNewsDataModel *shareData = [[MessageShareNewsDataModel alloc] initWithDictionary:dic];
        MessageParamDataModel *param = [[MessageParamDataModel alloc] init];
        param.type = MessageTypeShareNews;
        param.paramObject = shareData;
        param.paramString = [NSJSONSerialization stringWithJSONObject:dic];
        
        XTForwardDataModel *forwardDM = [[XTForwardDataModel alloc] initWithDictionary:nil];
        forwardDM.forwardType = ForwardMessageShareNews;
        forwardDM.message = data.record.content;
        forwardDM.title = data.record.content;
        forwardDM.contentString = data.record.content;
        forwardDM.paramObject = param;
        forwardDM.dataInternal = data;
        return forwardDM;
    }
    return nil;
}

//data可能为逐条转发数组，也可能为合并转发XTForwardDataModel
-(void)forwardMsgArray:(id)data
{
    KDForwardChooseViewController *contentViewController = [[KDForwardChooseViewController alloc] initWithCreateExtenalGroup:YES];
    contentViewController.hidesBottomBarWhenPushed = YES;
    contentViewController.isFromConversation = YES;
    contentViewController.isFromFileDetailViewController = NO;   //触发转发文件埋点
    //contentViewController.fileDetailDictionary = notify.userInfo;
    contentViewController.isMulti = YES;
    contentViewController.forwardData = data;
    contentViewController.delegate = self;
    contentViewController.type = XTChooseContentForward;
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    [self presentViewController:contentNav animated:YES completion:nil];
}

-(void)forwardMessagesToGroup
{
    if (self.isForward) {
        //开始转发
        self.isForward = NO;
        
        if([self.forwardDM isKindOfClass:[XTForwardDataModel class]])
        {
            //转发单条
            [self sendMessage:self.forwardDM];
        }
        else if([self.forwardDM isKindOfClass:[NSArray class]])
        {
            //转发多条
            __weak XTChatViewController *selfInBlock = self;
            NSMutableArray *forwardDMArray = self.forwardDM;
            [forwardDMArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [selfInBlock sendMessage:obj];
            }];
        }
    }
    
}

-(void)sendMessage:(XTForwardDataModel *)forwardDM
{
    if (forwardDM.forwardType == ForwardMessageFile) {
        if ([forwardDM.paramObject isKindOfClass:[NSNull class]] || forwardDM.paramObject == nil) {
            return;
        }
        NSDictionary *dict = [(MessageFileDataModel *)forwardDM.paramObject dictionaryFromMessageFileDataModel];
        [self sendShareFile:dict];
    }
    else if (forwardDM.forwardType == ForwardMessageText){
        [self sendShareMessage:forwardDM];
        
    }
    else if (forwardDM.forwardType == ForwardMessagePicture){
        
        [self sendSharePicture:forwardDM];
        
    }
    else if (forwardDM.forwardType == ForwardMessageNew){
        [self sendShareNew:forwardDM];
    }
    else if (forwardDM.forwardType == ForwardMessageLocation){
        [self sendShareLocation:forwardDM];
    }
    else if (forwardDM.forwardType == ForwardMessageShortVideo){
        [self sendShareShortVideo:forwardDM];
    }
    else if (forwardDM.forwardType == ForwardMessageCombine){
        //合并转发
        [self sendShareCombineMessage:forwardDM];
    }
    else if (forwardDM.forwardType == ForwardMessageShareNews){
        [self sendShareNews:forwardDM];
    }
    else{
        return;
    }
}


#pragma mark - SendFileDelegate

- (void)sendShareFile:(NSDictionary *)dict
{
    NSString *content = [NSString stringWithFormat:ASLocalizedString(@"XTChatViewController_Tip_19"),[dict objectForKey:@"name"]];
    MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithDictionary:dict type:MessageTypeFile];
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeFile];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setContent:content];
    [sendRecord setMsgLen:(int)content.length];
    [sendRecord setParam:param];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [self.recordsList addObject:sendRecord];
    
    [self sendWithRecord:sendRecord];
}

- (void)sendShareMessage:(XTForwardDataModel *)record
{
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeText];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setContent:record.contentString];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setMsgLen:(int)record.contentString.length];
    [self.recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
    
}

- (void)sendSharePicture:(XTForwardDataModel *)forwardDM
{
    if (forwardDM.editImage) {
        [self handleImage:forwardDM.editImage savedPhotosAlbum:NO withLibUrl:nil];
        return;
    }
    
    UIImage * thumbnailImage = [[SDWebImageManager sharedManager] diskImageForURL:forwardDM.thumbnailUrl];
    UIImage * originalImage = [[SDWebImageManager sharedManager] diskImageForURL:forwardDM.originalUrl options:SDWebImageScalePreView];
    if(!originalImage)
        originalImage = [[SDWebImageManager sharedManager] diskImageForURL:forwardDM.originalUrl options:SDWebImageScaleNone];
    
    NSData *data = UIImageJPEGRepresentation(originalImage,1);
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypePicture];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgLen:(int)[data length]];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    if(forwardDM.dataInternal.record.msgId.length>0)
        [sendRecord setTranslateMsgId:forwardDM.dataInternal.record.msgId];
    else
        [sendRecord setTranslateMsgId:sendRecord.msgId];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setContent:ASLocalizedString(@"KDPublicTopCell_Pic")];
    //add by fang
    [sendRecord setParam:forwardDM.paramObject];
    [self.recordsList addObject:sendRecord];
    
    
    [[SDImageCache sharedImageCache] storeImage:thumbnailImage forKey:[[sendRecord thumbnailPictureUrl] absoluteString]];
    [[SDImageCache sharedImageCache] storeImage:originalImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[sendRecord originalPictureUrl] imageScale:SDWebImageScalePreView]];
    
    [self sendWithRecord:sendRecord];
}

- (void)sendShareNew:(XTForwardDataModel *)forwardDM
{
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeShareNews];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    //   [sendRecord setMsgLen:[data length]];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [self.recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
}

- (void)sendShareLocation:(XTForwardDataModel *)forwardDM
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",forwardDM.longitude],@"longitude",[NSString stringWithFormat:@"%f",forwardDM.latitude],@"latitude",forwardDM.address,@"addressName",forwardDM.file_id,@"fileId", nil];
    
    MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithDictionary:dic type:MessageTypeLocation];
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeLocation];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setMsgLen:0];
    
    [sendRecord setParam:param];
    if(forwardDM.dataInternal.record.msgId.length>0)
        [sendRecord setTranslateMsgId:forwardDM.dataInternal.record.msgId];
    else
        [sendRecord setTranslateMsgId:sendRecord.msgId];
    
    [self.recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
    
}

- (void)sendShareShortVideo:(XTForwardDataModel *)forwardDM
{
    MessageTypeShortVideoDataModel * model = forwardDM.dataInternal.record.param.paramObject;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: model.file_id,@"fileId", model.ext,@"ext", model.videoThumbnail,@"videoThumbnail", model.size,@"size", model.mtime,@"mtime", model.name,@"name", model.videoTimeLength,@"videoTimeLength", model.videoUrl,@"videoUrl", nil];
    
    MessageParamDataModel *param = [[MessageParamDataModel alloc] initWithDictionary:dic type:MessageTypeShortVideo];
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeShortVideo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setMsgLen:0];
    [sendRecord setContent:ASLocalizedString(@"Short_video")];
    
    [sendRecord setParam:param];
    if(forwardDM.dataInternal.record.msgId.length>0)
        [sendRecord setTranslateMsgId:forwardDM.dataInternal.record.msgId];
    else
        [sendRecord setTranslateMsgId:sendRecord.msgId];
    
    [self.recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
}


- (void)sendShareCombineMessage:(XTForwardDataModel *)record
{
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeCombineForward];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setContent:@"[聊天记录]"];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setNickname:@"我"];
    [sendRecord setMsgLen:(int) record.contentString.length];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:safeString(record.mergeId) forKey:@"mergeId"];
    //  title
    NSMutableString *title = [NSMutableString new];
    if(record.title)
    {
        [title appendString:record.title];
    }
    else
    {
        if (record.sourceGroup.groupType == GroupTypeDouble) {
            NSString *otherName = record.sourceGroup.firstParticipant.personName;
            NSString *myName = [[BOSConfig sharedConfig] user].name;
            [title appendFormat:@"%@和%@的聊天记录", myName, otherName];
        }
        else if(record.sourceGroup.groupType == GroupTypePublic && record.pubAccount)
        {
            NSString *pubName = record.pubAccount.name;
            [title appendFormat:@"%@的聊天记录", pubName];
        }
        else {
            NSString *groupName = record.sourceGroup.groupName;
            [title appendFormat:@"%@的聊天记录", groupName];
        }
    }
    [param setObject:safeString(title) forKey:@"title"];
    
    //content
    NSMutableString *content = [NSMutableString new];
    if(record.contentString)
    {
        [content appendString:record.contentString];
    }
    else
    {
        int contentCount = 0;
        NSMutableArray *array = record.mergeRecords.mutableCopy;
        [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            RecordDataModel *record1 = (RecordDataModel *)obj1;
            RecordDataModel *record2 = (RecordDataModel *)obj2;
            return [record1.sendTime compare:record2.sendTime];
        }];
        for (RecordDataModel *r in array) {
            [content appendFormat:@"%@: %@", (record.pubAccount && [[BOSConfig sharedConfig].user.userId isEqualToString:r.fromUserId])?record.pubAccount.name:[self personNameWithGroup:record.sourceGroup record:r], [r.content stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            contentCount += 1;
            if (contentCount == 4) {
                break;
            }
            if (contentCount < 4 && contentCount != array.count) {
                [content appendFormat:@"\n"];
            }
            
        }
    }
    [param setObject:safeString(content) forKey:@"content"];
    
    sendRecord.param = [[MessageParamDataModel alloc] initWithDictionary:param type:MessageTypeCombineForward];
    
    
    [self.recordsList addObject:sendRecord];
    //文本
    [self sendWithRecord:sendRecord];
}

-(void)sendShareNews:(XTForwardDataModel *)forwardDM
{
    MessageParamDataModel *param = forwardDM.paramObject;
    if ([forwardDM.paramObject isKindOfClass:[NSNull class]] || forwardDM.paramObject == nil)
        param = forwardDM.dataInternal.record.param;
    
    RecordDataModel *sendRecord = [[RecordDataModel alloc] init];
    [sendRecord setGroupId:self.group.groupId];
    [sendRecord setMsgType:MessageTypeShareNews];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [sendRecord setSendTime:[formatter stringFromDate:[NSDate date]]];
    [sendRecord setFromUserId:[BOSConfig sharedConfig].user.userId];
    [sendRecord setStatus:MessageStatusRead];
    [sendRecord setMsgRequestState:MessageRequestStateRequesting];
    [sendRecord setMsgId:[ContactUtils uuid]];
    [sendRecord setMsgDirection:MessageDirectionRight];
    [sendRecord setNickname:ASLocalizedString(@"KDMeVC_me")];
    [sendRecord setMsgLen:0];
    [sendRecord setContent:forwardDM.title];
    
    [sendRecord setParam:param];
    
    [self.recordsList addObject:sendRecord];
    [self sendWithRecord:sendRecord];
}

- (void)forwardMessage:(NSNotification *)notify
{
    XTForwardDataModel *forwardData = (XTForwardDataModel *)notify.object;
    if (forwardData != nil) {
        NSIndexPath *index =[NSIndexPath indexPathForRow:[self.bubbleArray indexOfObject:forwardData.dataInternal] inSection:0] ;
        if (!index)
        {
            return;
        }
        
        self.selectMenuCellIndexPath = index;
        self.multiseSelctMode = 1;//转发
        self.multiselecting = YES;
    }
}


-(void)startMultiForward:(UIButton *)btn
{
    __weak XTChatViewController *selfInBlock = self;
    //转发
    __block BOOL isContainsUnSupportToCombind = NO;
    NSMutableArray *forwardArray = [NSMutableArray new];
    NSMutableArray *msgIds = [NSMutableArray new];
    NSMutableArray *records = [NSMutableArray new];
    self.multiselectArray = [self getMultiselectArray];
    [self.multiselectArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XTForwardDataModel *forwardDM = [selfInBlock packgeRecordToForwardData:obj];
        if(forwardDM) {
            if (forwardDM.forwardType == ForwardMessagePicture) {
                forwardDM.bCanEditImage = YES;
            }
            [forwardArray addObject:forwardDM];
        }
        
        //用于合并转发
        BOOL bIsEmoji = NO;
        if (forwardDM.dataInternal.record.strEmojiType) {
            bIsEmoji = [forwardDM.dataInternal.record.strEmojiType isEqualToString:@"original"];
        }
        
        BubbleDataInternal *dataInternal = (BubbleDataInternal *)obj;
        if(dataInternal.record.msgType != MessageTypeCombineForward
           && dataInternal.record.msgRequestState == MessageRequestStateSuccess && !bIsEmoji)
        {
            //聊天记录跟未转发的不能合并转发
            [msgIds addObject:dataInternal.record.msgId];
            [records addObject:dataInternal.record];
        }
        else
            isContainsUnSupportToCombind = YES;
    }];
    if(forwardArray.count == 0)
        return;
    
    if(btn == self.multiselectActionBtn)
    {
        //逐条转发
        selfInBlock.multiselecting = NO;
        [selfInBlock forwardMsgArray:forwardArray];
    }
    else
    {
        if(isContainsUnSupportToCombind)
        {
            __weak __typeof(self) weakSelf = self;
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:ASLocalizedString(@"Forward_Combine_Tips") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:ASLocalizedString(@"Global_Cancel") style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:actionCancel];
            
            UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_7") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //剔除不能合并转发的类型后，假如小于或等于1条，无法转发
                if(msgIds.count == 0)
                    [KDPopup showHUDToast:ASLocalizedString(@"Forward_Combine_Tips_None")];
                else if(msgIds.count == 1)
                {
                    [KDPopup showHUDToast:ASLocalizedString(@"Forward_Combine_Tips_UnSupport")];
                    //                        增加合并转发剩下单条时自动转变为逐条转发（暂时屏蔽）
                    //                        __block  XTForwardDataModel *forwardDM = nil;
                    //                        NSString *msgId = [msgIds firstObject];
                    //                        [forwardArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //                            XTForwardDataModel *forwardObj = (XTForwardDataModel*)obj;
                    //                            if([forwardObj.dataInternal.record.msgId isEqualToString:msgId])
                    //                            {
                    //                                forwardDM = forwardObj;
                    //                                *stop = YES;
                    //                            }
                    //                        }];
                    //
                    //                        if(forwardDM)
                    //                            [self forwardMsgArray:[NSMutableArray arrayWithObject:forwardDM]];
                }
                else
                    [weakSelf sendCombindMsgWithMsgIds:msgIds andRecords:records];
            }];
            [alertVC addAction:actionConfirm];
            [weakSelf presentViewController:alertVC animated:YES completion:nil];
        }
        else
            [selfInBlock sendCombindMsgWithMsgIds:msgIds andRecords:records];
        
    }
}

-(void)sendCombindMsgWithMsgIds:(NSMutableArray *)msgIds andRecords:(NSMutableArray *)records
{
    //合并转发
    [KDPopup showHUDInView:self.view];
    __weak __typeof(self) weakSelf = self;
    [[KDOpenAPIClientWrapper sharedInstance] createMerge:self.group.groupId
                                                  msgIds:msgIds
                                              completion:^(BOOL succ, NSString * error, id result) {
                                                  
                                                  [KDPopup hideHUDInView:weakSelf.view];
                                                  
                                                  if (succ && result && [result isKindOfClass:[NSString class]]) {
                                                      
                                                      
                                                      weakSelf.multiselecting = NO;
                                                      
                                                      NSString *mergeId = (NSString *)result;
                                                      XTForwardDataModel *fmodel = [XTForwardDataModel new];
                                                      fmodel.forwardType = ForwardMessageCombine;
                                                      fmodel.mergeId = mergeId;
                                                      fmodel.mergeRecords = records;
                                                      fmodel.sourceGroup = weakSelf.group;
                                                      fmodel.pubAccount = weakSelf.pubAccount;
                                                      [weakSelf forwardMsgArray:fmodel];
                                                  }
                                                  
                                                  if (!succ && error.length > 0) {
                                                      [KDPopup showHUDToast:error];
                                                  }
                                                  
                                              }];
    
}
@end
