//
//  KDMessageHandler.m
//  kdweibo
//
//  Created by 王 松 on 14-5-19.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDMessageHandler.h"
#import "BOSSetting.h"
#import "ContactClient.h"
#import "BOSConfig.h"
#import "KDCommon.h"

#define kKDMessageHandlerTimeout 30.f

@implementation KDMessageHandler

+ (instancetype)messageHandler
{
    static dispatch_once_t onceToken;
    static KDMessageHandler *_messageHandler;
    dispatch_once(&onceToken, ^{
        _messageHandler = [[KDMessageHandler alloc] init];
        [_messageHandler setMaxConcurrentOperationCount:1];
        [_messageHandler setShouldCancelAllRequestsOnFailure:NO];
        [_messageHandler go];
    });
    return _messageHandler;
}

+ (NSString *)defaultUserAgent
{
    static NSString *defaultUserAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUserAgent = [[NSString alloc] initWithFormat:@"%@/%@;%@ %@;Apple;%@;%d/%@",XuntongAppClientId, [KDCommon clientVersion], [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion, [UIDevice platform], [BOSConfig sharedConfig].appId, [BOSConfig sharedConfig].instanceName];
    });
    return defaultUserAgent;
}

- (void)sendMessage:(KDMessageModel *)message chatMode:(ChatMode)mode block:(KDMessageHandlerBlock)block
{
    switch (message.messageType) {
        case MessageTypeFile:
        case MessageTypeText:
        case MessageTypeCombineForward:
        case MessageTypeShortVideo:
        case MessageTypeShareNews:
            [self sendTextMessage:message chatMode:mode block:block];
            break;
        case MessageTypeSpeech:
        case MessageTypePicture:
        case MessageTypeLocation:
            [self sendDataMessage:message chatMode:mode block:block];
            break;
        default:
            break;
    }
    
    if (message.messageType == MessageTypeNotrace) {
        if (message.paramObj != nil && [message.paramObj isKindOfClass: [MessageNotraceDataModel class]]) {
            MessageNotraceDataModel *model = (MessageNotraceDataModel *)message.paramObj;
            if (model.msgType == MessageTypePicture) {
                [self sendDataMessage:message chatMode:mode block:block];
                
            } else {
                [self sendTextMessage:message chatMode:mode block:block];
            }
        }
    }

}

- (void)sendDataMessage:(KDMessageModel *)message chatMode:(ChatMode)mode block:(KDMessageHandlerBlock)block
{
    NSString *url = nil;
    
    switch (mode) {
        case ChatPublicMode:
            url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_PUBLIC_SENDFILE];
            break;
        case ChatPrivateMode:
        default:
        {
            MessageTypeLocationDataModel *locationObj = nil;
            MessageShareTextOrImageDataModel *paramObj = nil;
            MessageTypeShortVideoDataModel *shortVideoObj = nil;
            MessageNotraceDataModel *notraceObj = nil;
            if (message.messageType == MessageTypeLocation) {
                locationObj = message.paramObj;
            }
            else if (message.messageType == MessageTypeShortVideo) {
                shortVideoObj = message.paramObj;
            }
            else if (message.messageType == MessageTypeNotrace) {
                notraceObj = message.paramObj;
            }
            else
            {
                paramObj = message.paramObj;
            }
//            
//            if (message.messageType == MessageTypeShortVideo && !message.transmit) {
//                
//                 url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_SENDFILE];
//            }
//            else
            if(paramObj.fileId.length > 0 || notraceObj.file_id.length > 0 || locationObj.file_id.length > 0 || shortVideoObj.file_id.length >0 )
            {
                url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_TRANSENDFILE];
            }
            else
                url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_SENDFILE];
        }
            break;
    }
    
  
    
    NSString *fileExt = @"amr";
    if (MessageTypePicture == message.messageType || MessageTypeLocation == message.messageType || MessageTypeNotrace == message.messageType) {
        fileExt = @"jpg";
    }
    
    NSMutableDictionary *params = [[self commonBodyWithMessage:message] mutableCopy];
    
    //add by fang
    if(message.paramObj)
    {
        if (message.messageType == MessageTypeLocation) {
            MessageTypeLocationDataModel *paramObj = (MessageTypeLocationDataModel *)message.paramObj;
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"file_id":paramObj.file_id,@"addressName":paramObj.address,@"latitude":[NSString stringWithFormat:@"%f", paramObj.latitude],@"longitude":[NSString stringWithFormat:@"%f", paramObj.longitude]} options:NSJSONWritingPrettyPrinted error:nil];
            if (data)
            {
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(jsonStr)
                    [params setObject:jsonStr forKey:@"param"];
            }

        }
        else if (message.messageType == MessageTypeShortVideo) {
            MessageTypeShortVideoDataModel *paramObj = (MessageTypeShortVideoDataModel *)message.paramObj;
            //组装一下param数据
            NSData *jsonData  = [NSJSONSerialization dataWithJSONObject:@{@"fileId":paramObj.file_id,@"videoThumbnail":paramObj.videoThumbnail,@"size":paramObj.size,@"mtime":paramObj.mtime,@"name":paramObj.name,@"ext":paramObj.ext } options:NSJSONWritingPrettyPrinted error:nil];;

            if (jsonData)
            {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if(jsonStr)
                    [params setObject:jsonStr forKey:@"param"];
            }
            
        }else if (message.messageType == MessageTypeNotrace) {
//            MessageNotraceDataModel *paramObj = (MessageNotraceDataModel *)message.paramObj;
//            //组装一下param数据
//            NSData *jsonData  = [NSJSONSerialization dataWithJSONObject:@{@"name":paramObj.name,@"ext":paramObj.ext,@"content":paramObj.content,@"msgType":@(paramObj.msgType)} options:NSJSONWritingPrettyPrinted error:nil];
//            
//            if (jsonData)
//            {
//                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                if(jsonStr)
//                    [params setObject:jsonStr forKey:@"param"];
//            }
//            
        }
        else
        {
            MessageShareTextOrImageDataModel *paramObj = (MessageShareTextOrImageDataModel *)message.paramObj;
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"name":paramObj.name,@"ext":paramObj.ext} options:NSJSONWritingPrettyPrinted error:nil];
            if (data)
            {
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(jsonStr)
                    [params setObject:jsonStr forKey:@"param"];
            }
        }
    }

    [params setObject:[BOSConfig sharedConfig].user.wbNetworkId forKey:@"networkId"];
    
    if (fileExt) {
        [params setObject:fileExt forKey:@"fileExt"];
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setRequestMethod:@"POST"];
    
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    
    NSArray *allKeys = [params allKeys];
    
    for (NSString *key in allKeys) {
        [request setPostValue:params[key] forKey:key];
    }
    
    MessageTypeLocationDataModel *locationObj = nil;
    MessageShareTextOrImageDataModel *paramObj = nil;
    MessageTypeShortVideoDataModel *shortVideoObj = nil;
    MessageNotraceDataModel *notraceObj = nil;
    if (message.messageType == MessageTypeLocation) {
        locationObj = message.paramObj;
    }
    else if (message.messageType == MessageTypeShortVideo) {
        shortVideoObj = message.paramObj;
    }
    else if (message.messageType == MessageTypeNotrace) {
        notraceObj = message.paramObj;
    }
    else
    {
        paramObj = message.paramObj;
    }
//    MessageShareTextOrImageDataModel *paramObj = message.paramObj;
    
//    if(paramObj.fileId.length == 0 || locationObj.file_id.length == 0)
//        [request addData:message.sendData forKey:@"upload"];
//    else
//        [request setPostValue:message.clientMessageId forKey:@"mgsIds"];
    if(paramObj.fileId.length > 0 || notraceObj.file_id.length > 0 || locationObj.file_id.length > 0 || shortVideoObj.file_id > 0)
    {
        [request setPostValue:message.translateId forKey:@"mgsIds"];
    }
    else
    {
        [request addData:message.sendData forKey:@"upload"];
    }
        
    
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];

    NSDictionary *header = [self header];
    for (id key in header.allKeys) {
        [request addRequestHeader:key value:[header objectForKey:key]];
    }
    
    if (block) {
        request.userInfo = @{@"ResultHandler" : [block copy], @"Model" : message};
    }
    
    [request setTimeOutSeconds:kKDMessageHandlerTimeout];
    
    [self addOperation:request];
}



//- (void)sendTextMessage:(KDMessageModel *)message chatMode:(ChatMode)mode block:(KDMessageHandlerBlock)block
//{
//    NSString *url = nil;
//    
//    switch (mode) {
//        case ChatPublicMode:
//            url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_PUBLIC_SEND];
//            break;
//        case ChatPrivateMode:
//        default:
//            url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_MESSAGESEND];
//            break;
//    }
//    
//    NSMutableDictionary *params = [[self commonBodyWithMessage:message] mutableCopy];
//    
//    [params setObject:message.content forKey:@"content"];
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
//    [request setRequestMethod:@"POST"];
//    
//    NSData *requestData = nil;
//    if (params != nil) {
//        requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
//    }
//    else {
//        requestData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
//    }
//    
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    if (requestData) {
//        [request setPostBody:[NSMutableData dataWithData:requestData]];
//    }
//    NSDictionary *header = [self header];
//    for (id key in header.allKeys) {
//        [request addRequestHeader:key value:[header objectForKey:key]];
//    }
//    
//    if (block) {
//        request.userInfo = @{@"ResultHandler" : [block copy], @"Model" : message};
//    }
//    
//    [request setTimeOutSeconds:kKDMessageHandlerTimeout];
//    
//    [self addOperation:request];
//}



- (void)sendTextMessage:(KDMessageModel *)message chatMode:(ChatMode)mode block:(KDMessageHandlerBlock)block
{
    KDMessageHandlerBlock copyBlock = [block copy];
    
    NSString *url = nil;

    switch (mode) {
        case ChatPublicMode:
            url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_PUBLIC_SEND];
            break;
        case ChatPrivateMode:
        default:
            url = [[BOSSetting sharedSetting].url stringByAppendingString:EMPSERVERURL_MESSAGESEND];
            break;
    }

    NSMutableDictionary *params = [[self commonBodyWithMessage:message] mutableCopy];

    [params setObject:message.content forKey:@"content"];

    
    if(self.afManager == nil)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.afManager.operationQueue.maxConcurrentOperationCount = 50;
    }
    AFURLSessionManager *manager = self.afManager;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    NSData *requestData = nil;
    if (params != nil) {
        requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    }
    else {
        requestData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (requestData) {
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
    }
    
    NSDictionary *header = [self header];
    for (id key in header.allKeys) {
        [request setValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    
    
//    if (block) {
//        request = @{@"ResultHandler" : [block copy], @"Model" : message};
//    }
//
    
    request.timeoutInterval = kKDMessageHandlerTimeout;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (error) {
            if (copyBlock) {
                BOSResultDataModel *sendResult = [[BOSResultDataModel alloc] init];
                sendResult.success = NO;
                if (copyBlock) {
                    copyBlock(message, sendResult);
                }
            }
        } else {
            if (copyBlock)
            {
                NSInteger errorCode = httpResponse.statusCode;
                if (errorCode < 400) {//正常，无错误
                    errorCode = 0;
                }
                
                id result = nil;
                if (errorCode == 0) {
                    id jsonResult = responseObject;
                    if (jsonResult) {
                        result = jsonResult;
                    }else{
                        errorCode = BOSConnectParseResponseError;
                    }
                }
                
                BOSResultDataModel *sendResult = [[BOSResultDataModel alloc] initWithDictionary:result];
                
                if (copyBlock) {
                    copyBlock(message, sendResult);
                }
            }
        }
    }];
    [dataTask resume];
}


- (NSDictionary *)commonBodyWithMessage:(KDMessageModel *)message
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setObject:message.groupId forKey:@"groupId"];
    [params setObject:message.toUserId forKey:@"toUserId"];
    [params setObject:message.publicId forKey:@"publicId"];
    [params setObject:[NSString stringWithFormat:@"%d", message.messageType] forKey:@"msgType"];
    [params setObject:[NSString stringWithFormat:@"%ld", message.messageLength] forKey:@"msgLen"];
    [params setObject:message.param forKey:@"param"];
    [params setObject:message.isOriginalPic forKey:@"isOriginalPic"];
    [params setObject:message.clientMessageId forKey:@"clientMsgId"];
    [params setObject:[KDMessageHandler defaultUserAgent] forKey:@"ua"];
    return params;
}

-(NSDictionary *)header
{
    NSString *openToken = [BOSConfig sharedConfig].user.token;
    if (!openToken) {
        openToken = @"";
    }
    return [NSDictionary dictionaryWithObject:openToken forKey:@"openToken"];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.userInfo) {
        
        int errorCode = [request responseStatusCode];
        if (errorCode < 400) {//正常，无错误
            errorCode = 0;
        }
        
        id result = nil;
        if (errorCode == 0) {
            NSString *responseString = [request responseString];;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (jsonResult) {
                result = jsonResult;
            }else{
                errorCode = BOSConnectParseResponseError;
            }
        }
        
        BOSResultDataModel *sendResult = [[BOSResultDataModel alloc] initWithDictionary:result];
        
        KDMessageHandlerBlock block = request.userInfo[@"ResultHandler"];
        if (block) {
            block(request.userInfo[@"Model"], sendResult);
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.userInfo) {
        KDMessageHandlerBlock block = request.userInfo[@"ResultHandler"];
        BOSResultDataModel *sendResult = [[BOSResultDataModel alloc] init];
        sendResult.success = NO;
        if (block) {
            block(request.userInfo[@"Model"], sendResult);
        }
    }
}

@end
