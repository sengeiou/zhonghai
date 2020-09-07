//
//  KDVoteView.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDVoteView.h"

@implementation KDVoteView
@synthesize voteTitleView = _voteTitleView;
@synthesize talbeView = _talbeView;

-(void)dealloc
{
    [_voteTitleView release];    
    [_talbeView release];
    
    [super dealloc];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.voteTitleView = [CommenMethod getMainViewFromNib:[KDVoteTitleView class] owner:nil];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}
-(void)drawRect:(CGRect)rect
{
    [self addSubview:self.voteTitleView];

}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 10; 
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"voteCell";
    KDVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [CommenMethod getMainViewFromNib:[KDVoteCell class] owner:nil];
    }
    return cell;
}


@end
