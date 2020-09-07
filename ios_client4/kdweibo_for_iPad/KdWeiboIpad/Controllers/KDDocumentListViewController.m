//
//  KDDocumentListViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-25.
//
//

#import "KDDocumentListViewController.h"
#import "KDDMMessage.h"
#import "KDStatus.h"
#import "KDAttachment.h"
#import "KDDownload.h"
#import "KDDocumentCell.h"
#import "KDDocumentMoreCell.h"
#import "UIImage+Additions.h"
#import "KDDocumentsAllListViewController.h"
#import "KDDocumentPreviewViewController.h"
#define ROW_HEIGHT  60.0f

@interface KDDocumentListViewController () {
    
    UITableViewCell *moreDocCell_;
}
@property (nonatomic,retain)NSArray *documentArray;


@end

@implementation KDDocumentListViewController
@synthesize documentArray = documentArray_;
@synthesize documentDataSource = documentDataSource_;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
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
        //暂时以文档的形式来显示视频
        if ([status hasAttachments] || [status hasVideo]) {
            attachemnts = status.attachments;
        }
        [KDDownload downloadsWithAttachemnts:attachemnts Status:status finishBlock:^(NSArray *result) {
            self.documentArray = result;
            [self.tableView reloadData];
        }];
    } else if([documentDataSource_ isKindOfClass:[KDDMMessage class]]){
        
        KDDMMessage *dm = (KDDMMessage *)documentDataSource_;
        attachemnts = dm.attachments;
        
        [KDDownload downloadsWithAttachemnts:attachemnts diretMessage:dm finishBlock:^(NSArray *result){
            self.documentArray = result;
            [self.tableView reloadData];
        }];
    }
}

+(CGFloat)heightOfTableViewByStatus:(KDStatus *)status {
    CGFloat height = 0;
    NSInteger count = [status.attachments count];
   // count = count >5?5:count;
    //height+=(count *ROW_HEIGHT);
    height = count>5?(5*[KDDocumentCell optimalHeight]+[KDDocumentMoreCell optimalHeight]):count*[KDDocumentCell optimalHeight];
    return height;
}

+(CGFloat)heightOfTableViewByMessage:(KDDMMessage *)message {
    CGFloat height = 0;
    NSInteger count = [message.attachments count];
    // count = count >5?5:count;
    //height+=(count *ROW_HEIGHT);
    height = count>5?(5*[KDDocumentCell optimalHeight]+[KDDocumentMoreCell optimalHeight]):count*[KDDocumentCell optimalHeight];
    return height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
//        footerView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more_docs"]];
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//        CGRect frame = imageView.frame;
//        frame.origin.x = 35;
//        frame.origin.y = (CGRectGetHeight(footerView_.frame) - frame.size.height) *0.5;
//        imageView.frame = frame;
//        [footerView_ addSubview:imageView];
//        [imageView release];
//        
//        frame.origin.x = CGRectGetMaxX(frame) +26;
//        UILabel *lable = [[UILabel alloc] initWithFrame:frame];
//        lable.font = [UIFont boldSystemFontOfSize:13];
//        lable.text = [NSString stringWithFormat:@"还有%d个文档，点击查看",8];
//        [footerView_ addSubview:lable];
//        [lable release];
//        
//        UIGestureRecognizer *grzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerViewTapped:)];
//        [footerView_ addGestureRecognizer:grzr];
//        [grzr release];
//        KDDocumentCell *cell = [[KDDocumentCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
//       /// cell.backgroundColor = [UIColor blackColor];
//        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"more_docs_btn_bg" leftCapWidth:5 topCapHeight:0]];
//        backgroundView.frame = CGRectMake(-2, -4, self.view.frame.size.width+4, 72);
//        cell.backgroundView = backgroundView;
       
//        UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"more_docs_btn_bg" leftCapWidth:5 topCapHeight:0]];
//        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        selectedBackgroundView.frame = CGRectMake(-1, -1, self.view.frame.size.width+2, 70);
//        cell.selectedBackgroundView = backgroundView;
//
        
//        ((KDDocumentCell *)cell).kindImageView.image = [UIImage imageNamed:@"icon_more_docs"];
//        ((KDDocumentCell *)cell).filenameLabel.text = [NSString stringWithFormat:@"还有%d个文档，点击查看",[self.documentArray count] - 5];
//        moreDocCell_ = cell;
        
//        moreDocCell_ = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 68)];
//        moreDocCell_.backgroundColor = [UIColor blackColor];
//        UIButton *button = [[UIButton alloc] initWithFrame:moreDocCell_.bounds];
//        [moreDocCell_ addSubview:button];
//        [button setBackgroundImage:[UIImage stretchableImageWithImageName:@"more_docs_btn_bg" leftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"icon_more_docs"] forState:UIControlStateNormal];
//        [button setTitle:[NSString stringWithFormat:@"还有%d个文档，点击查看",[self.documentArray count] - 5] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        NSLog(@"button's frame = %@",NSStringFromCGRect(button.frame));
//        NSLog(@"moreDocCell_ bounds = %@",NSStringFromCGRect(moreDocCell_.bounds));
        KDDocumentMoreCell *cell = [[KDDocumentMoreCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [KDDocumentMoreCell optimalHeight])];
        [cell setMoreCount:[self.documentArray count] - 5];
        moreDocCell_ = cell;
        
    }
    return moreDocCell_;
    
}

- (id)topMostController {
    for (UIView* next = [self.view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]] &&![nextResponder isKindOfClass:[KDDocumentListViewController class]]) {
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
    [super dealloc];
}
@end
