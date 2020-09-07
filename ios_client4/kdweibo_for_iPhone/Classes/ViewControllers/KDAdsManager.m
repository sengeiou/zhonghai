//
//  KDAdsManager.m
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDAdsManager.h"
#import "BOSFileManager.h"
#import "AdvertisementView.h"
#import "BOSConfig.h"
@interface KDAdsManager()
//启动页
@property (nonatomic, strong) KDAdsClient *queryLaunchAdsClient;
@property (nonatomic, copy) KDqueryAdsBlock queryLaunchAdsBlock;
//应用页签
@property (strong , nonatomic) KDAdsClient *queryApplicationAdsClient;
@property (nonatomic, copy) KDqueryAdsBlock queryApplicationAdsBlock;

@end

@implementation KDAdsManager


#pragma mark - public -
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static KDAdsManager *adsManger;
    dispatch_once(&onceToken, ^{
        adsManger = [KDAdsManager new];
    });
    return adsManger;
}

- (void)queryAdsWithBlock:(KDqueryAdsBlock)block adsType:(KDAdsLocationType)adsType {
    switch (adsType) {
        case KDAdsLocationType_index:
            [self queryLaunchAdsWithBlock:block];
            break;
        case KDAdsLocationType_application:
            [self queryApplicationAdsWithBlock:block];
            break;
        default:
            break;
    }
}

- (void)clearLocalAdsWithAdsType:(KDAdsLocationType)adsType {
    switch (adsType) {
        case KDAdsLocationType_index:
            [self clearLaunchAds];
            break;
        case KDAdsLocationType_application:
            break;
        default:
            break;
    }
}

#pragma mark - 文件操作 -
- (void)writeAds:(NSArray *)adsArray adsType:(KDAdsLocationType)adsType{
    NSString *filePath = [self lauchAdsFilePathWithAdsType:adsType];
    [NSKeyedArchiver archiveRootObject:adsArray toFile:filePath];
}

- (NSArray *)queryAdsFromFilePathWithAdsType:(KDAdsLocationType)adsType{
    NSString *filePath = [self lauchAdsFilePathWithAdsType:adsType];
    return [NSKeyedUnarchiver unarchiveObjectWithFile: filePath];
}

- (NSString *)lauchAdsFilePathWithAdsType:(KDAdsLocationType)adsType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *parentPath = [ documentsDirectory stringByAppendingPathComponent:@"yunzhijia"];
    NSString *lauchAdsPath =  @"";
    
    NSString *eid = [BOSConfig sharedConfig].user.eid;
    NSString *userId = [BOSConfig sharedConfig].user.userId;
    switch (adsType) {
        case KDAdsLocationType_index:
            lauchAdsPath = [parentPath stringByAppendingPathComponent:@"launchAds.txt"];
            break;
            
        case KDAdsLocationType_application:
            lauchAdsPath = [parentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"applicatitonAds_%@_%@.txt",eid,userId]];
            break;
            
        default:
            break;
    }
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    if (![defaultFileManager fileExistsAtPath:parentPath]) {
        [defaultFileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return  lauchAdsPath;
}



#pragma mark - 启动页广告
- (void)queryLaunchAdsWithBlock:(KDqueryAdsBlock)block{
    if(_queryLaunchAdsClient)
    {
        [_queryLaunchAdsClient cancelRequest];
        _queryLaunchAdsClient = nil;
        self.queryLaunchAdsBlock = nil;
    }
    self.queryLaunchAdsBlock = block;
    [self.queryLaunchAdsClient queryAdsWithLocationType:KDAdsLocationType_index];
}

- (KDAdsClient *)queryLaunchAdsClient
{
    if(!_queryLaunchAdsClient)
    {
        _queryLaunchAdsClient = [[KDAdsClient alloc] initWithTarget:self action:@selector(queryLaunchAdsDidReceived:result:)];
    }
    return _queryLaunchAdsClient;
}

- (void)queryLaunchAdsDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || result == nil || ![result isKindOfClass:[BOSResultDataModel class]]) {
        
    }
    else if (result.success) {
        [self writeAds:nil adsType:KDAdsLocationType_index];
        if ([result.data isKindOfClass:[NSArray class]]) {
            NSArray *arrayData = (NSArray *) result.data;
            if(arrayData && arrayData.count>0)
            {
                NSMutableArray *adsArray = [self adsArrayFromArray:arrayData];
                [self writeAds:adsArray adsType:KDAdsLocationType_index];
                
                if(self.queryLaunchAdsBlock)
                {
                    self.queryLaunchAdsBlock();
                }
            }
        }
    }
    _queryLaunchAdsClient = nil;
    self.queryLaunchAdsBlock = nil;
}

- (void)clearLaunchAds
{
    if(_queryLaunchAdsClient)
    {
        [_queryLaunchAdsClient cancelRequest];
        _queryLaunchAdsClient = nil;
        self.queryLaunchAdsBlock = nil;
    }
    [self writeAds:nil adsType:KDAdsLocationType_index];
}





- (KDAdDetailModel *)getCurrentShowAd
{
    KDAdDetailModel *model = nil;
    NSArray *adsArray = [self queryAdsFromFilePathWithAdsType:KDAdsLocationType_index];
    
    if(adsArray && adsArray.count>0)
    {
        NSSortDescriptor *createdateDesc = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO];
        NSArray *sortedArray = [adsArray sortedArrayUsingDescriptors:@[createdateDesc]];
        for (KDAdDetailModel *detailModel in sortedArray) {
            if(![self loadAdKey:detailModel.key]){
                model = detailModel;
                break;
            }
        }
    }
    return model;
}

- (void)showAdvertisementOnView:(UIView *)container  timeout:(NSTimeInterval)timeout  completetion:(dispatch_block_t)complete
{
    KDAdDetailModel *model = [self getCurrentShowAd];
    if(model){
        [self showAdvertisementOnView:container adModel:model timeout:timeout completetion:complete];
    }
}

- (void)showAdvertisementOnView:(UIView *)container adModel:(KDAdDetailModel *)model  timeout:(NSTimeInterval)timeout completetion:(dispatch_block_t)complete  {
    
    __block UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgImageView.backgroundColor = [UIColor whiteColor];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    [container addSubview:bgImageView];
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";
    NSString *launchImage = nil;
    NSArray*imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if(CGSizeEqualToSize(imageSize, viewSize)&&[viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]){
            launchImage = dict[@"UILaunchImageName"];
            break;
        }
    }
    bgImageView.image = [UIImage imageNamed:launchImage];
    
    AdvertisementView *adView = [[AdvertisementView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    adView.alpha = 0;
    adView.AdAnimationType = ADAnimationTypeZoom;
    adView.block = complete;
    [adView setAdsModel:model timeout:timeout];
    [container addSubview:adView];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionCurveLinear animations:^{
        adView.alpha = 1;
        
    } completion:^(BOOL finished) {
        [bgImageView removeFromSuperview];
        bgImageView = nil;
    }];
    if(model.closeType == 1){
        [self saveAdKey:model.key];
    }
}


- (void)saveAdKey:(NSString *)adKey {
    NSString *eid = [BOSConfig sharedConfig].user.eid;
    NSString *userId = [BOSConfig sharedConfig].user.userId;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@%@", adKey, eid ? eid : @"_", userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)loadAdKey:(NSString *)adKey {
    NSString *eid = [BOSConfig sharedConfig].user.eid;
    NSString *userId = [BOSConfig sharedConfig].user.userId;
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@%@", adKey, eid ? eid : @"_", userId]];
}

#pragma mark - 应用页签广告 - 
- (void)queryApplicationAdsWithBlock:(KDqueryAdsBlock)block{
    if(_queryApplicationAdsClient)
    {
        [_queryApplicationAdsClient cancelRequest];
        _queryApplicationAdsClient = nil;
        self.queryApplicationAdsBlock = nil;
    }
    self.queryApplicationAdsBlock = block;
    [self.queryApplicationAdsClient queryAdsWithLocationType:KDAdsLocationType_application];
}

- (KDAdsClient *)queryApplicationAdsClient
{
    if(!_queryApplicationAdsClient)
    {
        _queryApplicationAdsClient = [[KDAdsClient alloc] initWithTarget:self action:@selector(queryApplicationAdsDidReceived:result:)];
    }
    return _queryApplicationAdsClient;
}

- (void)clearApplicationAds
{
    if(_queryApplicationAdsClient)
    {
        [_queryApplicationAdsClient cancelRequest];
        _queryApplicationAdsClient = nil;
        self.queryApplicationAdsBlock = nil;
    }
    [self writeAds:nil adsType:KDAdsLocationType_application];
}


- (void)queryApplicationAdsDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError || result == nil || ![result isKindOfClass:[BOSResultDataModel class]]) {
        
    }
    else if (result.success) {
        [self writeAds:nil adsType:KDAdsLocationType_application];
        if ([result.data isKindOfClass:[NSArray class]]) {
            NSArray *arrayData = (NSArray *) result.data;
            if(arrayData && arrayData.count>0)
            {
                NSMutableArray *adsArray = [self adsArrayFromArray:arrayData];
                [self writeAds:adsArray adsType:KDAdsLocationType_application];
                
                if(self.queryApplicationAdsBlock)
                {
                    self.queryApplicationAdsBlock();
                }
            }
        }
    }
    _queryApplicationAdsClient = nil;
    self.queryApplicationAdsBlock = nil;
}



#pragma mark - common -
- (NSMutableArray *)adsArrayFromArray:(NSArray *)arrayData {
    NSMutableArray *adsArray = [NSMutableArray new];
    for (NSDictionary *dict in arrayData) {
        NSString *module = dict[@"module"];
        //启动页
        if([module isEqualToString:@"index"])
        {
            NSArray *arrayAds = dict[@"ads"];
            if(arrayAds && ![arrayAds isKindOfClass:[NSNull class]] && arrayAds.count>0)
            {
                for (NSDictionary *dictAd in arrayAds) {
                    KDAdDetailModel *detailModel = [[KDAdDetailModel alloc] initWithDictionary:dictAd];
                    [adsArray addObject:detailModel];
                    
                    //获取数据并且缓存图片
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:detailModel.pictureUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                            [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:detailModel.pictureUrl] imageScale:SDWebImageScalePreView] recalculateFromImage:NO imageData:data forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:detailModel.pictureUrl] imageScale:SDWebImageScalePreView] toDisk:YES];
                        }];
                    });
                }
            }
            break;
        }
        //应用页签
        if([module isEqualToString:@"application"])
        {
            NSArray *arrayAds = dict[@"ads"];
            if(arrayAds && ![arrayAds isKindOfClass:[NSNull class]] && arrayAds.count>0)
            {
                for (NSDictionary *dictAd in arrayAds) {
                    KDAdDetailModel *detailModel = [[KDAdDetailModel alloc] initWithDictionary:dictAd];
                    [adsArray addObject:detailModel];
                    
                    //获取数据并且缓存图片
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:detailModel.pictureUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                            
                            [[SDImageCache sharedImageCache] storeImage:image forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:detailModel.pictureUrl] imageScale:SDWebImageScalePreView] recalculateFromImage:NO imageData:data forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:detailModel.pictureUrl] imageScale:SDWebImageScalePreView] toDisk:YES];
                            
                        }];
                    });
                }
            }
            break;
        }
        
    }
    return adsArray;
}
@end
