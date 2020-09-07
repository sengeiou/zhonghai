//
//  RecordDataModel.m
//  ContactsLite
//
//  Created by Gil on 12-12-10.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import "RecordDataModel.h"
#import "ContactConfig.h"
#import "ContactUtils.h"
#import "PersonDataModel.h"
#import "ContactClient.h"
#import "BOSUtils.h"
#import "BOSConfig.h"
#import "XTFileUtils.h"
#import "XTCloudClient.h"
#import "KDWeiboServicesContext.h"

@implementation MessageAttachEachDataModel

- (id)init {
    self = [super init];
    if (self) {
        _name = [[NSString alloc] init];
        _value = [[NSString alloc] init];
        _appId = [[NSString alloc] init];
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
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name != nil) {
            self.name = name;
        }
        id value = [dict objectForKey:@"value"];
        if (![value isKindOfClass:[NSNull class]] && value != nil) {
            self.value = value;
        }
        
        id appId = [dict objectForKey:@"appid"];
        if (![appId isKindOfClass:[NSNull class]] && appId != nil) {
            self.appId = appId;
        }
        
    }
    return self;
}

@end

@implementation MessageAttachDataModel

- (id)init {
    self = [super init];
    if (self) {
        _attach = [[NSArray alloc] init];
        _attachCount = 0;
        _billId = [[NSString alloc] init];
        _appId = [[NSString alloc] init];
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
        id attach = [dict objectForKey:@"attach"];
        if (attach != nil && [attach isKindOfClass:[NSArray class]] && [(NSArray *)attach count] > 0) {
            NSMutableArray *attachs = [NSMutableArray array];
            [attach enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageAttachEachDataModel *attachDM = [[MessageAttachEachDataModel alloc] initWithDictionary:obj];
                [attachs addObject:attachDM];
            }];
            self.attach = attachs;
        }
        id attachCount = [dict objectForKey:@"attachCount"];
        if (![attachCount isKindOfClass:[NSNull class]] && attachCount != nil) {
            self.attachCount = [attachCount intValue];
        }
        id billId = [dict objectForKey:@"billId"];
        if (![billId isKindOfClass:[NSNull class]] && billId != nil) {
            self.billId = billId;
        }
        
        id appId = [dict objectForKey:@"appid"];
        if (![appId isKindOfClass:[NSNull class]] && appId != nil) {
            self.appId = appId;
        }
        
    }
    return self;
}

@end

@implementation MessageTypeNewsEventsModel
- (id)init {
    self = [super init];
    if (self) {
        _title = [[NSString alloc] init];
        _event = [[NSString alloc] init];
        _url = [[NSString alloc] init];
        _appid = [[NSString alloc] init];
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
        id n_title = [dict objectForKey:@"title"];
        if (![n_title isKindOfClass:[NSNull class]] && n_title != nil) {
            self.title = n_title;
        }
        
        id n_event = [dict objectForKey:@"event"];
        if (![n_event isKindOfClass:[NSNull class]] && n_event != nil) {
            self.event = n_event;
        }
        
        id n_url = [dict objectForKey:@"url"];
        if (![n_url isKindOfClass:[NSNull class]] && n_url != nil) {
            self.url = n_url;
        }
        
        id n_appid = [dict objectForKey:@"appid"];
        if (![n_appid isKindOfClass:[NSNull class]] && n_appid != nil) {
            self.appid = n_appid;
        }
    }
    return self;
}

@end

@implementation MessageNewsEachDataModel

- (id)init {
    self = [super init];
    if (self) {
        _date = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _text = [[NSString alloc] init];
        _title = [[NSString alloc] init];
        _url = [[NSString alloc] init];
        _appId = [[NSString alloc] init];
        _row = 0;
        _buttons = [NSMutableArray array];
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
        id n_date = [dict objectForKey:@"date"];
        if (![n_date isKindOfClass:[NSNull class]] && n_date != nil) {
            self.date = n_date;
        }
        
        id n_name = [dict objectForKey:@"name"];
        if (![n_name isKindOfClass:[NSNull class]] && n_name != nil) {
            self.name = n_name;
        }
        
        id n_text = [dict objectForKey:@"text"];
        if (![n_text isKindOfClass:[NSNull class]] && n_text != nil) {
            self.text = n_text;
        }
        
        id n_title = [dict objectForKey:@"title"];
        if (![n_title isKindOfClass:[NSNull class]] && n_title != nil) {
            self.title = n_title;
        }
        
        id n_url = [dict objectForKey:@"url"];
        if (![n_url isKindOfClass:[NSNull class]] && n_url != nil) {
            self.url = n_url;
        }
        
        id n_appId = [dict objectForKey:@"appid"];
        if (![n_appId isKindOfClass:[NSNull class]] && n_appId != nil) {
            self.appId = n_appId;
        }
        
        id row = [dict objectForKey:@"row"];
        if (![row isKindOfClass:[NSNull class]] && row != nil) {
            self.row = row;
        }
        
        id n_buttons = [dict objectForKey:@"button"];
        if (n_buttons != nil && [n_buttons isKindOfClass:[NSArray class]] && [(NSArray *)n_buttons count] > 0) {
            
            NSMutableArray *buttons = [NSMutableArray array];
            [n_buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageTypeNewsEventsModel *newDM = [[MessageTypeNewsEventsModel alloc] initWithDictionary:obj];
                [buttons addObject:newDM];
            }];
            self.buttons = buttons;
        }
        
    }
    return self;
}

- (BOOL)hasHeaderPicture
{
    return self.name.length > 0 && ![self.name isEqualToString:@"(null)"];
}

- (BOOL)isSubNews{
    return  ([self.title isEqualToString:self.text] || self.title.length == 0);
}

@end

@implementation MessageNewsDataModel

- (id)init {
    self = [super init];
    if (self) {
        _newslist = [[NSMutableArray alloc] init];
        _model = 0;
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
        id model = [dict objectForKey:@"model"];
        if (![model isKindOfClass:[NSNull class]] && model != nil) {
            self.model = [model intValue];
        }
        
        id todoNotify = [dict objectForKey:@"todoNotify"];
        if (![todoNotify isKindOfClass:[NSNull class]] && todoNotify != nil) {
            self.todoNotify = [todoNotify boolValue];
        }
        
        id list = [dict objectForKey:@"list"];
        if (list != nil && [list isKindOfClass:[NSArray class]] && [(NSArray *)list count] > 0) {
            NSMutableArray *news = [NSMutableArray array];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageNewsEachDataModel *newDM = [[MessageNewsEachDataModel alloc] initWithDictionary:obj];
                [news addObject:newDM];
            }];
            self.newslist = news;
        }
        
    }
    return self;
}

@end

@implementation MessageShareNewsDataModel

- (id)init {
    self = [super init];
    if (self) {
        _appId = [[NSString alloc] init];
        _appName = [[NSString alloc] init];
        _title = [[NSString alloc] init];
        _content = [[NSString alloc] init];
        _thumbUrl = [[NSString alloc] init];
        _webpageUrl = [[NSString alloc] init];
        _lightAppId = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id appId = [dict objectForKey:@"appId"];
        if (![appId isKindOfClass:[NSNull class]] && appId != nil) {
            self.appId = appId;
        }
        id appName = [dict objectForKey:@"appName"];
        if (![appName isKindOfClass:[NSNull class]] && appName != nil) {
            self.appName = appName;
        }
        id title = [dict objectForKey:@"title"];
        if (![title isKindOfClass:[NSNull class]] && title != nil) {
            self.title = title;
        }
        id content = [dict objectForKey:@"content"];
        if (![content isKindOfClass:[NSNull class]] && content != nil) {
            self.content = content;
        }
        id thumbUrl = [dict objectForKey:@"thumbUrl"];
        if (![thumbUrl isKindOfClass:[NSNull class]] && thumbUrl != nil) {
            self.thumbUrl = thumbUrl;
        }
        id webpageUrl = [dict objectForKey:@"webpageUrl"];
        if (![webpageUrl isKindOfClass:[NSNull class]] && webpageUrl != nil) {
            self.webpageUrl = webpageUrl;
        }
        id lightAppId = [dict objectForKey:@"lightAppId"];
        if (![lightAppId isKindOfClass:[NSNull class]] && lightAppId != nil) {
            self.lightAppId = lightAppId;
        }
    }
    return self;
}

@end

@implementation MessageShareTextOrImageDataModel

- (id)init {
    self = [super init];
    if (self) {
        _appId = [[NSString alloc] init];
        _appName = [[NSString alloc] init];
        
        _effectiveDuration = 0;
        _clientTime = nil;
        
        _replyMsgId = [NSString new];
        _replyPersonName = [NSString new];
        _replySummary = [NSString new];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id appId = [dict objectForKey:@"appId"];
        if (![appId isKindOfClass:[NSNull class]] && appId != nil) {
            self.appId = appId;
        }
        id appName = [dict objectForKey:@"appName"];
        if (![appName isKindOfClass:[NSNull class]] && appName != nil) {
            self.appName = appName;
        }
        id effectiveDuration = [dict objectForKey:@"effectiveDuration"];
        if (![effectiveDuration isKindOfClass:[NSNull class]] && effectiveDuration != nil) {
            self.effectiveDuration = [effectiveDuration intValue];
        }
        
        //消息回复使用
        id replyMsgId = [dict objectForKey:@"replyMsgId"];
        if (![replyMsgId isKindOfClass:[NSNull class]] && replyMsgId != nil) {
            self.replyMsgId = replyMsgId;
        }
        id replyPersonName = [dict objectForKey:@"replyPersonName"];
        if (![replyPersonName isKindOfClass:[NSNull class]] && replyPersonName != nil) {
            self.replyPersonName = replyPersonName;
        }
        id replySummary = [dict objectForKey:@"replySummary"];
        if (![replySummary isKindOfClass:[NSNull class]] && replySummary != nil) {
            self.replySummary = replySummary;
        }
        
        id clientTime = [dict objectForKey:@"clientTime"];
        if (![clientTime isKindOfClass:[NSNull class]] && clientTime != nil) {
            NSDateFormatter *fdf = [[NSDateFormatter alloc] init];
            [fdf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *now = [fdf dateFromString:clientTime];
            self.clientTime = now;
        }
        
        
        id fileId = [dict objectForKey:@"fileId"];
        if (![fileId isKindOfClass:[NSNull class]] && fileId != nil) {
            self.fileId = fileId;
        }
        
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name != nil) {
            self.name = name;
        }
        
        id ext = [dict objectForKey:@"ext"];
        if (![ext isKindOfClass:[NSNull class]] && ext != nil) {
            self.ext = ext;
        }
    }
    return self;
}

@end

@implementation MessageFileDataModel

- (id)init {
    self = [super init];
    if (self) {
        _appId = [[NSString alloc] init];
        _appName = [[NSString alloc] init];
        _file_id = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _uploadDate = [[NSString alloc] init];
        _size = [[NSString alloc] init];
        _ext = [[NSString alloc] init];
        _emojiType = [[NSString alloc] init];
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
        id appId = [dict objectForKey:@"appId"];
        if (![appId isKindOfClass:[NSNull class]] && appId != nil) {
            self.appId = appId;
        }
        id appName = [dict objectForKey:@"appName"];
        if (![appName isKindOfClass:[NSNull class]] && appName != nil) {
            self.appName = appName;
        }
        id fileId = [dict objectForKey:@"file_id"];
        if (![fileId isKindOfClass:[NSNull class]] && fileId != nil) {
            self.file_id = fileId;
        }
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name != nil) {
            self.name = name;
        }
        id uploadDate = [dict objectForKey:@"uploadDate"];
        if (![uploadDate isKindOfClass:[NSNull class]] && uploadDate != nil) {
            self.uploadDate = uploadDate;
        }
        id size = [dict objectForKey:@"size"];
        if (![size isKindOfClass:[NSNull class]] && size != nil) {
            if ([size isKindOfClass:[NSString class]]) {
                self.size = size;
            }
            else if ([size isKindOfClass:[NSNumber class]])
            {
                self.size = [NSString stringWithFormat:@"%@",size];
            }
        }
        id ext = [dict objectForKey:@"ext"];
        if (![ext isKindOfClass:[NSNull class]] && ext != nil) {
            self.ext = [ext stringByReplacingOccurrencesOfString:@"." withString:@""];
        } else {
            self.ext = @"null";
        }
        id emojiType = [dict objectForKey:@"emojiType"];
        if (![emojiType isKindOfClass:[NSNull class]] && emojiType != nil) {
            self.emojiType = emojiType;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryFromMessageFileDataModel
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.file_id,@"file_id", self.name, @"name", self.uploadDate,@"uploadDate", self.size,@"size", self.ext,@"ext",self.emojiType,@"emojiType",nil];
    return dict;
}

@end

@implementation MessageTypeLocationDataModel

- (id)init {
    self = [super init];
    if (self) {
        _address = [[NSString alloc] init];
        _file_id = [[NSString alloc] init];
        _latitude = 0.0f;
        _longitude = 0.0f;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id address = [dict objectForKey:@"addressName"];
        if (![address isKindOfClass:[NSNull class]] && address != nil) {
            self.address = address;
        }
        id fileId = [dict objectForKey:@"fileId"];
        if (![fileId isKindOfClass:[NSNull class]] && fileId != nil) {
            self.file_id = fileId;
        }
        id latitude = [dict objectForKey:@"latitude"];
        if (![latitude isKindOfClass:[NSNull class]] && latitude != nil) {
            self.latitude = [latitude floatValue];
        }
        id longitude = [dict objectForKey:@"longitude"];
        if (![longitude isKindOfClass:[NSNull class]] && longitude != nil) {
            self.longitude = [longitude floatValue];
        }
        
    }
    return self;
}

@end

@implementation MessageTypeShortVideoDataModel

- (id)init {
    self = [super init];
    if (self) {
        
        _file_id = [[NSString alloc] init];
        _ext = [[NSString alloc] init];
        _videoThumbnail = [[NSString alloc] init];
        _mtime = [[NSString alloc] init];
        _size = [[NSString alloc] init];
        _videoUrl = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _videoTimeLength = [[NSString alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
            id fileId = [dict objectForKey:@"fileId"];
        if (![fileId isKindOfClass:[NSNull class]] && fileId != nil) {
            self.file_id = fileId;
        }
        
        id ext = [dict objectForKey:@"ext"];
        if (![ext isKindOfClass:[NSNull class]] && ext != nil) {
            self.ext = [ext stringByReplacingOccurrencesOfString:@"." withString:@""];
        } else {
            self.ext = @"null";
        }
    
        id videoThumbnail = [dict objectForKey:@"videoThumbnail"];
        if (![videoThumbnail isKindOfClass:[NSNull class]] && videoThumbnail != nil) {
            self.videoThumbnail = videoThumbnail;
        }

        id mtime = [dict objectForKey:@"mtime"];
        if (![mtime isKindOfClass:[NSNull class]] && mtime != nil) {
            self.mtime = mtime;
        }
        
        id size = [dict objectForKey:@"size"];
        if (![size isKindOfClass:[NSNull class]] && size != nil) {
            if ([size isKindOfClass:[NSString class]]) {
                self.size = size;
            }
            else if ([size isKindOfClass:[NSNumber class]])
            {
                self.size = [NSString stringWithFormat:@"%@",size];
            }
        }

        
        id videoUrl = [dict objectForKey:@"videoUrl"];
        if (![videoUrl isKindOfClass:[NSNull class]] && videoUrl != nil) {
            self.videoUrl = videoUrl;
        }
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name != nil) {
            self.name = name;
        }
        id videoTimeLength = [dict objectForKey:@"videoTimeLength"];
        if (![videoTimeLength isKindOfClass:[NSNull class]] && videoTimeLength != nil) {
            self.videoTimeLength = videoTimeLength;
        }

    }
    return self;
}

-(NSString *)videoSize
{
    NSString *result = @"";
    if (self.size.intValue / 1024 >= 1024) {
        result = [NSString stringWithFormat:@"%.2fMB", self.size.floatValue / 1024 / 1024];
    }else {
        result = [NSString stringWithFormat:@"%dKB", (int)self.size.intValue / 1024];
    }
    return result;
}

-(NSString *)videoDuartion
{
    return [NSString stringWithFormat:@"0:%02ld",[self.videoTimeLength integerValue]];
}

-(NSString *)thumbImageUrl
{
    NSString *path =[NSString stringWithFormat:@"%@/microblog/filesvr/%@",[[KDWeiboServicesContext defaultContext] serverBaseURL],self.videoThumbnail];
    return path;
}
@end

@implementation MessageNotraceDataModel

- (id)init {
    self = [super init];
    if (self) {
        _content = [[NSString alloc] init];
        _file_id = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _uploadDate = [[NSString alloc] init];
        _size = [[NSString alloc] init];
        _ext = [[NSString alloc] init];
        
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
        id msgType = [dict objectForKey:@"msgType"];
        if (![msgType isKindOfClass:[NSNull class]] && msgType != nil) {
            self.msgType = [msgType intValue];
        }
        
        id content = [dict objectForKey:@"content"];
        if (![content isKindOfClass:[NSNull class]] && content != nil) {
            self.content = content;
        }
        
        id effectiveDuration = [dict objectForKey:@"effectiveDuration"];
        if (![effectiveDuration isKindOfClass:[NSNull class]] && effectiveDuration != nil) {
            self.effectiveDuration = [effectiveDuration intValue];
        }
        
        id file_id = [dict objectForKey:@"fileId"];
        if (![file_id isKindOfClass:[NSNull class]] && file_id != nil) {
            self.file_id = file_id;
        }
        
        id name = [dict objectForKey:@"name"];
        if (![name isKindOfClass:[NSNull class]] && name != nil) {
            self.name = name;
        }
        
        id uploadDate = [dict objectForKey:@"uploadDate"];
        if (![uploadDate isKindOfClass:[NSNull class]] && uploadDate != nil) {
            self.uploadDate = uploadDate;
        }
        
        id size = [dict objectForKey:@"size"];
        if (![size isKindOfClass:[NSNull class]] && size != nil) {
            self.size = size;
        }
        
        id ext = [dict objectForKey:@"ext"];
        if (![ext isKindOfClass:[NSNull class]] && ext != nil) {
            self.ext = ext;
        }
    }
    return self;
}
@end

@implementation MessageCombineForwardDataModel

- (id)init {
    self = [super init];
    if (self) {
        _content = [[NSString alloc] init];
        _mergeId = [[NSString alloc] init];
        _title = [[NSString alloc] init];
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
        
        id content = [dict objectForKey:@"content"];
        if (![content isKindOfClass:[NSNull class]] && content != nil) {
            self.content = content;
        }
        
        id mergeId = [dict objectForKey:@"mergeId"];
        if (![mergeId isKindOfClass:[NSNull class]] && mergeId != nil) {
            self.mergeId = mergeId;
        }
        
        id title = [dict objectForKey:@"title"];
        if (![title isKindOfClass:[NSNull class]] && title != nil) {
            self.title = title;
        }
    }
    return self;
}
@end


@implementation MessageParamDataModel
- (id)init {
    self = [super init];
    if (self) {
        _type = 0;
        _paramObject = nil;
        _paramString = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict type:(MessageType)type
{
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        
        self.type = type;
        self.paramString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        
        switch (type) {
            case MessageTypeText:
            case MessageTypePicture:
            {
                MessageShareTextOrImageDataModel *textOrImage = [[MessageShareTextOrImageDataModel alloc] initWithDictionary:dict];
                self.paramObject = textOrImage;
                break;
            }
            case MessageTypeAttach:
            {
                MessageAttachDataModel *attach = [[MessageAttachDataModel alloc] initWithDictionary:dict];
                self.paramObject = attach;
                break;
            }
            case MessageTypeNews:
            {
                MessageNewsDataModel *news = [[MessageNewsDataModel alloc] initWithDictionary:dict];
                self.paramObject = news;
                break;
            }
            case MessageTypeShareNews:
            {
                MessageShareNewsDataModel *news = [[MessageShareNewsDataModel alloc] initWithDictionary:dict];
                self.paramObject = news;
                break;
            }
            case MessageTypeFile:
            {
                MessageFileDataModel *file = [[MessageFileDataModel alloc] initWithDictionary:dict];
                self.paramObject = file;
                break;
            }
            case MessageTypeLocation:
            {
                MessageTypeLocationDataModel *locatinoInfo = [[MessageTypeLocationDataModel alloc] initWithDictionary:dict];
                self.paramObject = locatinoInfo;
                break;
            }
            case MessageTypeShortVideo:
            {
                MessageTypeShortVideoDataModel *shortVideoInfo = [[MessageTypeShortVideoDataModel alloc] initWithDictionary:dict];
                self.paramObject = shortVideoInfo;
                break;
            }
            case MessageTypeNotrace:
            {
                MessageNotraceDataModel *notraceInfo = [[MessageNotraceDataModel alloc] initWithDictionary:dict];
                self.paramObject = notraceInfo;
                break;
            }
            case MessageTypeCombineForward:
            {
                MessageCombineForwardDataModel *combineInfo = [[MessageCombineForwardDataModel alloc] initWithDictionary:dict];
                self.paramObject = combineInfo;
                break;
            }
                // TODO: MessageTypeEvent，暂不做解析，因为不需要展现
            default:
                break;
        }
    }
    return self;
}

- (id)initWithJSONString:(NSString *)jsonString type:(MessageType)type
{
    if (jsonString.length > 0) {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        return [self initWithDictionary:jsonObject type:type];
    }
    return [self init];
}

@end

@implementation RecordDataModel

- (id)init {
    self = [super init];
    if (self) {
        _fromUserId = [[NSString alloc] init];
        _sendTime = [[NSString alloc] init];
        _msgId = [[NSString alloc] init];
        _msgType = MessageTypeSystem;
        _status = MessageStatusUnread;
        _msgLen = 0;
        _content = [[NSString alloc] init];
        _msgDirection = MessageDirectionRight;
        _nickname = [[NSString alloc] init];
        _param = nil;
        _msgPlayType = MessagePlayTypeSuccess;
        _msgRequestState = MessageRequestStateSuccess;
        _groupId = [[NSString alloc] init];
        _sourceMsgId = [[NSString alloc]init];
        _isOriginalPic = [[NSString alloc]init];
        _clientMsgId = [NSString new];
        _todoStatus = [[NSString alloc]init];
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
        id fromUserId = [dict objectForKey:@"fromUserId"];
        id sendTime = [dict objectForKey:@"sendTime"];
        id msgId = [dict objectForKey:@"msgId"];
        id msgType = [dict objectForKey:@"msgType"];
        id status = [dict objectForKey:@"status"];
        id msgLen = [dict objectForKey:@"msgLen"];
        id content = [dict objectForKey:@"content"];
        id direction = [dict objectForKey:@"direction"];
        id nickname = [dict objectForKey:@"nickname"];
        id sourceMsgId = [dict objectForKey:@"sourceMsgId"];
        id isOriginalPic = [dict objectForKey:@"isOriginalPic"];
        id fromClientId = [dict objectForKey:@"fromClientId"];
        id todoStatus = [dict objectForKey:@"todoStatus"];
        if (![fromUserId isKindOfClass:[NSNull class]] && fromUserId) {
            self.fromUserId = fromUserId;
        }
        id clientMsgId = [dict objectForKey:@"clientMsgId"];
        
        if (![clientMsgId isKindOfClass:[NSNull class]] && clientMsgId) {
            self.clientMsgId = clientMsgId;
        }
        
        if (![sendTime isKindOfClass:[NSNull class]] && sendTime) {
            self.sendTime = sendTime;
        }
        if (![msgId isKindOfClass:[NSNull class]] && msgId) {
            self.msgId = msgId;
        }
        if (![msgType isKindOfClass:[NSNull class]] && msgType) {
            self.msgType = [msgType intValue];
        }
        if (![status isKindOfClass:[NSNull class]] && status) {
            self.status = [status intValue];
        }
        if (![msgLen isKindOfClass:[NSNull class]] && msgLen) {
            self.msgLen = [msgLen intValue];
        }
        if (![content isKindOfClass:[NSNull class]] && content) {
            self.content = content;
        }
        if (![direction isKindOfClass:[NSNull class]] && direction) {
            self.msgDirection = [direction intValue];
        }
        if (![nickname isKindOfClass:[NSNull class]] && nickname) {
            self.nickname = nickname;
        }
        if (![sourceMsgId isKindOfClass:[NSNull class]] && sourceMsgId) {
            self.sourceMsgId = sourceMsgId;
        }
        if (![isOriginalPic isKindOfClass:[NSNull class]] && isOriginalPic) {
            self.isOriginalPic = isOriginalPic;
        }
        else
        {
            self.isOriginalPic = @"0";
        }
        if (![fromClientId isKindOfClass:[NSNull class]] && fromClientId != nil) {
            self.fromClientId = fromClientId;
        }
        if (![todoStatus isKindOfClass:[NSNull class]] && todoStatus != nil) {
            self.todoStatus = todoStatus;
        }
        
        
        // 提及 4 接收消息 recordtimeline.action 返回 新增提醒信息
        id param = [dict objectForKey:@"param"];
        if (![param isKindOfClass:[NSNull class]] && param != nil)
        {
            self.iNotifyType = [[param objectNotNSNullForKey:@"notifyType"] intValue];
            self.strNotifyDesc = [param objectNotNSNullForKey:@"notifyDesc"];
            self.strEmojiType = [param objectNotNSNullForKey:@"emojiType"];
            self.bImportant = [[param objectNotNSNullForKey:@"important"] boolValue];
            
            MessageParamDataModel *paramDM = [[MessageParamDataModel alloc] initWithDictionary:param type:self.msgType];
            self.param = paramDM;
        }
        
    }
    return self;
}

- (NSString *)xtFilePath
{
    if (_msgType != MessageTypeSpeech) {
        return nil;
    }
    if ([@"" isEqualToString:_msgId]) {
        return nil;
    }
    
    NSString *filePath = nil;
    if (![@"" isEqualToString:_groupId]) {
        filePath = [[ContactUtils recordFilePathWithGroupId:_groupId] stringByAppendingFormat:@"/%@%@",_msgId,XTFileExt];
    }
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    
    filePath = [[ContactUtils recordTempFilePath] stringByAppendingFormat:@"/%@%@",_msgId,XTFileExt];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    
    return nil;
}

- (NSURL *)thumbnailPictureUrl
{
    return [self pictureUrlWithWidth:120 height:120];
}

- (NSURL *)originalPictureUrl
{
    return [self pictureUrlWithWidth:0 height:0];
}
- (NSURL *)midPictureUrl
{
    CGSize size = [self isHighResolutionDevice]?CGSizeMake(480.0, 360.0):CGSizeMake(240.f, 180.f);
    return [self pictureUrlWithWidth:size.width height:size.height];
}

//可以转发的图片url
- (NSURL *)canTransmitUrl
{
    NSURL *url = [self originalPictureUrl];
    BOOL isExist = [[SDWebImageManager sharedManager]diskImageExistsForURL:url imageScale:SDWebImageScalePreView];
    if(isExist)
        return url;
    
    isExist = [[SDWebImageManager sharedManager]diskImageExistsForURL:url imageScale:SDWebImageScaleNone];
    if(isExist)
        return url;
    
    url = [self midPictureUrl];
    isExist = [[SDWebImageManager sharedManager]diskImageExistsForURL:url];
    if(isExist)
        return url;
    
    return nil;
}

//大图，实际上这才是原图
//对于消息，只有一种图  对于文件 实际上是有中图和大图
- (NSURL *)bigPictureUrl
{
    return [self pictureUrlWithWidth:-1 height:-1];
}

- (NSURL *)pictureUrlWithWidth:(int)width height:(int)height
{
    switch (self.msgType) {
        case MessageTypePicture:
        case MessageTypeLocation:
        case MessageTypeShortVideo:
        {
            NSLog(@"%@",[NSURL URLWithString:[[BOSSetting sharedSetting].url stringByAppendingFormat:@"%@?msgId=%@&width=%d&height=%d",EMPSERVERURL_HTTPGETIMAGE,self.msgId,MAX(width, 0),MAX(height, 0)]]);
            return [NSURL URLWithString:[[BOSSetting sharedSetting].url stringByAppendingFormat:@"%@?msgId=%@&width=%d&height=%d",EMPSERVERURL_HTTPGETIMAGE,self.msgId,MAX(width, 0),MAX(height, 0)]];
        }
            
            
        case MessageTypeFile:
        {
            MessageFileDataModel *file = (MessageFileDataModel *)self.param.paramObject;
            if ([XTFileUtils isPhotoExt:file.ext]) {
                NSString *url = [[[KDWeiboServicesContext defaultContext] serverBaseURL] stringByAppendingFormat:@"%@", @"/microblog/filesvr/"];
                if (width == 0) {
                    //原图
                    url = [url stringByAppendingFormat:@"%@?original", file.file_id];
                }
                else if (width < 0) {
                    //大图
                    url = [url stringByAppendingFormat:@"%@?big", file.file_id];
                }
                else {
                    //缩略图
                    url = [url stringByAppendingFormat:@"%@?thumbnail", file.file_id];
                }
                return [NSURL URLWithString:url];
            }
        }
        case MessageTypeNotrace:
        {
            MessageNotraceDataModel *file = (MessageNotraceDataModel *)self.param.paramObject;
            NSString *url = [[[KDWeiboServicesContext defaultContext] serverBaseURL] stringByAppendingFormat:@"%@", @"/microblog/filesvr/"];
            if (width == 0) {
                //中图
                url = [url stringByAppendingFormat:@"%@", file.file_id];
            }
            else if (width < 0) {
                //大图
                url = [url stringByAppendingFormat:@"%@?big", file.file_id];
            }
            else {
                //缩略图
                url = [url stringByAppendingFormat:@"%@?thumbnail", file.file_id];
            }
            return [NSURL URLWithString:url];
        }
        default:
            return nil;
    }
}
- (BOOL)isHighResolutionDevice {
    return ([UIScreen mainScreen].scale + 0.01) > 2.0;
}
- (BOOL)isPicture
{
    switch (self.msgType) {
        case MessageTypePicture:
            return YES;
        case MessageTypeFile:
        case MessageTypeLocation:
        {
            MessageFileDataModel *file = (MessageFileDataModel *)self.param.paramObject;
            return [XTFileUtils isPhotoExt:file.ext];
        }
        case MessageTypeShortVideo:
        {
            MessageFileDataModel *file = (MessageFileDataModel *)self.param.paramObject;
            return [XTFileUtils isPhotoExt:file.ext];
        }
        default:
            return NO;
    }
}
- (NSString *)username{
    PersonSimpleDataModel *person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:_fromUserId];
    return person.personName;
}
#pragma mark - super

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[RecordDataModel class]]) {
        return NO;
    }
    RecordDataModel *record = (RecordDataModel *)object;
    return [record.msgId isEqualToString:self.msgId];
}

@end



