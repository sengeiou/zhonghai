//
//  KWIMentiontlVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/15/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMentionTLVCtrl.h"

#import "NSError+KWIExt.h"

#import "KWEngine.h"
#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"

@interface KWIMentionTLVCtrl () 

@property (retain, nonatomic) NSCache *cellCache;

@end

@implementation KWIMentionTLVCtrl

@synthesize cellCache = _cellCache;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.view addSubview:self.emptyV];
    self.data = [NSArray array];
    
    [self _refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]];
    
    return CGRectGetHeight(cell.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row]]; 
}

- (KWIStatusCell *)_loadCellForStatus:(KWStatus *)status
{
    KWIStatusCell *cell = [self.cellCache objectForKey:status.id_];
    if (nil == cell) {
        cell = [KWIStatusCell cell];
        cell.data = status;
        [self.cellCache setObject:cell forKey:status.id_];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row]];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [KWIStatusCell class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];  
}

#pragma mark -
- (void)_refresh
{
    if(self.isLoading) return;
    
    self.isLoading = YES;
    isLoadMore_ = NO;
    [[KDWeiboCore sharedKDWeiboCore] fetchMentionMeTimeLineIsLoad:NO delegate:self];
}

- (void)_loadmore
{    
    if(self.isLoading) return;
    
    self.isLoading = YES;
    isLoadMore_ = YES;
    [[KDWeiboCore sharedKDWeiboCore] fetchMentionMeTimeLineIsLoad:YES delegate:self];
}

#pragma mark -
- (NSCache *)cellCache
{
    if (!_cellCache) {
        _cellCache = [[NSCache alloc] init];
        _cellCache.name = self.class.description;
        _cellCache.countLimit = 20;
    }
    
    return _cellCache;
}

#pragma mark - empty view

- (NSString *)emptyImageName
{
    return @"emptyMention.png";
}

- (NSString *)emptyTextPartial
{
    return @"提及";
}

#pragma mark -

//override this method to do sth. special

- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].mentionMeTimeLines];
    [super kdWeiboCore:core didFinishLoadFor:delegate withError:error userInfo:userInfo];
}


@end
