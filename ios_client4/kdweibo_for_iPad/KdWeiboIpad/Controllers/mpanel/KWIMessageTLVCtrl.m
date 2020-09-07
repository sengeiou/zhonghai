//
//  KWIMessageTLVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMessageTLVCtrl.h"

#import "NSError+KWIExt.h"
#import "KWEngine.h"

#import "KWIThreadCell.h"
#import "KWIConversationVCtrl.h"
#import "KWISimpleFollowingsVCtrl.h"
#import "KWISelectThreadParticipantVCtrl.h"
#import "KDDMThread.h"

@interface KWIMessageTLVCtrl ()

@property (retain, nonatomic) UIButton *nThreadBtn;
@property (assign, nonatomic, readonly) NSUInteger PAGE_SIZE_;

@end

@implementation KWIMessageTLVCtrl
{
    KWISelectThreadParticipantVCtrl *_selectThreadParticipantVCtrl;
}

@synthesize nThreadBtn = _nThreadBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImage *newThreadBg = [UIImage imageNamed:@"newThreadBg.png"];
    UIImageView *newThreadBgV = [[[UIImageView alloc] initWithImage:newThreadBg] autorelease];
    [self.view addSubview:newThreadBgV];
    
    self.data = [NSArray array];
    
    UIImage *newThreadBtnImg = [UIImage imageNamed:@"newThreadBtn.png"];
    self.nThreadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect btnFrame = self.nThreadBtn.frame;
    btnFrame.size = newThreadBtnImg.size;
    btnFrame.origin.x = (newThreadBg.size.width - btnFrame.size.width) / 2;
    btnFrame.origin.y = (newThreadBg.size.height - btnFrame.size.height) / 2;
    self.nThreadBtn.frame = btnFrame;
    [self.nThreadBtn setBackgroundImage:newThreadBtnImg forState:UIControlStateNormal];
    self.nThreadBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
    [self.nThreadBtn setTitleColor:[UIColor colorWithRed:93/255.0 green:71/255.0 blue:61/255.0 alpha:1] forState:UIControlStateNormal];
    [self.nThreadBtn setTitle:@" 新 建 短 邮" forState:UIControlStateNormal];
    [self.nThreadBtn addTarget:self action:@selector(_onNewThreadBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nThreadBtn];
    
    CGRect frame = self.tableView.frame;
    frame.origin.y = newThreadBg.size.height;
    frame.size.height -= frame.origin.y;
    self.tableView.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_onParticipantsSelected:)
                                                 name:@"KWISelectThreadParticipantVCtrl.doneSelecting"
                                               object:nil];
    
    [self _refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_selectThreadParticipantVCtrl release];
    [super dealloc];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"KWIThreadCell";
    KWIThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (nil == cell) {
        cell = [KWIThreadCell cell];
    }
    
    cell.data = [self.data objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDDMThread *thread = [self.data objectAtIndex:indexPath.row];
    KWIConversationVCtrl *vctrl = [KWIConversationVCtrl vctrlForThread:thread];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIConversationVCtrl.show" object:self userInfo:inf]; 
}

#pragma mark -
- (void)refresh
{
    [self _refresh];
}

- (void)_refresh
{
    if(!self.isLoading) {
        isLoadMore_ = NO;
        self.isLoading = YES;
        [[KDWeiboCore sharedKDWeiboCore] fetchMessageListIsLoad:isLoadMore_ delegate:self];
    }
}

- (void)_loadmore
{
    if(!self.isLoading) {
        self.isLoading = YES;
        isLoadMore_ = YES;
        [[KDWeiboCore sharedKDWeiboCore] fetchMessageListIsLoad:isLoadMore_ delegate:self];
    }
}

- (void)newMessage:(NSArray *)participants
{
    KDDMThread*thread = [[[KDDMThread alloc] init] autorelease];
    //thread.participants = participants;
    KWIConversationVCtrl *vctrl = [KWIConversationVCtrl vctrlForThread:thread];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIConversationVCtrl.show" object:self userInfo:inf];
}

- (void)_onNewThreadBtnTapped
{
    if (!_selectThreadParticipantVCtrl) {
        _selectThreadParticipantVCtrl = [[KWISelectThreadParticipantVCtrl vctrl] retain];
    }
    
    [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:_selectThreadParticipantVCtrl.view];
}

- (void)_onParticipantsSelected:(NSNotification *)note
{
    [self newMessage:[note.userInfo objectForKey:@"users"]];
}

#pragma mark - empty view

- (NSString *)emptyImageName
{
    return @"emptyMsg.png";
}

- (NSString *)emptyTextPartial
{
    return @"短邮";
}

#pragma mark -

//override this method to do sth. special

 - (void)kdWeiboCore:(KDWeiboCore *)core didFinishLoadFor:(id)delegate withError:(NSError *)error userInfo:(NSDictionary *)userInfo {
     self.data = [NSArray arrayWithArray:[KDWeiboCore sharedKDWeiboCore].messageList];
     [super kdWeiboCore:core didFinishLoadFor:delegate withError:error userInfo:userInfo];
 }
@end
