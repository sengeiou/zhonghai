//
//  KWIWelcomeVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 6/13/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIWelcomeVCtrl.h"

#import <CoreLocation/CoreLocation.h>

#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "TBXML.h"

#import "KWIWelcomeTrendV.h"
#import "KWIWelcomeElectionV.h"
#import "KDCommonHeader.h"

@interface KWIWelcomeVCtrl () <CLLocationManagerDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *ctnV;
@property (nonatomic, retain)CLLocation *bestEffortAtLocation;

@end

@implementation KWIWelcomeVCtrl
{
    IBOutlet UILabel *_dateV;
    IBOutlet UILabel *_dayOfWeekV;
    IBOutlet UILabel *_lunarDateV;
    IBOutlet UILabel *_dayOfMonthV;
    IBOutlet UILabel *_regionV;
    IBOutlet UILabel *_weatherV;
    IBOutlet UILabel *_temperatureV;
    IBOutlet UIButton *_hotTrendBtn;
    IBOutlet UIButton *_newTrendBtn;
    IBOutlet UIScrollView *_trendV;
    IBOutlet UIScrollView *_electionV;  
    IBOutlet UIPageControl *_trendCtrlV;
    IBOutlet UIImageView *_weatherImg;
    IBOutlet UIPageControl *_electionPgCtrl;
    
    CLLocationManager *_locMgr;
    CLGeocoder *_geocoder;
    
    CGRect _frame;
}

@synthesize ctnV = _ctnV;
@synthesize bestEffortAtLocation = bestEffortAtLocation_;

+ (KWIWelcomeVCtrl *)vctrlInBounds:(CGRect)bounds
{
    return [[[self alloc] initWithFrame:bounds] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithNibName:self.class.description bundle:nil];
    if (self) {
        _frame = frame;
    }
    return self;
}

- (void)dealloc {
    [_ctnV release];
    [_dateV release];
    [_dayOfWeekV release];
    [_dayOfMonthV release];
    [_regionV release];
    [_weatherV release];
    [_temperatureV release];
    [_hotTrendBtn release];
    [_newTrendBtn release];
    [_trendV release];
    [_electionV release];
    [_lunarDateV release];
    [_locMgr release];
    [_geocoder release];
    [_trendCtrlV release];
    [_weatherImg release];
    [_electionPgCtrl release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect frame = self.view.frame;
    frame.origin.x = self.ctnV.frame.size.width - frame.size.width;
    frame.origin.y = ceil((_frame.size.height - self.ctnV.frame.size.height) / 2 - (self.ctnV.frame.origin.y));
    self.view.frame = frame;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
    
    fmt.dateFormat = @"YYYY-MM-dd";
    _dateV.text = [fmt stringFromDate:today];
    
    fmt.dateFormat = @"eeee";
    _dayOfWeekV.text = [fmt stringFromDate:today];
    
    fmt.dateFormat = @"d";
    _dayOfMonthV.text = [fmt stringFromDate:today];
    
    _lunarDateV.text = [self LunarForSolar:today];
    
    _trendCtrlV.userInteractionEnabled = NO;
    
   // [self _queryLocation];
    
    [self _loadHotTrends];
    
    [self _loadElections];
}

- (void)viewDidUnload
{
    [self setCtnV:nil];
    [_dateV release];
    _dateV = nil;
    [_dayOfWeekV release];
    _dayOfWeekV = nil;
    [_dayOfMonthV release];
    _dayOfMonthV = nil;
    [_regionV release];
    _regionV = nil;
    [_weatherV release];
    _weatherV = nil;
    [_temperatureV release];
    _temperatureV = nil;
    [_hotTrendBtn release];
    _hotTrendBtn = nil;
    [_newTrendBtn release];
    _newTrendBtn = nil;
    [_trendV release];
    _trendV = nil;
    [_electionV release];
    _electionV = nil;
    [_lunarDateV release];
    _lunarDateV = nil;
    [_locMgr release];
    _locMgr = nil;
    [_geocoder release];
    _geocoder = nil;
    [_trendCtrlV release];
    _trendCtrlV = nil;
    [_weatherImg release];
    _weatherImg = nil;
    [_electionPgCtrl release];
    _electionPgCtrl = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)_queryLocation
{
    if (CLLocationManager.locationServicesEnabled) {
        if (!_locMgr) {
            _locMgr = [[CLLocationManager alloc] init];
            _locMgr.delegate = self;
            _locMgr.desiredAccuracy = kCLLocationAccuracyKilometer ;
        }
        
        if (CLLocationManager.significantLocationChangeMonitoringAvailable) {
            [_locMgr startMonitoringSignificantLocationChanges];
        } else {
            [_locMgr startUpdatingLocation];
        }
        [self performSelector:@selector(locatingTimeOut) withObject:nil afterDelay:60];
    } else {
        [self _configRegion:nil];
    }
}

- (void)locatingTimeOut {
    [self _configRegion:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //[self _reverseGeocodingForLocation:(CLLocation *)newLocation];
    DLog(@"loactionmanager did Update.....");
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation_ == nil || bestEffortAtLocation_.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        self.bestEffortAtLocation = newLocation;
        DLog(@"bestEfforAtLocaiton = %@",bestEffortAtLocation_);
        if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locatingTimeOut) object:nil];          
            [self _queryWeatherForLocation:bestEffortAtLocation_];
            
            if (CLLocationManager.significantLocationChangeMonitoringAvailable) {
                [manager stopMonitoringSignificantLocationChanges];
            } else {
                [manager stopUpdatingLocation];
            }
            
        }

   }
}

- (id)jsonObj:(NSString *)string {
    if (string.length == 0) {
        return  nil;
    }
    id obj = nil;
    NSError *error = nil;
    @try {
        Class clazz = NSClassFromString(@"NSJSONSerialization");
        
        if(clazz != Nil){
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            obj = [NSJSONSerialization JSONObjectWithData:data  options:0 error:&error];
            
        }else {
            SBJSON *jsonParser = [[SBJSON alloc] init];
            obj = [jsonParser objectWithString:string error:&error];
            [jsonParser release];
        }
        
    } @catch (NSException *exception) {
        DLog(@"parse json did catch an exception:%@", exception);
    }
    
    if(error != nil){
        DLog(@"Can not build json object with error:%@", error);
        
    }
    return obj;
}

//- (void)_queryWeatherForPlace:(CLPlacemark *)placemark
- (void)_queryWeatherForLocation:(CLLocation *)loc
{
    [self _queryWOEIDForLocation:loc onSuccess:^(NSString *woeid) {
        NSURL *yWeather = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastjson?w=%@&u=c", woeid]]; //NSLog(@"yw | %@", yWeather);
        __block ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:yWeather];
        req.completionBlock = ^{
            NSDictionary *result = [self jsonObj:req.responseString];
                    
            unsigned int conditionCode = [[[result objectForKey:@"condition"] objectForKey:@"code"] intValue];
            _weatherV.text = [self _getWeatherConditionStrFromCode:conditionCode];
            
            _weatherImg.image = [self _getWeatherImgFromCode:conditionCode];
            
            // use google one
            /*NSArray *forecasts = [result objectForKey:@"forecast"]; 
            for (NSDictionary *el in forecasts) {
                if ([@"Today" isEqualToString:[el objectForKey:@"day"]]) {
                    NSUInteger highT = [[el objectForKey:@"high_temperature"] intValue];
                    NSUInteger lowT = [[el objectForKey:@"low_temperature"] intValue];
                    
                    _temperatureV.text = [NSString stringWithFormat:@"%d° ~ %d°", lowT, highT];
                    
                    break;
                }
            }*/
        };
        [req setFailedBlock:^{
//            NSLog(@"query weather failed: %@", req.error);
        }];
        [req startAsynchronous];
    }];
}

- (NSString *)_getWeatherConditionStrFromCode:(NSUInteger)code
{
    NSString *condition = nil;
    switch (code) {
        case 0:
        case 1:
        case 2:
            condition = @"风暴";
            break;
            
        case 3:
        case 4:
            condition = @"雷暴";
            break;
            
        case 5:
            condition = @"雨夹雪";
            break;
            
        case 6:
        case 7:
            condition = @"雨夹雹";
            break;
            
        case 8:
        case 10:
        case 18:
            condition = @"冻雨";
            break;
            
        case 9:
            condition = @"小雨";
            break;
            
        case 11:
        case 12:
        case 13:
        case 14:
        case 40:
            condition = @"阵雨";
            break;
            
        case 15:
        case 16:
            condition = @"雪";
            break;
            
        case 17:
            condition = @"冰雹";
            break;
            
        case 19:
            condition = @"沙尘暴";
            break;
            
        case 20:
            condition = @"雾";
            break;
            
        case 21:
        case 22:
            condition = @"雾霾";
            break;
            
        case 23:
            condition = @"大风";
            break;
            
        case 24:
            condition = @"风";
            break;
            
        case 25:
            condition = @"冰冻";
            break;
            
        case 26:
            condition = @"阴";
            break;
            
        case 27:
        case 28:
            condition = @"多云";
            break;
            
        case 29:
        case 30:
            condition = @"晴间多云";
            break;
            
        case 31:
        case 32:
        case 33:
        case 34:
            condition = @"晴";
            break;
            
        case 35:
            condition = @"雨夹雹";
            break;
            
        case 36:
            condition = @"高温";
            break;
            
        case 37:
        case 38:
        case 39:
            condition = @"雷暴";
            break;
            
        case 41:
        case 43:
            condition = @"大雪";
            break;
            
        case 42:
        case 46:
            condition = @"阵雪";
            break;
            
        case 44:
            condition = @"晴间多云";
            break;
            
        case 45:
        case 47:
            condition = @"雷阵雨";
            break;
            
        default:
            condition = @"不明天气";
            break;
    }
    
    return condition;
}

- (UIImage *)_getWeatherImgFromCode:(NSUInteger)code
{
    NSString *imgcode;
    switch (code) {
        case 0:
        case 1:
        case 2:
            imgcode = @"019";
            break;
            
        case 3:
        case 4:
            imgcode = @"024";
            break;
            
        case 5:
            imgcode = @"018";
            break;
            
        case 6:
        case 7:
        case 17:
        case 35:
            imgcode = @"004";
            break;
            
        case 8:
        case 10:
        case 18:
            imgcode = @"007";
            break;
            
        case 9:
            imgcode = @"017";
            break;
            
        case 11:
        case 12:
        case 13:
        case 14:
        case 40:
            imgcode = @"015";
            break;
            
        case 15:
        case 16:
            imgcode = @"020";
            break;
            
        case 19:
        case 21:
        case 22:
            imgcode = @"006";
            break;
            
        case 20:
            imgcode = @"008";
            break;        
            
        case 23:
        case 24:
            imgcode = @"025";
            break;            
            
        case 25:
            imgcode = @"007";
            break;
            
        case 26:
            imgcode = @"026";
            break;
            
        case 27:
            imgcode = @"003";
            break;
            
        case 28:
            imgcode = @"002";
            break;
            
        case 29:
            imgcode = @"009";
            break;
            
        case 30:
            imgcode = @"010";
            break;
            
        case 31:
        case 32:
        case 34:
            imgcode = @"021";
            break;
            
        case 33:        
            imgcode = @"001";
            break;            
            
        case 36:
            imgcode = @"021";
            break;
            
        case 37:
        case 38:
        case 39:
            imgcode = @"024";
            break;
            
        case 41:
        case 42:
        case 43:
        case 46:
            imgcode = @"020";
            break;
            
        case 44:
            imgcode = @"010";
            break;
            
        case 45:
        case 47:
            imgcode = @"022";
            break;
            
        default:
            imgcode = @"011";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"Yahoo_Weather_%@.png", imgcode]];
}

//- (void)_queryWOEIDForPlace:(CLPlacemark *)placemark onSuccess:(void(^)(NSString *))onSuccess
- (void)_queryWOEIDForLocation:(CLLocation *)loc onSuccess:(void(^)(NSString *))onSuccess
{
    NSURL *yPlaceFinder = [NSURL URLWithString:[NSString stringWithFormat:@"http://where.yahooapis.com/geocode?q=%f,%f&flags=J&gflags=LRQ&locale=zh_CN&appid=dbXofr6e", loc.coordinate.latitude, loc.coordinate.longitude]];
    
    __block ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:yPlaceFinder];
    req.completionBlock = ^{
        NSDictionary *resp = [self jsonObj:req.responseString];
        NSString *woeid = nil;
        
        if ([resp objectForKey:@"ResultSet"]) {
            if ([[resp objectForKey:@"ResultSet"] objectForKey:@"Results"]) {
                NSArray *ar = [[resp objectForKey:@"ResultSet"] objectForKey:@"Results"];
                if (0 < ar.count) { 
                    NSDictionary *locInf = [[[resp objectForKey:@"ResultSet"] objectForKey:@"Results"] objectAtIndex:0];
                    [self _configRegion:locInf];
                    woeid = [locInf objectForKey:@"woeid"];
                    
                    // use google weather API for only temperature
                    [self _queryGWeatherForCity:[locInf objectForKey:@"city"]];
                }
            }
        } 
        
        if (woeid && onSuccess) {
            onSuccess(woeid);
        }
    };
    [req setFailedBlock:^{
//        NSLog(@"geocoding failed: %@", req.error);
    }];
    [req startAsynchronous];
}

- (void)_queryGWeatherForCity:(NSString *)city
{
    NSURL *gWeather = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@", [city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __block ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:gWeather];
    __block BOOL isDone = NO;
    req.completionBlock = ^{
        //NSDictionary *resp = [req.responseString JSONValue];
        //NSLog(@"> w < | %@", req.responseString);
        
        NSError *error;
        TBXML * tbxml = [[TBXML newTBXMLWithXMLString:req.responseString error:&error] autorelease];
        
        if (error) {
//            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        } else {
            [TBXML iterateElementsForQuery:@"weather" fromElement:tbxml.rootXMLElement withBlock:^(TBXMLElement *element) {
                [TBXML iterateElementsForQuery:@"forecast_conditions" fromElement:element withBlock:^(TBXMLElement *element) {
                    if (isDone) {
                        return;
                    }                     
                    
                    TBXMLElement *elTempLow = [TBXML childElementNamed:@"low" parentElement:element];
                    NSString *tempLowF = [TBXML valueOfAttributeNamed:@"data" forElement:elTempLow];
                    NSInteger tempLowC = ceil((tempLowF.intValue - 32.0) * 5 / 9);
                    
                    TBXMLElement *elTempHigh = [TBXML childElementNamed:@"high" parentElement:element];
                    NSString *tempHighF = [TBXML valueOfAttributeNamed:@"data" forElement:elTempHigh];
                    NSInteger tempHighC = ceil((tempHighF.intValue - 32.0) * 5 / 9);
                    
                    _temperatureV.text = [NSString stringWithFormat:@"%d° ~ %d°", tempLowC, tempHighC];
                    
                    isDone = YES;
                }];
            }];
        }
    };
    [req setFailedBlock:^{
//        NSLog(@"gweather failed: %@", req.error);
    }];
    [req startAsynchronous];
}

//- (void)_configRegion:(CLPlacemark *)placemark
- (void)_configRegion:(NSDictionary *)locInf
{ // NSLog(@"%@", locInf);
    if (locInf) {
        _regionV.text = [locInf objectForKey:@"city"];
    } else {
        _regionV.font = [UIFont systemFontOfSize:10];
        _regionV.text = @"未能取得地理位置";
    }    
}


#pragma mark - 
- (IBAction)_onHotTrendsBtnTapped:(id)sender 
{
    for (UIView *v in _trendV.subviews) {
        [v removeFromSuperview];
    }

    _hotTrendBtn.selected = YES;
    _newTrendBtn.selected = NO;
    [self _loadHotTrends];
}

- (IBAction)_onRecentTrendBtnTapped:(id)sender 
{
    for (UIView *v in _trendV.subviews) {
        [v removeFromSuperview];
    }

    _hotTrendBtn.selected = NO;
    _newTrendBtn.selected = YES;
    [self _loadRecentTrends];
}

- (void)_loadHotTrends
{

    KDQuery *query = [KDQuery query];
    [query setParameter:@"hottest_limit" integerValue:16];
    [query setParameter:@"new_limit" integerValue:0];
    __block KWIWelcomeVCtrl *tvc = [self retain];
  
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            [tvc _populateTrendScrollV:results];
        }else {
            
        }
        // release current view controller
        [tvc release];
       
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:weekly" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_loadRecentTrends {
    __block KWIWelcomeVCtrl *tvc = [self retain];

    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            //[tvc _populateTrendScrollV:results];
            if(results) {
               [tvc _populateTrendScrollV:results];
            }else {
                UILabel *emptyLabel = [[[UILabel alloc] initWithFrame:_trendV.bounds] autorelease];
                emptyLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
                emptyLabel.textColor = [UIColor colorWithHexString:@"666"];
                emptyLabel.textAlignment = UITextAlignmentCenter;
                emptyLabel.backgroundColor = [UIColor clearColor];
                emptyLabel.text = @"暂无最新话题";
                [_trendV addSubview:emptyLabel];
                _trendCtrlV.numberOfPages = 0;
            }
            

        }else {
            
        }
        // release current view controller
        [tvc release];
       
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/trends/:fresh" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)_populateTrendScrollV:(NSArray *)topics
{

    _trendV.contentSize = _trendV.frame.size;
    _trendV.contentOffset = CGPointZero;
    _trendCtrlV.currentPage = 0;
    
    unsigned int i = 0;
    for (KDTopic *topic in topics) {
        KWIWelcomeTrendV *trendV = [KWIWelcomeTrendV viewForTrend:topic];
        
        unsigned int pgNum = i/4;
        unsigned int rowNum = i%4;
        
        CGRect frame = trendV.frame;
        frame.origin.x = _trendV.frame.size.width * pgNum;
        frame.origin.y = 28 * rowNum;
        
        trendV.frame = frame;
        
        [_trendV addSubview:trendV];
        
        i++;
    }
    
    unsigned int pgCount = ceil(topics.count / 4.0);
    
    CGSize size = _trendV.frame.size;
    size.width *= pgCount;
    _trendV.contentSize = size;
    
    _trendCtrlV.numberOfPages = pgCount;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    unsigned int pgNum = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if (_trendV == scrollView) {
        _trendCtrlV.currentPage = pgNum;
    } else if (_electionV == scrollView) {
        _electionPgCtrl.currentPage = pgNum;
    }
}

- (void)_loadElections
{

        __block KWIWelcomeVCtrl *tvc = [self retain];
   
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results) {
                NSArray *votes = results;
                    unsigned int i = 0;
                           CGRect frm = _electionV.bounds;
                           for (KDVote *vote in votes) {
                               KWIWelcomeElectionV *view = [KWIWelcomeElectionV viewForElection:vote];
                
                               frm.origin.x = frm.size.width * i;
                               view.frame = frm;
                               [_electionV addSubview:view];
                
                               i++;
                           }
                
                           CGSize size = _electionV.bounds.size;
                           size.width *= votes.count;
                          _electionV.contentSize = size;
                          
                         _electionPgCtrl.numberOfPages = votes.count;
            }
        }
        else {
            
        }
        // release current view controller
        [tvc release];
       
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/vote/:voteLatest" query:nil
                                 configBlock:nil completionBlock:completionBlock];
}


#pragma mark -
// http://blog.csdn.net/studyrecord/article/details/6651794
// 农历转换函数
-(NSString *)LunarForSolar:(NSDate *)solarDate{
    //天干名称
    //NSArray *cTianGan = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];
    
    //地支名称
    //NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    //属相名称
    //NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                         @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                         @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static int wCurYear,wCurMonth,wCurDay;
    static int nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:solarDate];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    //NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    //NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];
    
    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]]; 
    }
    else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth]; 
    }
    
    // NSString *lunarDate = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    NSString *lunarDate = [NSString stringWithFormat:@"农历%@月%@",szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}

@end
