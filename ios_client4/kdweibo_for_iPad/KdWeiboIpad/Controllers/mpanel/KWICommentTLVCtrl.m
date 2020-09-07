//
//  KWICommentTLVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/16/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWICommentTLVCtrl.h"

#import "KWEngine.h"

#import "NSError+KWIExt.h"

#import "KWICommentMPCell.h"
#import "KWIStatusVCtrl.h"

@interface KWICommentTLVCtrl ()

@property (retain, nonatomic) NSCache *cellCache;

@end

@implementation KWICommentTLVCtrl

@synthesize cellCache = _cellCache;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = [NSArray array];
    
    [self _refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    [_cellCache release];
    [super dealloc];
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

- (KWICommentMPCell *)_loadCellForStatus:(KWComment *)comment
{
    KWICommentMPCell *cell = [self.cellCache objectForKey:comment.id_];
    if (nil == cell) {
        cell = [KWICommentMPCell cell];
        cell.data = comment;
        [self.cellCache setObject:cell forKey:comment.id_];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //KWStatus *status = [[[KWStatus alloc] init] autorelease];
    KWComment *comment = [self.data objectAtIndex:indexPath.row];
    //status.id_ = comment.in_reply_to_status_id;
    //KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:status];
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatusId:comment.in_reply_to_status_id];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf]; 
}

#pragma mark - 
- (void)_refresh
{
    if(!self.isLoading) {
        self.isLoading = YES;
        isLoadMore_ = NO;
        [[KDWeiboCore sharedKDWeiboCore] fetchCommentMeTimeLineIsLoad:isLoadMore_ delegate:self];
        
    }
    
}

- (void)_loadmore
{
    if (self.isLoading) {
        return;
    }    
    self.isLoading = YES;
    
    isLoadMore_ = YES;
    
    [[KDWeiboCore sharedKDWeiboCore] fetchCommentMeTimeLineIsLoad:isLoadMore_ delegate:self];
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
    return @"emptyComment.png";
}

- (NSString *)emptyTextPartial
{
    return @"回复";
}

#pragma mark -

//override this method to do sth. special

- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].commentMeTimeLines];
    [super kdWeiboCore:core didFinishLoadFor:delegate withError:error userInfo:userInfo];
}

@end
