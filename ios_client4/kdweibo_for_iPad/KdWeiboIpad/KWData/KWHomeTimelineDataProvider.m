//
//  KWHomeTimelineDataProvider.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KWHomeTimelineDataProvider.h"

#import "Logging.h"
#import "NSObject+SBJson.h"

#import "NSDate+KWDataExt.h"

#import "KWStatus.h"
#import "RawStatus.h"

static const NSString *_namespace = @"hometimeline";

@implementation KWHomeTimelineDataProvider

@synthesize delegate = _delegate;

+ (KWHomeTimelineDataProvider *)provider
{
    return [[[self alloc] init] autorelease];
}

+ (KWHomeTimelineDataProvider *)providerWithDelegate:(NSObject<KWHomeTimelineDataDelegate> *) delegate
{
    KWHomeTimelineDataProvider *provider = [self provider];
    provider.delegate = delegate;
    return provider;
}

- (NSString *)contextName
{
    return @"hometimeline";
}

- (NSString *)entityName
{
    return @"RawStatus";
}

- (void)reload:(void (^)(NSArray *))onSuccess
{
    [self.api fetchHomeTimeline:[KWPaging pagingWithPage:1] 
                      onSuccess:^(NSArray *result){
                          [self clearData];
                          
                          for (NSDictionary *data in result) {
                              RawStatus *rawStatus = [[[RawStatus alloc] initWithEntity:[self getEntityDescription] insertIntoManagedObjectContext:self.context] autorelease];
                              rawStatus.raw_json = [data JSONRepresentation];
                              rawStatus.id_ = [data objectForKey:@"id"];
                              rawStatus.created = [NSDate dateFromString:[data objectForKey:@"created_at"]];
                          }
                          
                          NSError *error = nil;
                          [self.context save:&error];
                          
                          if (error) {
                              LogError(@"err: %@", error);
                              abort();
                          }
                          
                          if (onSuccess) {
                              onSuccess([KWStatus statusesFromDict:result]);
                          }
                      }
                        onError:^(NSError *error) {
                            // TODO
                        }];
}

- (void)refresh
{
    KWPaging *p;    
    NSArray *existings = [self loadData];
    if (existings.count) {
        KWStatus *lastStatus = [existings objectAtIndex:0];
        p = [KWPaging pagingWithSinceId:lastStatus.id_];
    } else {
        p = [KWPaging pagingWithPage:1];
    }    
    
    [self.api fetchHomeTimeline:p 
                      onSuccess:^(NSArray *dictAr){
                          NSMutableDictionary *existingsDict = [NSMutableDictionary dictionary];    
                          for (KWStatus *status in existings) {
                              [existingsDict setValue:@"" forKey:status.id_];
                          }
                          
                          // NSMutableArray *rawStatuses = [NSMutableArray arrayWithCapacity:dictAr.count];
                          NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:dictAr.count];
                          for (NSDictionary *data in dictAr) {
                              if (nil == [existingsDict objectForKey:[data objectForKey:@"id"]]) {
                                  RawStatus *rawStatus = [[[RawStatus alloc] initWithEntity:[self getEntityDescription] insertIntoManagedObjectContext:self.context] autorelease];
                                  rawStatus.raw_json = [data JSONRepresentation];
                                  rawStatus.id_ = [data objectForKey:@"id"];
                                  rawStatus.created = [NSDate dateFromString:[data objectForKey:@"created_at"]];
                                  KWStatus *status = [KWStatus statusFromDict:data];
                                  [statuses addObject:status];
                              }
                          }
                          
                          NSError *error = nil;
                          // this call lead to crash in ios 4.3
                          //[self.context save:&error];
                          
                          if (error) {
                              LogError(@"err: %@", error);
                              abort();
                          }
                          
                          if (self.delegate && [self.delegate respondsToSelector:@selector(hometimelinePrepended:)]) {
                              [self.delegate hometimelinePrepended:[NSArray arrayWithArray:statuses]];
                          }
                      } 
                        onError:^(NSError *error) {
                            if (self.delegate && [self.delegate respondsToSelector:@selector(loadingFailedWithError:)]) {
                                [self.delegate loadingFailedWithError:error];
                            }
                        }];
}

- (void)loadmore
{
    KWPaging *p;    
    NSArray *existings = [self loadData];
    if (existings.count) {
        KWStatus *oldestStatus = [existings lastObject];
        p = [KWPaging pagingWithMaxId:oldestStatus.id_];
    } else {
        p = [KWPaging pagingWithPage:1];
    }    
    
    [self.api fetchHomeTimeline:p 
                      onSuccess:^(NSArray *dictAr){
                          // we dont persistence appended data        
                          if (self.delegate && [self.delegate respondsToSelector:@selector(hometimelineAppended:)]) {
                              [self.delegate hometimelineAppended:[KWStatus statusesFromDict:dictAr]];
                          }
                      } 
                        onError:^(NSError *error) {
                            // TODO
                        }];
}

- (NSArray *)loadData
{
    NSFetchRequest *request = [self getFetchRequestWithDescendingAttr:@"created"];
    //request.fetchBatchSize = INFINITY;
    
    NSError *error = nil;
    NSArray *records = [self.context executeFetchRequest:request error:&error];
    if (error) {
        LogError(@"err: %@", error);
        abort();
    }
    
    if (records.count) {
        NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:records.count];    
        for (RawStatus *data in records) {
            [statuses addObject:[KWStatus statusFromDict:[data.raw_json JSONValue]]];
        }
        return [NSArray arrayWithArray:statuses];
    } else {
        return [NSArray array];
    }
}

- (void)remove:(KWStatus *)status
{
    NSFetchRequest *request = [self getFetchRequest];
    
    NSError *error = nil;
    NSArray *records = [self.context executeFetchRequest:request error:&error];
    if (error) {
        LogError(@"err: %@", error);
        abort();
    }
    
    for (RawStatus *e in records) {
        if ([e.id_ isEqualToString:status.id_]) {
            [self.context deleteObject:e];
            break;
        }
    }
}

@end
