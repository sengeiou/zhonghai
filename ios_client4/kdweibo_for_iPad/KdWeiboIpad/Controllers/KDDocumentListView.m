//
//  KDDocumentListView.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-22.
//
//

#import "KDDocumentListView.h"
#import "KDDocumentCell.h"
#import "KDDMMessage.h"
#import "KDStatus.h"
#import "KDAttachment.h"
#import "KDDownload.h"
#import "KDDocumentCell.h"
#import "KDDocumentMoreCell.h"
#import "UIImage+Additions.h"
#import "KDDocumentsAllListViewController.h"
#import "KDDocumentPreviewViewController.h"
@interface KDDocumentListView()<UITableViewDataSource,UITableViewDelegate>
 @property(nonatomic,retain)  UITableViewCell *moreDocCell;
 @property (nonatomic,retain) NSArray *documentArray;
@property (nonatomic,retain) UIActivityIndicatorView *activiyIndicatorView;
@end

@implementation KDDocumentListView
@synthesize moreDocCell = moreDocCell_;
@synthesize documentArray = documentArray_;
@synthesize documentDataSource = documentDataSource_;
@synthesize activiyIndicatorView = activiyIndicatorView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        activiyIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:activiyIndicatorView_];
        activiyIndicatorView_.hidesWhenStopped = YES;
        
    }
    return self;
}


- (void)setDocumentDataSource:(id)documentDataSource {
    if (documentDataSource_ != documentDataSource) {
        [documentDataSource_ release];
        documentDataSource_ = [documentDataSource retain];
        [self buildDataSourceWithAttachmentSource];
    }
}

- (void)buildDataSourceWithAttachmentSource {
    NSArray *attachemnts = nil;
    if ([documentDataSource_ isKindOfClass:[KDStatus class]]) {
        
        KDStatus *status = (KDStatus *)documentDataSource_;
        if ([status hasAttachments]) {
            attachemnts = status.attachments;
        }
        [activiyIndicatorView_ startAnimating];
        [KDDownload downloadsWithAttachemnts:attachemnts Status:status finishBlock:^(NSArray *result) {
            self.backgroundColor = [UIColor whiteColor];
            [self.activiyIndicatorView stopAnimating];
            
            self.documentArray = result;
            [self reloadData];
        }];
    } else if([documentDataSource_ isKindOfClass:[KDDMMessage class]]){
        
        KDDMMessage *dm = (KDDMMessage *)documentDataSource_;
        attachemnts = dm.attachments;
        [activiyIndicatorView_ startAnimating];
        [KDDownload downloadsWithAttachemnts:attachemnts diretMessage:dm finishBlock:^(NSArray *result){
            self.backgroundColor = [UIColor whiteColor];
            [self.activiyIndicatorView stopAnimating];
            
            self.documentArray = result;
            [self reloadData];
        }];
    }
}

+(CGFloat)heightOfTableViewByAttachemts:(NSArray *)attachemts {
    CGFloat height = 0;
    NSInteger count = [attachemts count];
    height = count>5?(5*[KDDocumentCell optimalHeight]+[KDDocumentMoreCell optimalHeight]):count*[KDDocumentCell optimalHeight];
    return height;
}

//+(CGFloat)heightOfTableViewByMessage:(KDDMMessage *)message {
//    CGFloat height = 0;
//    NSInteger count = [message.attachments count];
//    // count = count >5?5:count;
//    //height+=(count *ROW_HEIGHT);
//    height = count>5?(5*[KDDocumentCell optimalHeight]+[KDDocumentMoreCell optimalHeight]):count*[KDDocumentCell optimalHeight];
//    return height;
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    // Return the number of sections.
    return ([documentArray_ count] >5?2:1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = [KDDocumentCell optimalHeight];
    }else if (indexPath.section == 1) {
        height = [KDDocumentMoreCell optimalHeight];
    }
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rows = 0;
    if (section == 0) {
        rows =  [documentArray_ count]>5?5:[documentArray_ count];
    }
    else if(section == 1) {
        rows = 1;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[[KDDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.backgroundView = nil;
            
        }
        
        KDDownload *download = self.documentArray[indexPath.row];
        ((KDDocumentCell *)cell).download = download;
    }
    else if (indexPath.section == 1) {
        cell = [self moreDocsCell];
    }
    // Configure the cell...
    return cell;
}

- (UITableViewCell *)moreDocsCell {
    if (moreDocCell_ == nil) {
        
        KDDocumentMoreCell *cell = [[KDDocumentMoreCell alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [KDDocumentMoreCell optimalHeight])];
        [cell setMoreCount:[self.documentArray count] - 5];
        moreDocCell_ = cell;
        
    }
    return moreDocCell_;
    
}

- (id)topMostController {
    for (UIView* next = [self  superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return [NSNull null];
    
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *vctrl = nil;
    if (indexPath.section == 0) {
        KDDownload *download = self.documentArray[indexPath.row];
        vctrl = [[[KDDocumentPreviewViewController  alloc] init] autorelease];
        ((KDDocumentPreviewViewController *)vctrl).download = download;
        
    }else if(indexPath.section == 1) {
        
        vctrl = [[[KDDocumentsAllListViewController alloc] init] autorelease];
        ((KDDocumentsAllListViewController *)vctrl).downloadArray = self.documentArray;
        ((KDDocumentsAllListViewController *)vctrl).data = self.documentDataSource;
        
    }
    UIViewController *controllerFrom = [self topMostController];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [controllerFrom class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentList.show" object:self userInfo:inf];
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)dealloc {
    KD_RELEASE_SAFELY(moreDocCell_);
    KD_RELEASE_SAFELY(documentArray_);
    KD_RELEASE_SAFELY(documentDataSource_);
    KD_RELEASE_SAFELY(activiyIndicatorView_);
    [super dealloc];
}
@end
