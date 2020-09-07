//
//  KDAttachmentViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 7/27/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDAttachmentViewController.h"
//#import "KDProviderManager.h"
#import "KDDownloadCell.h"
#import "KDDownloadManager.h"
#import "KDProgressModalViewController.h"
#import "KDWeiboAppDelegate.h"
#import "KDAllDownloadedViewController.h"

#import "KDStatus.h"
#import "KDDMMessage.h"
#import "KDAttachment.h"

@interface KDAttachmentViewController ()

@property(nonatomic, retain)  NSArray *dataSource;
@property(nonatomic, retain)  id attachmentSourceObj;
@property(nonatomic, retain) UITableView *tableView;

@end

@implementation KDAttachmentViewController

@synthesize dataSource = dataSource_;
@synthesize attachmentSourceObj = attachmentSourceObj_;
@synthesize tableView = _tableView;

- (void)buildDataSourceWithAttachmentSource {
    NSArray *attachemnts = nil;
    if ([attachmentSourceObj_ isKindOfClass:[KDStatus class]]) {
        self.navigationItem.title = NSLocalizedString(@"NAV_TITLE_DM_STATUS",@"" );
        
        KDStatus *status = (KDStatus *)attachmentSourceObj_;
        if ([status hasAttachments]) {
            attachemnts = status.attachments;
            
        } else if ([status.forwardedStatus hasAttachments]) {
            attachemnts = status.forwardedStatus.attachments;
        }
        
        [KDDownload downloadsWithAttachemnts:attachemnts Status:status finishBlock:^(NSArray *result) {
            self.dataSource = result;
            [self.tableView reloadData];
        }];
    } else if([attachmentSourceObj_ isKindOfClass:[KDDMMessage class]]){
        self.navigationItem.title = NSLocalizedString(@"NAV_TITLE_DM_DOC", @"");
        
        KDDMMessage *dm = (KDDMMessage *)attachmentSourceObj_;
        attachemnts = dm.attachments;
        
        [KDDownload downloadsWithAttachemnts:attachemnts diretMessage:dm finishBlock:^(NSArray *result){
            self.dataSource = result;
            [self.tableView reloadData];
        }];
    }
}

- (id)initWithSource:(id)source {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.attachmentSourceObj = source;
    }
    
    return self;
}

- (void) setNavBarItem {
    /*
    UIImage *imageNormal = [[UIImage imageNamed:@"post_send_btn_bg_v2.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:15];
	UIImage *imageHighlighted = [[UIImage imageNamed:@"post_send_btn_bg_hl_v2.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:15];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"NAV_TITLE_DOWNLOADED",@"" ) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setBackgroundImage: imageNormal forState:UIControlStateNormal];
    [button setBackgroundImage: imageHighlighted forState:UIControlStateHighlighted];
    button.frame= CGRectMake(0.0, 0.0, 85,30);
    
    [button addTarget:self action:@selector(allDownloadedDocuments) forControlEvents:UIControlEventTouchUpInside];
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, button.frame.size.width,button.frame.size.height )];    
    [v addSubview:button];
    
    UIBarButtonItem *reviewDownloadedbtnItem = [[UIBarButtonItem alloc] initWithCustomView:v];
    [v release];
    
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        self.navigationItem.rightBarButtonItem = reviewDownloadedbtnItem;
        //
    }else {
        UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                            target:nil action:nil] autorelease];
        negativeSpacer.width = -14;
        self.navigationItem.rightBarButtonItems = [NSArray
                                                   arrayWithObjects:negativeSpacer,reviewDownloadedbtnItem, nil];
    }
    [reviewDownloadedbtnItem release];
    */
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setImage:[UIImage imageNamed:@"document_downloaded"] forState:UIControlStateNormal];
    [confirmBtn setImage:[UIImage imageNamed:@"document_downloaded_selected"] forState:UIControlStateHighlighted];
    [confirmBtn addTarget:self action:@selector(allDownloadedDocuments) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:confirmBtn];
    //2013.9.30  修复ios7 navigationBar 左右barButtonItem 留有空隙bug   by Tan Yingqi
    //2013-12-26 song.wang
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];// autorelease];
    negativeSpacer.width = kRightNegativeSpacerWidth;
    self.navigationItem.rightBarButtonItems = [NSArray
                                               arrayWithObjects:negativeSpacer,rightItem, nil];
//    [rightItem release];
    
}

- (void) configTableView {
    
    [self.tableView setBackgroundColor:MESSAGE_BG_COLOR];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = [KDDownloadCell downloadCellHeight];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] ;//autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];

    [self setNavBarItem];
    [self configTableView];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self buildDataSourceWithAttachmentSource];
    
    [self.navigationController.navigationBar setHidden:NO];
}
- (void) allDownloadedDocuments {
    KDAllDownloadedViewController *allDownloadViewController = [[KDAllDownloadedViewController alloc] init];// autorelease];
    [self.navigationController pushViewController:allDownloadViewController animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)executeWithDownload:(KDDownload *)download {
    KDProgressModalViewController *progressModalViewController = [[KDProgressModalViewController alloc] initWithDownload:download];
    [self.navigationController pushViewController:progressModalViewController animated:YES];
//    [progressModalViewController release]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KDDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KDDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    KDDownload *download = [dataSource_ objectAtIndex:indexPath.row];
    cell.download = download;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    KDDownload *download = [dataSource_ objectAtIndex:indexPath.row];
    if ([download isSuccess]) {
        [(KDDownloadCell *)cell showStateIndicator];
        
    }else {
         [(KDDownloadCell *)cell hideStateIndicator];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KDDownload *download = [dataSource_ objectAtIndex:indexPath.row];
    [self executeWithDownload:download];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(attachmentSourceObj_);
    //KD_RELEASE_SAFELY(dataSource_);
    //KD_RELEASE_SAFELY(_tableView);
    
    //[super dealloc];
}

@end
