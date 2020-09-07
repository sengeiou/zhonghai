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
    [self.bubbleTable addFooterWithCallback:^{
        [self recordTimeline];
    }];
    [self.mainView addSubview:self.bubbleTable];
    
    [self recordTimeline];
    
    if ([[BOSSetting sharedSetting] openWaterMark:WaterMarkTypPublicAndLightApp])
    {
        CGRect frame = CGRectMake(0, 0, ScreenFullWidth, self.mainView.frame.size.height);
        [KDWaterMarkAddHelper coverOnView:self.mainView withFrame:frame];
    }
    else
    {
        [KDWaterMarkAddHelper removeWaterMarkFromView:self.mainView];
    }

    [self.view addSubview:self.tipsLabel];
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
    
    BubbleDataInternal *bubbleDataInternal = [self.bubbleArray lastObject];
    [_requestClient publicRecordHistory:self.pubAcc.personId andLastDate:bubbleDataInternal.record.sendTime];
}


-(void)recordTimelineDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result
{
    [self.bubbleTable footerEndRefreshing];
    if (result.success && result.data && !client.hasError && [result isKindOfClass:[BOSResultDataModel class]]) {
        
        RecordListDataModel *records = [[RecordListDataModel alloc] initWithDictionary:result.data];
        int recordCount = (int)[records.list count];
        if(recordCount>0)
        {
            id list = [result.data objectForKey:@"list"];
            for(NSUInteger i = 0;i<recordCount;i++)
            {
                NSDictionary *obj = list[i];
                RecordDataModel *record = [[RecordDataModel alloc] initWithDictionary:obj];
                if(![self.recordsList containsObject:record])
                    [self.recordsList addObject:record];
            }
        }
        
        [self updateData];
        [self.bubbleTable reloadData];
        
        self.tipsLabel.hidden = (self.bubbleArray.count != 0);
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
        
        NSDateFormatter *dateFormatter2Date = [[NSDateFormatter alloc]init];
        [dateFormatter2Date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (int i = 0; i < count; i++)
        {
            BubbleDataInternal *dataInternal = [[BubbleDataInternal alloc] initWithRecord:[_recordsList objectAtIndex:i] andGroup:self.group andChatMode:ChatPrivateMode];
            if(dataInternal == nil)
                continue;
            
            dataInternal.header = [ContactUtils xtDateFormatter:dataInternal.record.sendTime];
            dataInternal.cellHeight += 35;
            
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
    cell.hideMenu = YES;
    return cell;
}


-(UILabel *)tipsLabel
{
    if(_tipsLabel == nil)
    {
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,ScreenFullWidth,30)];
        _tipsLabel.center = CGPointMake(ScreenFullWidth/2, self.view.frame.size.height/2);
        _tipsLabel.text = ASLocalizedString(@"XTPubAccHistoryViewController_NoHistory");
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = FC3;
        _tipsLabel.font = FS4;
        _tipsLabel.numberOfLines = 1;
    }
    return _tipsLabel;
}

@end
