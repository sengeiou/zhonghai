//
//  KWIGroupStreamVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIGroupStreamVCtrl.h"

#import "NSError+KWIExt.h"

#import "KWEngine.h"
#import "KWIStatusCell.h"
#import "KWIStatusVCtrl.h"
#import "KWIGroupInfVCtrl.h"
#import "KDGroup.h"
@interface KWIGroupStreamVCtrl ()

@property (retain, nonatomic) NSCache *cellCache;
@property (retain, nonatomic) NSMutableArray *data;

@end

@implementation KWIGroupStreamVCtrl
{
    UITableViewCell *_headerCell;
}

@synthesize group = _group, cellCache = _cellCache, data = _data;

+ (KWIGroupStreamVCtrl *)vctrlWithGroup:(KWGroup *)group
{
    return [[[self alloc] initWithGroup:group] autorelease];
}

- (id)initWithGroup:(KDGroup *)group
{
    self = [super init];
    
    if(self)
    {
        self.group = group;
        
        _headerCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
        _headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _headerCell.autoresizingMask = UIViewAutoresizingNone;
        
        UILabel *nameV = [[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 1000, 200)] autorelease];
        nameV.font = [UIFont systemFontOfSize:24];
        nameV.textColor = [UIColor colorWithHexString:@"333"];
        nameV.backgroundColor = [UIColor clearColor];
        nameV.text = group.name;
        [nameV sizeToFit];
        [_headerCell addSubview:nameV];
        
        UIButton *infBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [infBtn setImage:[UIImage imageNamed:@"groupInfBtn.png"] forState:UIControlStateNormal];
        infBtn.frame = CGRectMake(418, 10, 44, 44);
        infBtn.userInteractionEnabled = NO;
        [_headerCell addSubview:infBtn];
        
        UIView *borderBtn = [[[UIView alloc] initWithFrame:CGRectMake(0, 67, self.view.frame.size.width, 1)] autorelease];
        borderBtn.autoresizingMask = UIViewAutoresizingNone;
        borderBtn.backgroundColor = [UIColor colorWithHexString:@"d5d1bc"];
        [_headerCell addSubview:borderBtn];
        
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self
                selector:@selector(_refresh)
                    name:@"KWIPostVCtrl.newGroupStatus"
                  object:nil];
        [dnc addObserver:self
                selector:@selector(_onStatusDeleted:)
                    name:@"KWStatus.remove"
                  object:nil];
        
        [[KDWeiboCore sharedKDWeiboCore].groupTimeLines removeAllObjects];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.data = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].groupTimeLines];
    
    
    [self _refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_cellCache release];
    [_data release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return 68;
    } else {
        UITableViewCell *cell = [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row - 1]];
        
        return CGRectGetHeight(cell.frame);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return _headerCell;
    } else {
        return [self _loadCellForStatus:[self.data objectAtIndex:indexPath.row - 1]];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        KWIGroupInfVCtrl *vctrl = [KWIGroupInfVCtrl vctrlWithGroup:self.group];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIGroupInfVCtrl.show" object:self userInfo:inf];
    } else {
        KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:[self.data objectAtIndex:indexPath.row - 1]];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
    }
}

#pragma mark -
- (void)_refresh
{
    if(self.isLoading) return;
    
    self.isLoading = YES;
    
    isLoadMore_ = NO;
    
    //[[KDWeiboCore sharedKDWeiboCore] fetchGroupTimeLineIsLoad:NO forGroup:self.group.id_ delegate:self];
}

- (void)_loadmore
{
    if(self.isLoading) return;
    
    self.isLoading = YES;
    isLoadMore_ = YES;
   // [[KDWeiboCore sharedKDWeiboCore] fetchGroupTimeLineIsLoad:YES forGroup:self.group.id_ delegate:self];
}

- (void)_onStatusDeleted:(NSNotification *)note
{
    KWStatus *status = note.object;
    KWStatus *toDel = nil;
    unsigned int idxRm = 0;
    for (KWStatus *e in self.data) {
        if ([e.id_ isEqualToString:status.id_]) {
            toDel = e;
            break;
        }
        idxRm++;
    }
    
    if (nil == toDel) {
        return;
    }
    
    [self.data removeObject:toDel];
    
    NSArray *indexpaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:idxRm+1 inSection:0]];
    [self.tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
- (NSCache *)cellCache
{
    if (!_cellCache) {
        _cellCache = [[NSCache alloc] init];
        _cellCache.name = self.class.description;
        _cellCache.countLimit = 50;
    }
    
    return _cellCache;
}

#pragma mark - empty view

- (NSString *)emptyImageName
{
    return @"emptyStatus.png";
}

- (NSString *)emptyTextPartial
{
    return @"来自该小组的微博";
}

- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    self.data = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].groupTimeLines];
    
    [super kdWeiboCore:core didFinishLoadFor:delegate withError:error userInfo:userInfo];
}
@end
