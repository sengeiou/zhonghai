//
//  KDAllDownloadedViewController.m
//  kdweibo
//
//  Created by Tan yingqi on 8/3/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDAllDownloadedViewController.h"
#import "KDDownloadCell.h"
#import "KDWeiboAppDelegate.h"
#import "KDProgressModalViewController.h"
#import "KDDMThread.h"
#import "KDDMConversationViewController.h"

#import "KDWeiboDAOManager.h"
#import "KDDatabaseHelper.h"

#import "NSString+Additions.h"
#import "NSDate+Additions.h"
#import "UIViewAdditions.h"
#import "UIImage+Additions.h"
#import "KDDownloadCell.h"
#import "KDDefaultViewControllerContext.h"


#define KD_ALL_DOWNLOAD_SEPARATOR  110

@interface KDAllDownloadedViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain)NSMutableArray *dataSource;
@property(nonatomic, retain)UIDocumentInteractionController *docInteractionController;
@property(nonatomic, copy) NSString *selectedDownloadId;
@property(nonatomic, retain)UITableView *tableView;
- (KDDownload *)selectedDownload;

@end

@implementation KDAllDownloadedViewController
@synthesize dataSource = dataSource_;
@synthesize docInteractionController = docInteractionController_;
@synthesize selectedDownloadId = selectedDownLoadId_;
@synthesize tableView = tableView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        insertRow_ = NSNotFound;
    }
    return self;
}

- (void) setUpNavBarItem {
    
//    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void) getDataSource {
    [KDDownload grabExistingDowndsWithfinishBlock:^(NSArray *array)  {
        self.dataSource = [NSMutableArray arrayWithArray:array];
        
        if(selectedDownLoadId_) {
            NSUInteger row = [dataSource_ indexOfObject:[self selectedDownload]];
            
            if(row != NSNotFound) {
                insertRow_ = row + 1;
                [dataSource_ insertObject:[NSNull null] atIndex:insertRow_];
            }else {
                insertRow_ = NSNotFound;
            }
        }
        
        [self.tableView reloadData];
        
        if(dataSource_ && dataSource_.count)
            self.tableView.backgroundView = nil;
        else
            [self setBackgroud];
    }];
    
}

- (void) openDocumentWithDownload:(KDDownload * )download {
    KDProgressModalViewController *progressModalViewController = [[KDProgressModalViewController alloc] initWithDownLoadedDownload:download];
    [self.navigationController pushViewController:progressModalViewController animated:YES ];
//    [progressModalViewController release ];
}

//删除下载
- (void)deleteDownload:(KDDownload *)download {
    // TODO: please change to async mode in the future
    [KDDatabaseHelper inDatabase:(id)^(FMDatabase *fmdb){
        id<KDDownloadDAO> downloadDAO = [[KDWeiboDAOManager globalWeiboDAOManager] downloadDAO];
        BOOL success = [downloadDAO removeDownloadWithId:download.downloadId database:fmdb];
        
        return @(success);
        
    } completionBlock:^(id results){
        if ([(NSNumber *)results boolValue]) {
            [KDDownload deleteFromPersisten:download];
            
            if ([dataSource_ containsObject:download]) {
                [dataSource_ removeObjectAtIndex:insertRow_];
                [dataSource_ removeObject:download];
                self.selectedDownloadId = nil;
                insertRow_ = NSNotFound;
                [self.tableView reloadData];
                if(dataSource_ && dataSource_.count)
                    self.tableView.backgroundView = nil;
                else
                    [self setBackgroud];
            }
        }
    }];
}

- (void) setBackgroud
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];// autorelease];
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]];// autorelease];
    [bgImageView sizeToFit];
    bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, 137.5f);
    
    [backgroundView addSubview:bgImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, self.view.bounds.size.width, 15.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = MESSAGE_NAME_COLOR;
    label.text = NSLocalizedString(@"NO_DOWNLOADED_DOCUMENT", @"");
    
    [backgroundView addSubview:label];
//    [label release];
    
    
    [self.tableView setBackgroundView:backgroundView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void) configTableView {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - view lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MESSAGE_BG_COLOR;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] ;//autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];

    
    self.tableView.backgroundColor = MESSAGE_BG_COLOR;
    insertRow_ = NSNotFound;
    self.navigationItem.title = NSLocalizedString(@"NAV_TITLE_DOWNLOADED",@"" );
    [self setUpNavBarItem];
    [self configTableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getDataSource];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.dataSource = nil;
}

- (KDAttachmentMenuCell *)menuView {
    if(!menuCell_) {
        menuCell_ = [[KDAttachmentMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        menuCell_.delegate = self;
        menuCell_.height = [self tableView:self.tableView heightForRowAtIndexPath:nil];
    }
    
    return menuCell_;
}

- (KDDownload *)selectedDownload {
    if(selectedDownLoadId_ && dataSource_ && dataSource_.count) {
        for(KDDownload *d in dataSource_) {
            if([d.downloadId isEqualToString:selectedDownLoadId_])
                return d;
        }
    }
    
    return nil;
}

#pragma  mark -TableView dataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (dataSource_ != nil) ? [dataSource_ count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == insertRow_){
        return [self menuView];
    }else {
        static NSString *CellIdentifier = @"Cell";
        
        KDDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[KDDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.isShowAccessory = YES;
        }
        
        KDDownload *download = [dataSource_ objectAtIndex:indexPath.row];
        cell.download = download;
        
        return cell;
    }
    
}
- (void)arrowTransform:(UIView *)view angle:(CGFloat)angle
{
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        view.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)rowSelectedAtIndex:(int)row
{
    KDDownload *data = [dataSource_ objectAtIndex:row];
    if(insertRow_ == row + 1) {
        [dataSource_ removeObjectAtIndex:insertRow_];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertRow_ inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        
        self.selectedDownloadId = nil;
        insertRow_ = NSNotFound;
        
        KDDownloadCell *cell = (KDDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [self arrowTransform:cell.cellAccessoryImageView angle:0];
    
    } else {
        if(insertRow_ != NSNotFound) {
            
            KDDownloadCell *cell = (KDDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:insertRow_-1 inSection:0]];
            [self arrowTransform:cell.cellAccessoryImageView angle:0];
            
            [dataSource_ removeObjectAtIndex:insertRow_];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertRow_ inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
            row = (int)[dataSource_ indexOfObject:data];
        }
        
        KDDownloadCell *cell = (KDDownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [self arrowTransform:cell.cellAccessoryImageView angle:M_PI*0.5];
        
        self.selectedDownloadId = [(KDDownload *)data downloadId];
        
        insertRow_ = row + 1;
        [dataSource_ insertObject:[NSNull null] atIndex:insertRow_];

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertRow_ inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(insertRow_ == dataSource_.count - 1) ? insertRow_ : insertRow_ + 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

    
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowSelectedAtIndex:(int)indexPath.row];
}

#pragma mark -
#pragma mark KDAttachmentMenuCell Delegate Methods.

- (void)viewButtonClickedInAttachmentMenuCell:(KDAttachmentMenuCell *)cellView {
    [self openDocumentWithDownload:[self selectedDownload]];
}

- (void)deleteButtonClickedInAttachmentMenuCell:(KDAttachmentMenuCell *)cellView {
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"DELETE_DOC_WARNING",@"" )
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OKAY",@"" )
                                              otherButtonTitles:ASLocalizedString(@"Global_Cancel") , nil];
    [alterView show];
//    [alterView release];
}

#pragma  mark - AlertView  Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self deleteDownload:[self selectedDownload]];
    }
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(dataSource_);
    //KD_RELEASE_SAFELY(tableView_);
//    if(selectedDownLoadId_) //KD_RELEASE_SAFELY(selectedDownLoadId_);
    //[super dealloc];
}

@end
