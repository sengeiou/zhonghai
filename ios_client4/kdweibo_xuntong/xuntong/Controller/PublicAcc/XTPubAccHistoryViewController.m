//
//  XTPubAccHistoryViewController.m
//  kdweibo
//
//  Created by fang.jiaxin on 16/5/17.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "XTPubAccHistoryViewController.h"
#import "BubbleDataInternal.h"
#import "BubbleTableViewCell.h"
#import "RecordListDataModel.h"
#import "BOSConfig.h"
#import "XTFileUtils.h"
#import "NSString+Scheme.h"
#import "NSString+DZCategory.h"
#import "ContactUtils.h"
#import "MJRefresh.h"
#import "KDWeiboAppDelegate.h"
#import "KDWaterMarkAddHelper.h"

#define PageSize 10
@interface XTPubAccHistoryViewController ()<UITableViewDelegate,UITableViewDataSource,BubbleImageViewDelegate>

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UITableView *bubbleTable;
//表格数据
@property (nonatomic, strong) NSMutableArray *recordsList;
@property (nonatomic, strong) NSMutableArray *bubbleArray;

@property (nonatomic, strong) ContactClient *requestClient;

@end

@implementation XTPubAccHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    [KDWeiboAppDelegate setExtendedLayout:self];
    
    self.title = self.pubAcc.personName;
    self.recordsList = [NSMutableArray array];
    self.ispublic = YES;
    self.isFirstLoad = YES;
    
    self.mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainView];
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];

    self.bubbleTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64, ScreenFullWidth, ScreenFullHeight-74) style:UITableViewStylePlain];
    self.bubbleTable.backgroundColor = [UIColor kdBackgroundColor1];
    self.bubbleTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bubbleTable.delegate = self;
    self.bubbleTable.dataSource = self;
    [self.bubbleTable addHeaderWithCallback:^{
        [self recordTimeline];
    }];
    [self.mainView addSubview:self.bubbleTable];
    
    [self recordTimeline];
    
    if ([[BOSSetting sharedSetting] openWaterMark])
    {
        CGRect frame = CGRectMake(0, 0, ScreenFullWidth, self.mainView.frame.size.height);
        [KDWaterMarkAddHelper coverOnView:self.mainView withFrame:frame];
    }
    else
    {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.mainView];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)recordTimeline
{
    if (_requestClient == nil) {
        _requestClient = [[ContactClient alloc] initWithTarget:self action:@selector(recordTimelineDidReceived:result:)];
    }
    
    //从1开始
    NSUInteger page = self.recordsList.count/PageSize + 1;
    [_requestClient publicRecordHistory:self.pubAcc.personId withPage:page];
}


-(void)recordTimelineDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.bubbleTable headerEndRefreshing];
    if (result.success && result.data && !client.hasError && [result isKindOfClass:[BOSResultDataModel class]]) {
        
        RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:result.data];
        int recordCount = (int)[records.list count];
        if(recordCount>0)
        {
            //从0开始
            NSUInteger pageIndex = self.recordsList.count/PageSize;
            
            NSRange range;
            range.location = 0;
            range.length = self.recordsList.count - pageIndex*10;
            [self.recordsList removeObjectsInRange:range];
            
            id list = [result.data objectForKey:@"list"];
            for(NSUInteger i = 0;i<recordCount;i++)
            {
                NSDictionary *obj = list[i];
                RecordDataModel *record = [[RecordDataModel alloc] initWithDictionary:obj];
                [self.recordsList insertObject:record atIndex:0];
            }
        }
        
        [self updateData];
        [self.bubbleTable reloadData];
        
        if(self.isFirstLoad)
            [self.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.bubbleArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        self.isFirstLoad = NO;
    }
    else
    {
      
    }
    
}

- (void)updateData
{
    // Cleaning up old data
    self.bubbleArray = nil;
    
    // Loading new data
    int count = (int)[_recordsList count];
    if (count > 0)
    {
        self.bubbleArray = [[NSMutableArray alloc] init];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSDateFormatter *dateFormatter2Date = [[NSDateFormatter alloc]init];
        [dateFormatter2Date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *dateLast;// For 代办, 是否该显示日期, 汇总的逻辑flag
        for (int i = 0; i < count; i++)
        {
            __strong BubbleDataInternal *dataInternal = [[BubbleDataInternal alloc] init];
            dataInternal.group = self.group;
            dataInternal.record = [_recordsList objectAtIndex:i];
            
            BOOL personNameLabelHidden = NO;
            float personNameLabelHeight = 15.0;
            if ([[BOSConfig sharedConfig].user.userId isEqualToString:dataInternal.record.fromUserId])
            {
                personNameLabelHidden = YES;
                personNameLabelHeight = 0.0;
            } else {
                if (self.chatMode == ChatPrivateMode) {
                    if (self.group.groupType != GroupTypeMany) {
                        personNameLabelHidden = YES;
                        personNameLabelHeight = 0.0;
                    }
                } else {
                    if (dataInternal.record.msgDirection == MessageDirectionLeft && self.group.groupType != GroupTypePublicMany) {
                        personNameLabelHidden = YES;
                        personNameLabelHeight = 0.0;
                    }
                }
            }
            dataInternal.personNameLabelHidden = personNameLabelHidden;
            
            // Calculating cell height
            switch (dataInternal.record.msgType) {
                case MessageTypeSpeech:
                {
                    //语音
                    float width = 100.0 * (dataInternal.record.msgLen / 60.0) + 59.0;
                    dataInternal.bubbleLabelSize = CGSizeMake(width, 31.0);
                    dataInternal.contentLabelFrame = CGRectMake(dataInternal.record.msgDirection == MessageDirectionLeft ? 12.0 : 6.0, 8.0, dataInternal.bubbleLabelSize.width - 18.0, dataInternal.bubbleLabelSize.height - 16.0);
                    dataInternal.cellHeight = 61.0 + personNameLabelHeight + 5.0;
                }
                    break;
                case MessageTypeSystem:
                case MessageTypeCancel:
                {
                    //其他:系统、电话等
                    NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
                    NSMutableAttributedString *contentString = [NSMutableAttributedString attributedStringWithString:content];
                    [contentString setFont:[UIFont systemFontOfSize:12.0]];
                    [contentString setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping];
                    CGSize contentSize = [contentString sizeConstrainedToSize:CGSizeMake(300, 9999)];
                    
                    if (contentSize.height < 20){
                        contentSize.height = 20.0;
                    }
                    contentSize.width += 10.0;
                    dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width, contentSize.height);
                    dataInternal.contentLabelFrame = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
                    dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 10 + 5.0;
                }
                    break;
                case MessageTypePicture:
                {
                    //图片
                    dataInternal.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 90.0 + 20.0);
                    dataInternal.contentLabelFrame = CGRectZero;
                    dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 20.0;
                    if (dataInternal.record.param) {
                        dataInternal.cellHeight += 20.0;
                    }
                }
                    break;
                case MessageTypeFile:
                {
                    //文件
                    MessageFileDataModel *file = (MessageFileDataModel *)dataInternal.record.param.paramObject;
                    
                    if ([XTFileUtils isPhotoExt:file.ext]) {
                        dataInternal.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 90.0 + 20.0);
                        dataInternal.contentLabelFrame = CGRectZero;
                        dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 20.0;
                        if (dataInternal.record.param) {
                            dataInternal.cellHeight += 20.0;
                        }
                    }
                    else {
                        float bubbleHeight = 59.0;
                        
                        CGSize contentSize = [(dataInternal.record.content ? file.name : @"") sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(142, 9999) lineBreakMode:NSLineBreakByWordWrapping];
                        if (contentSize.height < 21.0) {
                            contentSize.height = 21.0;
                        }
                        
                        if (contentSize.width < 42.0) {
                            contentSize.width = 42.0;
                        }
                        dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                        dataInternal.cellHeight = (dataInternal.bubbleLabelSize.height > bubbleHeight ? dataInternal.bubbleLabelSize.height + 10.0 : bubbleHeight + 10.0) + personNameLabelHeight + 15.0;
                        if (file.appName.length > 0) {
                            dataInternal.cellHeight += 20.0;
                        }
                    }
                    
                }
                    break;
                case MessageTypeAttach:
                {
                    //带操作的消息
                    NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
                    
                    //                    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
                    //                    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                    //                    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                    //                                                                                forKey:NSFontAttributeName];
                    //                    [contentString addAttributes:attrsDictionary range:NSMakeRange(0, contentString.length)];
                    CGSize contentSize = [content sizeForMaxWidth:ScreenFullWidth-48 font:FS3];
                    
                    float bubbleLabelSizeHeight = contentSize.height;
                    CGFloat actionHeight = 0;
                    MessageAttachDataModel *paramObject = dataInternal.record.param.paramObject;
                    if ([paramObject.attach count] == 1)
                    {
                        actionHeight = 35;
                    } else if ([paramObject.attach count] == 2)
                    {
                        actionHeight = 35 + 35;
                    }
                    bubbleLabelSizeHeight += (25 + actionHeight);
                    float bubbleLabelSizeWidth = ScreenFullWidth-48;
                    dataInternal.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
                    dataInternal.contentLabelFrame = CGRectMake(8.0, 8.0, ScreenFullWidth-48, contentSize.height);
                    dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 10.0 + 5.0;
                }
                    break;
                case MessageTypeNews:
                {
                    //新闻
                    MessageNewsDataModel *paramObject = dataInternal.record.param.paramObject;
                    MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
                    
                    CGSize contentSize = [(news.text ? news.text : @"") sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(174, 70) lineBreakMode:NSLineBreakByWordWrapping];
                    if (contentSize.height < 13.0)
                    {
                        contentSize.height = 13.0;
                    }
                    
                    dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                    dataInternal.contentLabelFrame = CGRectZero;
                    if (paramObject.model == 1 && !paramObject.todoNotify && paramObject.newslist.count > 0)
                    {
                        MessageNewsEachDataModel *news=[paramObject.newslist   objectAtIndex:0];
                        
                        float fTitleHeight = 15;// [news.title sizeForMaxWidth:ScreenFullWidth-24 font:FS2].height;
                        //                        dataInternal.cellHeight = 68 + dataInternal.bubbleLabelSize.height + 10;
                        
                        float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-48 font:FS6 numberOfLines:4].height;
                        
                        if (news.date.length > 0)
                        {
                            float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                            
                            dataInternal.cellHeight = 15 + fTitleHeight + 12 + fDateHeight + 12 + fContentHeight + 15 + 10;
                        }
                        else
                        {
                            dataInternal.cellHeight = 15 + fTitleHeight + 12 + fContentHeight + 15 + 10;
                            
                        }
                        
                        
                    }
                    else if ((paramObject.model == 2 && paramObject.newslist.count > 0))
                    {
                        MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                        
                        float fTitleHeight = 15;// [news.title sizeForMaxWidth:ScreenFullWidth-24 font:FS2].height;
                        
                        float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-24-12*2 font:FS6].height;
                        
                        if (news.date.length > 0)
                        {
                            float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                            
                            dataInternal.cellHeight = 15 + fTitleHeight + 12 + fDateHeight + 12 + kNewsBigPictureHeight + 12 +  fContentHeight + 15+10;
                        }
                        else
                        {
                            dataInternal.cellHeight = 15 + fTitleHeight + 12 + kNewsBigPictureHeight + 12 +  fContentHeight + 15 +10;
                        }
                    }
                    else if (paramObject.model == 3 && paramObject.newslist.count > 0)
                    {
                        dataInternal.cellHeight = kNewsBigPictureHeight + 60 * paramObject.newslist.count-60 + 15+15+10;
                    }
                    else if (paramObject.model == 4)
                    {
                        if ([[paramObject.newslist objectAtIndex:0] hasHeaderPicture])
                        {
                            dataInternal.cellHeight = 207 + dataInternal.bubbleLabelSize.height + 10;
                        }
                        else
                        {
                            MessageNewsEachDataModel *news=[paramObject.newslist objectAtIndex:0];
                            
                            float fTitleHeight = 15;// [news.title sizeForMaxWidth:ScreenFullWidth-24 font:FS2].height;
                            //                        dataInternal.cellHeight = 68 + dataInternal.bubbleLabelSize.height + 10;
                            
                            float fContentHeight = [news.text sizeForMaxWidth:ScreenFullWidth-48 font:FS6].height;
                            
                            if (news.date.length > 0)
                            {
                                float fDateHeight = 15;//[news.date sizeForMaxWidth:ScreenFullWidth-24 font:FS6].height;
                                
                                dataInternal.cellHeight = 15 + fTitleHeight + 12+ fDateHeight + 12 + fContentHeight + 15 +10;
                            }
                            else
                            {
                                dataInternal.cellHeight = 15 + fTitleHeight + 12 + fContentHeight+ 15 +10;
                                
                            }
                        }
                        if ([[[paramObject.newslist objectAtIndex:0] buttons] count] > 0)
                        {
                            dataInternal.cellHeight += 23.f;
                        }
                    }
                    else if (paramObject.model == 1 && paramObject.todoNotify)
                    {
                        if (paramObject.newslist.count > 0)
                        {
                            MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
                            if (news.date)
                            {
                                dataInternal.cellHeight = 70 + dataInternal.bubbleLabelSize.height + 10;
                            }
                            else
                            {
                                dataInternal.cellHeight = 50 + dataInternal.bubbleLabelSize.height + 10;
                            }
                        }
                    }
                    
                }
                    break;
                case MessageTypeShareNews:
                {
                    /**
                     *  增加一种新的Cell样式，用于多图文分享
                     *  alanwong
                     */
                    MessageShareNewsDataModel *paramObject = dataInternal.record.param.paramObject;
                    if (paramObject.title.length == 0 || [paramObject.title isEqualToString:paramObject.content]) {
                        //多图文新闻
                        CGSize contentSize = CGSizeMake(194.0, 58.0);
                        dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                        dataInternal.contentLabelFrame = CGRectMake(72.0, 42.0, 134.0, 23.0);
                        dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 10.0 + 20.0;
                    }
                    else{
                        //单图文新闻
                        CGSize contentSize = CGSizeMake(174.0, 92.0);
                        dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
                        dataInternal.contentLabelFrame = CGRectMake(72.0, 42.0, 114.0, 55.0);
                        dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 10.0 + 20.0;
                        
                    }
                }
                    break;
                case MessageTypeLocation:
                {
                    //图片
                    dataInternal.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 90.0 + 20.0);
                    dataInternal.contentLabelFrame = CGRectZero;
                    dataInternal.cellHeight = dataInternal.bubbleLabelSize.height + 20.0;
                    if (dataInternal.record.param) {
                        dataInternal.cellHeight += 20.0;
                    }
                }
                    break;
                default:
                {
                    BOOL hasEffectiveDuration = false;
                    BOOL hasAppShareLabel = false;
                    if (dataInternal.record.msgType == MessageTypeText)
                    {
                        MessageShareTextOrImageDataModel *paramObject = dataInternal.record.param.paramObject;
                        if (paramObject.effectiveDuration > 0)
                        {
                            hasEffectiveDuration = true;
                            
                            //失效的密码不显示
                            NSTimeInterval interval = [paramObject.clientTime timeIntervalSinceNow];
                            interval = 0 - interval;
                            if (interval > paramObject.effectiveDuration) {
                                continue;
                            }
                        }
                        if (paramObject.appName.length > 0)
                        {
                            hasAppShareLabel = true;
                        }
                    }
                    
                    //文本
                    //                        NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
                    //                        NSMutableAttributedString *contentString = [NSMutableAttributedString attributedStringWithString:content];
                    //                        UIFont *font = hasEffectiveDuration ? [UIFont systemFontOfSize:20.0] : [UIFont systemFontOfSize:17.0];
                    //                        [contentString setFont:font];
                    //                        [contentString setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
                    //                        if (hasEffectiveDuration)
                    //                        {
                    //                            long number = 2;
                    //                            CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
                    //                            [contentString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[contentString length])];
                    //                            CFRelease(num);
                    //                        }
                    //                        else {
                    //                            //调整行间距
                    //                            OHParagraphStyle *paragraphStyle = [[OHParagraphStyle alloc] init];
                    //                            [paragraphStyle setLineSpacing:5];
                    //                            [contentString setParagraphStyle:paragraphStyle];
                    //                        }
                    //                        CGSize contentSize = [contentString sizeConstrainedToSize:CGSizeMake(204, 9999)];
                    
                    NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
                    UIFont *font = hasEffectiveDuration ? [UIFont systemFontOfSize:20.0] : [UIFont systemFontOfSize:17.0];
                    KDExpressionLabelType type = KDExpressionLabelType_Expression | KDExpressionLabelType_URL | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_TOPIC;
                    
                    //                    CGSize contentSize = [KDExpressionLabel sizeWithString:content constrainedToSize:CGSizeMake(204, CGFLOAT_MAX) withType:type textAlignment:NSTextAlignmentLeft textColor:nil textFont:font];
                    CGSize contentSize = [KDExpressionLabel sizeWithString:content constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 104 - 28 - 6, CGFLOAT_MAX) withType:type textAlignment:NSTextAlignmentLeft textColor:nil textFont:font];//原来是CGSizeMake(204, CGFLOAT_MAX)，
                    
                    if (hasEffectiveDuration) {
                        contentSize.width += content.length * 3.0;
                    }
                    
                    float bubbleLabelSizeWidth = contentSize.width + 28.0;
                    if (bubbleLabelSizeWidth < 60.0) {
                        bubbleLabelSizeWidth = 60.0;
                    }
                    
                    float bubbleLabelMiniSizeHeight = hasEffectiveDuration ? 51.0 : 31.0;
                    float bubbleLabelSizeHeight = contentSize.height + 20.0;
                    if (bubbleLabelSizeHeight < bubbleLabelMiniSizeHeight) {
                        bubbleLabelSizeHeight = bubbleLabelMiniSizeHeight;
                    }
                    
                    dataInternal.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
                    
                    float x = dataInternal.record.msgDirection == MessageDirectionLeft ? 12.0 : 6.0;
                    if (bubbleLabelSizeWidth - contentSize.width - 18.0 > 0) {
                        x += (bubbleLabelSizeWidth - contentSize.width - 18.0)/2;
                    }
                    float y = (bubbleLabelSizeHeight - contentSize.height)/2;
                    dataInternal.contentLabelFrame = CGRectMake(x, y, contentSize.width, contentSize.height);
                    dataInternal.cellHeight = (dataInternal.bubbleLabelSize.height > 51.0 ? dataInternal.bubbleLabelSize.height + 10.0 : 61) + personNameLabelHeight + 5.0;
                    
                    if (hasAppShareLabel) {
                        dataInternal.cellHeight += 20.0;
                    }
                }
                    break;
            }
            
            dataInternal.header = nil;
            NSDate *time = [dateFormatter2Date dateFromString:dataInternal.record.sendTime];
            
            
            // 每一天的代办的汇总逻辑
            if(self.group.groupType == GroupTypeTodo)
            {
                
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:time];
                NSDate *dateCurrent_ = [cal dateFromComponents:components];
                
                components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dateLast];
                NSDate *dateLast_ = [cal dateFromComponents:components];
                
                if (![dateCurrent_ isEqualToDate:dateLast_] || !dateLast) // 日期有变化
                {
                    // 就要再次设置
                    dataInternal.header = [ContactUtils formatDateString:dataInternal.record.sendTime] ;
                    dataInternal.cellHeight += 35;
                }
                else
                {
                    dataInternal.header = nil;
                }
                dateLast = time;
            }
            else
            {
                // 原逻辑
                if ([time timeIntervalSinceDate:last] > 300)
                {
                    dataInternal.header = self.group.groupType == GroupTypeTodo ? [ContactUtils formatDateString:dataInternal.record.sendTime] : [ContactUtils xtDateFormatter:dataInternal.record.sendTime];
                    dataInternal.cellHeight += 35;
                    last = time;
                }
            }
            
            
            
            [self.bubbleArray addObject:dataInternal];
    
        }
        
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bubbleArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:indexPath.row];
    return dataInternal.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"tblBubbleCell";
    
    NSLog(@"%@",self.bubbleArray);
    
    BubbleDataInternal *dataInternal = [self.bubbleArray objectAtIndex:indexPath.row];
    
    BubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_%@_%d", cellId, dataInternal.record.msgId,dataInternal.record.msgDirection]];
    if (cell == nil)
    {
        cell = [[BubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_%@_%d", cellId, dataInternal.record.msgId,dataInternal.record.msgDirection]];
    }
    dataInternal.checkMode = -1;
    cell.dataInternal = dataInternal;
    cell.row_index = indexPath.row;
    //    cell.backgroundColor = BOSCOLORWITHRGBA(0xf2f4f8, 1.0);
    cell.chatViewController = self;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


@end
