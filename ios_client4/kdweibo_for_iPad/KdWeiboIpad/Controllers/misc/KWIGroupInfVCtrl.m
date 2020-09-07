//
//  KWIGroupInfVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/6/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIGroupInfVCtrl.h"

#import "UIImageView+WebCache.h"

#import "NSError+KWIExt.h"
#import "UIDevice+KWIExt.h"

#import "KWIGroupMemberCell.h"
#import "KWIPeopleVCtrl.h"
#import "KDGroup.h"
#import "KDCommonHeader.h"
#import "iToast.h"

@interface KWIGroupInfVCtrl () <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSArray *members;

@end

@implementation KWIGroupInfVCtrl
{
    IBOutlet UIImageView *_iconV;
    IBOutlet UILabel *_nameV;    
    IBOutlet UIWebView *_bulletinV;
    IBOutlet UIImageView *_bgV;
    
    BOOL _isShadowDisabled;
}

@synthesize group = _group, tableView = _tableView, members = _members;

+ (KWIGroupInfVCtrl *)vctrlWithGroup:(KDGroup *)group
{
    return [[[self alloc] initWithGroup:group] autorelease];
}

- (id)initWithGroup:(KDGroup *)group
{
    self = [super initWithNibName:@"KWIGroupInfVCtrl" bundle:nil];
    if (self) {
        self.group = group;
        self.members = [NSArray array];
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(_onOrientationChanged:) name:@"UIInterfaceOrientationChanged" object:nil];
        [dnc addObserver:self selector:@selector(_onOrientationWillChange:) name:@"UIInterfaceOrientationWillChange" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self _configBgVForCurrentOrientation];
    
    [_iconV setImageWithURL:[NSURL URLWithString:self.group.profileImageURL]];
    _nameV.text = self.group.name;
    
//    DTAttributedTextView *metaV = [[[DTAttributedTextView alloc] initWithFrame:CGRectMake(_nameV.frame.origin.x, _nameV.frame.origin.y + _nameV.frame.size.height + 10, 1000, 400)] autorelease];
//    metaV.backgroundColor = [UIColor clearColor];
//    NSString *tpl = @"<span style=\"font-size:12px; color:#888\">微博</span>&nbsp;&nbsp;"
//                     "<span style=\"font-size:16px; color:#555;\">%d</span>&nbsp;&nbsp;&nbsp;&nbsp;"
//                     "<span style=\"font-size:12px; color:#888;\">成员</span>&nbsp;&nbsp;"
//                     "<span style=\"font-size:16px; color:#555;\">%d</span>";
//   // NSString *html = [NSString stringWithFormat:tpl, self.group.messageCount.intValue, self.group.memberCount.intValue];
//    //NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
//    metaV.attributedString = [[[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL] autorelease];   
//    [metaV sizeToFit];
//    [self.view addSubview:metaV];
    
    //_bulletinV.text = self.group.bulletin.length?self.group.bulletin:@"暂无公告";
    NSString *bulletion = [NSString stringWithFormat:@"<p style=\"font-size:14px; font-family:sans-serif; line-height:1.5; color:#555; background-color:transparent;\">%@</p>",self.group.bulletin.length?self.group.bulletin:@"暂无公告"];
    [_bulletinV loadHTMLString:bulletion baseURL:nil];
    [_bulletinV sizeToFit];
    
    CGRect tbFrame = self.view.frame;
    tbFrame.origin.y = _bulletinV.frame.origin.y + _bulletinV.frame.size.height + 10;
    tbFrame.size.height -= tbFrame.origin.y;    
    self.tableView = [[[UITableView alloc] initWithFrame:tbFrame style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self loadMembers];

  
}
- (void)loadMembers {
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"group_id" stringValue:self.group.groupId]
      setParameter:@"count" stringValue:@"9999"];
    
    __block KWIGroupInfVCtrl *vc = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                NSArray *users = [info objectForKey:@"users"];
                vc.members = users;
                
                [vc.tableView reloadData];
                if ([users count] > 0) {
                    // save users into database
                    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb){
                        id<KDUserDAO> userDAO = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
                        [userDAO saveUsersSimple:users database:fmdb];
                        return nil;
                        
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
                [[iToast makeText:[response.responseDiagnosis networkErrorMessage]] show];
            }
        }

        // release current view controller
        [vc release];
    };
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/group/:members" query:query
                                 configBlock:nil completionBlock:completionBlock];
 
}
- (void)dealloc {
   // []
     NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
    
    [_iconV release];
    [_nameV release];
    [_bulletinV release];
    [_bgV release];
    [super dealloc];
}


- (void)viewDidUnload
{
    [_iconV release];
    _iconV = nil;
    [_nameV release];
    _nameV = nil;
    [_bulletinV release];
    _bulletinV = nil;
    [_bgV release];
    _bgV = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // return [KWIGroupMemberCell cellWithUser:[self.members objectAtIndex:indexPath.row]];
    static NSString *identifier = @"cell";
    KWIGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [KWIGroupMemberCell cell];
    }
    cell.user = self.members[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:[self.members objectAtIndex:indexPath.row]];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (void)_configBgVForCurrentOrientation
{
    if ([UIDevice isPortrait]) {
        if (_isShadowDisabled) {
            _bgV.image = [UIImage imageNamed:@"profileBgPNoShadow.png"];
        } else {
            _bgV.image = [UIImage imageNamed:@"profileBgP.png"];
        }
    } else {
        _bgV.image = [UIImage imageNamed:@"profileBg.png"];
    }
    
    CGRect frame = _bgV.frame;
    frame.size = _bgV.image.size;
    _bgV.frame = frame;
}

- (void)_onOrientationWillChange:(NSNotification *)note
{
    _bgV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)_onOrientationChanged:(NSNotification *)note
{
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOn
{
    _isShadowDisabled = NO;
    [self _configBgVForCurrentOrientation];
}

- (void)shadowOff
{
    _isShadowDisabled = YES;
    [self _configBgVForCurrentOrientation];
}


@end
