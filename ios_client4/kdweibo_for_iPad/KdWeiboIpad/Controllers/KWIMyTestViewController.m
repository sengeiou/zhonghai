//
//  KWIMyTestViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 12-11-6.
//
//

#import "KWIMyTestViewController.h"
#import "NSString+SBJSON.h"
#import "KWMessage.h"
#import "KWDMMessageCell.h"
@interface KWIMyTestViewController ()

@end

@implementation KWIMyTestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSString *path = [[NSBundle mainBundle] pathForResource:@"json" ofType:@"text"];
    NSString *str = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* array = [str JSONValue];
    NSMutableArray *thArray = [NSMutableArray array];
    self.dic = [NSMutableDictionary dictionary];
    for (NSDictionary *theDic in array) {
        KWMessage *messge =[KWMessage messageFromDict:theDic];
        [thArray addObject:messge];
        CGRect frame = CGRectMake(0, 0, 768 - 48 -10, 300);
        
       KDMessageLayouter *layouter = [KDMessageLayouter layouterMessage:messge frame:frame];
        [layouter updateFrame];
        [self.dic setObject:layouter forKey:messge.id_];
        
    }
    self.dataSource = [NSArray arrayWithArray:thArray];
    
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  }

- (void)onTapped:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"tapped......");
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heigth = 0.0;
    KWMessage *curMsg = [self.dataSource objectAtIndex:indexPath.row];
  
    KDMessageLayouter *layouter = [self.dic objectForKey:curMsg.id_];
    heigth = layouter.frame.size.height +20;
    
    return MAX(heigth, 90);
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.dataSource count];
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    KWDMMessageCell *cell = (KWDMMessageCell * )[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[KWDMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    KWMessage *curMsg = [self.dataSource objectAtIndex:indexPath.row];
    KDMessageLayouter *layouter = [self.dic objectForKey:curMsg.id_];
    //[cell setMessage:curMsg];
    [cell update:curMsg layouter:layouter];
    return cell;

    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
