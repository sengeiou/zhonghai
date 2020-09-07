//
//  KDPreInvitePersonViewController.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-28.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPreInvitePersonViewController.h"
#import "KDABRecord.h"
#import "KDInvitePhoneContactsViewController.h"
#import "KDPreInviteCell.h"

@interface KDPreInvitePersonViewController ()
{
    NSMutableArray *preInvitePeople_;
}

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation KDPreInvitePersonViewController

@synthesize preInvitePeople = preInvitePeople_;
@synthesize tableView = tableView_;

- (void)dealloc
{
    //KD_RELEASE_SAFELY(preInvitePeople_);
    //KD_RELEASE_SAFELY(tableView_);
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0.0, 0.0, 61.0, 32.0);
    
    [addButton setBackgroundImage:[UIImage imageNamed:@"post_send_btn_bg_v2.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"post_send_btn_bg_hl_v2.png"] forState:UIControlStateHighlighted];
    
    addButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setTitle:ASLocalizedString(@"添加")forState:UIControlStateNormal];
    
    [addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //song.wang 2013-12-26
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
//    [rightItem release];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];// autorelease];
    [self.view addSubview:tableView_];
    self.view.backgroundColor = RGBCOLOR(235, 235, 235);
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    
//    for(UIGestureRecognizer *reg in self.view.gestureRecognizers) {
//        if([reg isKindOfClass:[UIPanGestureRecognizer class]]) {
//            [self.view removeGestureRecognizer:reg];
//        }
//    }
}

- (void)addContact:(id)sender
{
    KDInvitePhoneContactsViewController *invite = [[KDInvitePhoneContactsViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    invite.invitePeople = preInvitePeople_;
    [self.navigationController pushViewController:invite animated:YES];
}

- (void)setPreInvitePeople:(NSMutableArray *)preInvitePeople
{
    if(preInvitePeople_ != preInvitePeople) {
//        [preInvitePeople_ release];
        preInvitePeople_ = preInvitePeople;// retain];
        
        [self updateTitle];
    }
}

- (void)updateTitle
{
    if(preInvitePeople_.count > 0) {
        self.navigationItem.title = [NSString stringWithFormat:ASLocalizedString(@"KDPreInvitePersonViewController_navigationItem_title_count"), (unsigned long)preInvitePeople_.count];

    }else {
        self.navigationItem.title = ASLocalizedString(@"KDPreInvitePersonViewController_navigationItem_title");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return preInvitePeople_.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    KDPreInviteCell *cell = (KDPreInviteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell) {
        cell = [[KDPreInviteCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier];// autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    KDABRecord *record = [preInvitePeople_ objectAtIndex:indexPath.row];
    cell.textLabel.text = record.name;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [preInvitePeople_ removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateTitle];
    }
}

@end
