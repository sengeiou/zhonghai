//
//  XTShareDataModel.m
//  XT
//
//  Created by Gil on 13-9-26.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTShareDataModel.h"

@implementation XTShareDataModel

- (id)init {
    self = [super init];
    if (self) {
        _appId = [[NSString alloc] init];
        _appName = [[NSString alloc] init];
        _shareType = 0;
        _mediaObject = nil;
        
        _theme = [[NSString alloc] init];
        _participantIds = nil;
        _system = [[NSString alloc] init];
        _unreadMonitor = 1;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    
    if (self) {
        
        id appId = [dict objectForKey:@"appId"];
        if (![appId isKindOfClass:[NSNull class]] && appId) {
            self.appId = appId;
        }
        
        id appName = [dict objectForKey:@"appName"];
        if (![appName isKindOfClass:[NSNull class]] && appName) {
            self.appName = appName;
        }
        
        id shareType = [dict objectForKey:@"shareType"];
        if (![shareType isKindOfClass:[NSNull class]] && shareType) {
            self.shareType = [shareType intValue];
        }
        
        id unreadMonitor = [dict objectForKey:@"unreadMonitor"];
        if (![unreadMonitor isKindOfClass:[NSNull class]] && unreadMonitor) {
            self.unreadMonitor = [unreadMonitor intValue];
        }
        
        id params = [dict objectForKey:@"params"];
        if ([params isKindOfClass:[NSDictionary class]] && params) {
            self.params = [NSMutableDictionary dictionaryWithDictionary:params];
        }
        else
            self.params = [NSMutableDictionary dictionary];
        
        switch (self.shareType) {
            case ShareMessageText:
            {
                id text = [dict objectForKey:@"text"];
                if (![text isKindOfClass:[NSNull class]] && text) {
                    XTShareTextDataModel *textDM = [[XTShareTextDataModel alloc] init];
                    textDM.text = text;
                    self.mediaObject = textDM;
                }
                break;
            }
            case ShareMessageImage:
            {
                id imageData = [dict objectForKey:@"imageData"];
                if (![imageData isKindOfClass:[NSNull class]] && imageData) {
                    XTShareImageDataModel *imageDM = [[XTShareImageDataModel alloc] init];
                    imageDM.imageData = imageData;
                    self.mediaObject = imageDM;
                }
                break;
            }
            case ShareMessageNews:
            {
                XTShareNewsDataModel *newsDM = [[XTShareNewsDataModel alloc] init];
                
                id title = [dict objectForKey:@"title"];
                if (![title isKindOfClass:[NSNull class]] && title) {
                    newsDM.title = title;
                }
                
                id content = [dict objectForKey:@"content"];
                if (![content isKindOfClass:[NSNull class]] && content) {
                    newsDM.content = content;
                }
                
                id thumbData = [dict objectForKey:@"thumbData"];
                if (![thumbData isKindOfClass:[NSNull class]] && thumbData) {
                    newsDM.thumbData = thumbData;
                }
                
                id thumbURL = [dict objectForKey:@"thumbUrl"];
                if(![thumbURL isKindOfClass:[NSNull class]] && thumbURL) {
                    newsDM.thumbURL = thumbURL;
                }
                
                id webpageUrl = [dict objectForKey:@"webpageUrl"];
                if (![webpageUrl isKindOfClass:[NSNull class]] && webpageUrl) {
                    newsDM.webpageUrl = webpageUrl;
                }
                
                self.mediaObject = newsDM;
                
                break;
            }
            case ShareMessageApplication:
            case ShareMessageRedPacket://红包沿用应用分享的消息
            {
                XTShareApplicationDataModel *applicationDM = [[XTShareApplicationDataModel alloc] init];
                
                id title = [dict objectForKey:@"title"];
                if (![title isKindOfClass:[NSNull class]] && title) {
                    applicationDM.title = title;
                }
                
                id content = [dict objectForKey:@"content"];
                if (![content isKindOfClass:[NSNull class]] && content) {
                    applicationDM.content = content;
                }
                
                id thumbData = [dict objectForKey:@"thumbData"];
                if (![thumbData isKindOfClass:[NSNull class]] && thumbData) {
                    applicationDM.thumbData = thumbData;
                }
                
                id thumbUrl = [dict objectForKey:@"thumbUrl"];
                if(![thumbUrl isKindOfClass:[NSNull class]] && thumbUrl) {
                    applicationDM.thumbURL = thumbUrl;
                }
                
                id webpageUrl = [dict objectForKey:@"webpageUrl"];
                if (![webpageUrl isKindOfClass:[NSNull class]] && webpageUrl) {
                    applicationDM.webpageUrl = webpageUrl;
                }
                
                id cellContent = [dict objectForKey:@"cellContent"];
                if (![cellContent isKindOfClass:[NSNull class]] && cellContent) {
                    applicationDM.cellContent = cellContent;
                }
                
                id sharedObject = [dict objectForKey:@"sharedObject"];
                if (![sharedObject isKindOfClass:[NSNull class]] && sharedObject) {
                    applicationDM.sharedObject = sharedObject;
                }
                
                id callbackUrl = [dict objectForKey:@"callbackUrl"];
                if (![callbackUrl isKindOfClass:[NSNull class]] && callbackUrl) {
                    applicationDM.callbackUrl = callbackUrl;
                }
                
                id lightAppId = [dict objectForKey:@"lightAppId"];
                if (![lightAppId isKindOfClass:[NSNull class]] && lightAppId) {
                    applicationDM.lightAppId = lightAppId;
                }
                
                self.mediaObject = applicationDM;
                
                break;
            }
                
            case ShareMessageCombineForward: {
                XTShareCombineForwardDataModel *model = [XTShareCombineForwardDataModel new];
                
                id content = [dict objectForKey:@"content"];
                if (![content isKindOfClass:[NSNull class]] && content) {
                    model.content = content;
                }
                
                id mergeId = [dict objectForKey:@"mergeId"];
                if (![mergeId isKindOfClass:[NSNull class]] && mergeId) {
                    model.mergeId = mergeId;
                }
                
                id title = [dict objectForKey:@"title"];
                if (![title isKindOfClass:[NSNull class]] && title) {
                    model.title = title;
                }
                self.mediaObject = model;
                
                break;
            }
            default:
                break;
        }
        
        id theme = [dict objectForKey:@"theme"];
        if (![theme isKindOfClass:[NSNull class]] && theme) {
            self.theme = theme;
        }
        
        id participantIdsString = [dict objectForKey:@"participantIds"];
        if (![participantIdsString isKindOfClass:[NSNull class]] && participantIdsString) {
            NSArray *participantIds = [participantIdsString componentsSeparatedByString:@"||"];
            self.participantIds = participantIds;
        }
        
        id system = [dict objectForKey:@"system"];
        if (![system isKindOfClass:[NSNull class]] && system) {
            self.system = system;
        }
        
        id personIds = [dict objectForKey:@"personIds"];
        if (![personIds isKindOfClass:[NSNull class]] && personIds) {
            self.personIds = personIds;
        }
    }
    return self;
}

@end

@implementation XTShareTextDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _text = [[NSString alloc] init];
    }
    return self;
}

@end

@implementation XTShareImageDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _imageData = [[NSString alloc] init];
    }
    return self;
}

@end

@implementation XTShareNewsDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _title = [[NSString alloc] init];
        _content = [[NSString alloc] init];
        _thumbData = [[NSString alloc] init];
        _webpageUrl = [[NSString alloc] init];
    }
    return self;
}

@end

@implementation XTShareApplicationDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _cellContent = [[NSString alloc] init];
        _sharedObject = [[NSString alloc] init];
        _callbackUrl = [[NSString alloc] init];
        _lightAppId = [[NSString alloc] init];
    }
    return self;
}

- (BOOL)sharedToGroup
{
    return [self.sharedObject isEqualToString:@"group"];
}

- (BOOL)sharedToPerson
{
    return [self.sharedObject isEqualToString:@"person"];
}

@end


@implementation XTShareCombineForwardDataModel

- (id)init
{
    self = [super init];
    if (self) {
        _content = [[NSString alloc] init];
        _mergeId = [[NSString alloc] init];
        _title = [[NSString alloc] init];
    }
    return self;
}


@end
