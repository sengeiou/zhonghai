//
//  KWIGroupLsVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/5/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIGroupLsVCtrl.h"

#import "KWEngine.h"

#import "NSError+KWIExt.h"

#import "KWIGroupCell.h"
#import "KWIGroupStreamVCtrl.h"
#import "KWIRootVCtrl.h"

@interface KWIGroupLsVCtrl () <UITableViewDataSource, UITableViewDelegate, KDWeiboCoreDelegate>

@property (retain, nonatomic) NSMutableArray *data;

@end

@implementation KWIGroupLsVCtrl
{
    UIView *_emptyV;
    NSCache *_cellCache;
}

@synthesize tableView = _tableView, data = _data;

+ (KWIGroupLsVCtrl *)vctrl
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(10, 0, 250, CGRectGetHeight(KWIRootVCtrl.curInst.view.bounds));
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        UIImage *bg = [UIImage imageNamed:@"groupLsBg.png"];
        UIImageView *bgv = [[[UIImageView alloc] initWithImage:bg] autorelease];
        CGRect bgFrame = bgv.frame;
        bgFrame.origin.x = -20;
        bgFrame.origin.y = -4;
        bgFrame.size.height = CGRectGetHeight(self.view.frame) + 4;
        bgv.frame = bgFrame;       
        bgv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:bgv];
        
        self.data = [NSMutableArray array];
        
        _cellCache = [[NSCache alloc] init];
        _cellCache.name = self.class.description;
        _cellCache.countLimit = 20;
        
        self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;       
        [self.view addSubview:self.tableView];
        
        [[KDWeiboCore sharedKDWeiboCore] fetchGroupListWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[KDWeiboCore sharedKDWeiboCore] removeEverythingAbout:self];
    [_cellCache release];
    [_emptyV release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _loadCellForGroup:[self.data objectAtIndex:indexPath.row]];
}

- (KWIGroupCell *)_loadCellForGroup:(KWGroup *)group
{
    KWIGroupCell *cell = [_cellCache objectForKey:group.id_];
    if (nil == cell) {
        cell = [KWIGroupCell cellWithGroup:group];
        [_cellCache setObject:cell forKey:group.id_];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWGroup *group = [self.data objectAtIndex:indexPath.row];
    group.unreadCount = [NSNumber numberWithInt:0];
    
    //KWIGroupStreamVCtrl *groupStreamVCtrl = [KWIGroupStreamVCtrl vctrlWithGroup:group];
  //  NSDictionary *uinf = [NSDictionary dictionaryWithObject:groupStreamVCtrl forKey:@"vctrl"];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"KWIGroupStreamVCtrl.show" object:self userInfo:uinf];
}

#pragma mark
- (UIView *)emptyV
{
    if (!_emptyV) {
        _emptyV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) / 2 - 140, CGRectGetWidth(self.view.bounds), 120)];
        _emptyV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _emptyV.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgV = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyGroupLs.png"]] autorelease];
        CGRect imgFrm = imgV.frame;
        imgFrm.origin.x = (CGRectGetWidth(_emptyV.bounds) - CGRectGetWidth(imgFrm)) / 2;
        imgV.frame = imgFrm;
        [_emptyV addSubview:imgV];
        
        UILabel *emptyTextV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(_emptyV.bounds), 40)] autorelease];
        emptyTextV.backgroundColor = [UIColor clearColor];
        emptyTextV.textAlignment = UITextAlignmentCenter;
        emptyTextV.textColor = [UIColor colorWithHexString:@"666"];
        emptyTextV.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
        emptyTextV.text = @"你还没有加入任何小组";
        [_emptyV addSubview:emptyTextV];
    }
    
    return _emptyV;
}

- (void)updateUnreadCount:(NSDictionary *)inf
{
    for (KWGroup *group in self.data) {
        NSNumber *unreadNum = [inf objectForKey:group.id_];
        if (unreadNum) {
            group.unreadCount = unreadNum;
        }
    }
}

- (void)refresh {
    [[KDWeiboCore sharedKDWeiboCore] fetchGroupListWithDelegate:self];
}

#pragma mark - 
- (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    
    dispatch_block_t block = ^{
        self.data = [NSMutableArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].groupList];
        
        
        if(self.data.count == 0)
           [self.view addSubview:[self emptyV]];
        else if(_emptyV.superview == self.view)
            [_emptyV removeFromSuperview];
        
        if(error)
            [error KWIGeneralProcess];
        
        [self.tableView reloadData];
            
    };
    
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
