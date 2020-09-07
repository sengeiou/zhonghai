//
//  KDTopicGridView.m
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDTopicGridView.h"
#import "KDTopicGridCell.h"

#define MAX_COL   2
#define VER_SEP_TOP_MARGIN  5


@interface KDTopicGridView()

@property(nonatomic,retain)NSMutableArray *labels;
@property(nonatomic,retain)NSMutableArray *horizentalSeparators;
@property(nonatomic,retain)NSMutableArray *verticalSeparators;
@end

@implementation KDTopicGridView
@synthesize labels = labels_;
@synthesize  topics = topics_;
@synthesize horizentalSeparators = horizentalSeparators_;
@synthesize verticalSeparators = verticalSeparators_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ ( NSInteger)numberOfRow:(NSInteger)topicsCout {
    NSInteger rowNum = topicsCout;
    if (rowNum > 1) {
        rowNum =  ceilf((float)topicsCout/MAX_COL);
    }
    return rowNum;
}

- (void)loadRecentTopics {
    
}
- (void)layoutSubviews {
    NSInteger count = [labels_ count];
    if (count == 0) {
        return;
    }
    NSInteger rows = [KDTopicGridView numberOfRow:[topics_ count]];
    NSInteger labelNum = 0;
    NSInteger horNum = 0;
    NSInteger verNum = 0;
    UIView *hor  = nil;
    UIView *ver = nil;
    NSInteger i = 0;
    NSInteger j = 0;
    CGFloat gridWidth = self.bounds.size.width; //每列宽度
    CGFloat gridHeight = TOPIC_GRID_CELL_HEIGHT;
    CGFloat verHeight = (gridHeight - 2*VER_SEP_TOP_MARGIN);
    KDTopicGridCell *label;
    CGPoint center;
    CGFloat eachWidth = gridWidth/MAX_COL;
    if (count > 2) {
        for (i = 0; i< rows ; i++) {
            
            //横向分割线
            hor = [self horizentalSeparatorByIndex:horNum++];
            hor.frame = CGRectMake(0, i * TOPIC_GRID_CELL_HEIGHT, gridWidth, 1);
            
            
           // gridWidth = gridWidth/MAX_COL; //
           
            
            //竖向分割线
            for (j = 0; j< MAX_COL ; j++) { // 竖向分割线数量为列数 -1
                if (j < MAX_COL - 1) {
                    ver = [self verticalSeparatorByIndex:verNum++];
                    ver.frame = CGRectMake((j+1) *eachWidth, TOPIC_GRID_CELL_HEIGHT *i + VER_SEP_TOP_MARGIN, 1, verHeight);
                    
                }
                label = [self labelByIndex:labelNum ++];
                label.bounds = CGRectMake(0, 0, eachWidth, TOPIC_GRID_CELL_HEIGHT);
                
                center = CGPointMake(j*eachWidth + eachWidth *0.5, i*TOPIC_GRID_CELL_HEIGHT + TOPIC_GRID_CELL_HEIGHT * 0.5);
                label.center = center;
            }
            
        }
    }else {
        hor = [self horizentalSeparatorByIndex:horNum];
        hor.frame = CGRectMake(0, 0, gridWidth, 1);
        label = [self labelByIndex:labelNum ++];
        label.bounds = CGRectMake(0, 0, gridWidth, TOPIC_GRID_CELL_HEIGHT);
        //[label sizeToFit];
        center = CGPointMake(gridWidth*0.5, TOPIC_GRID_CELL_HEIGHT * 0.5);
        label.center = center;

    }
   
}

- (KDTopicGridCell *)labelByIndex:(NSInteger)index {
    KDTopicGridCell *label = nil;
    if (!labels_) {
        labels_ = [[NSMutableArray alloc] init];
    }
    if ([labels_ count] < index +1) {
        label = [[KDTopicGridCell alloc] init];// autorelease];
        [label addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:label];
        [labels_  addObject:label];
    }else {
        label = [labels_ objectAtIndex:index];
    }
    
    return label;
}

- (void)tap:(id)sender {
  
    NSInteger index = [self.labels indexOfObject:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSeletedGridAtIndex:)]) {
        [self.delegate didSeletedGridAtIndex:index];
        
    }
    
}

- (UIImageView *)horizentalSeparatorByIndex:(NSInteger)index {
    UIImageView *imageView = nil;
    if (!horizentalSeparators_) {
        horizentalSeparators_ = [[NSMutableArray alloc] init];
    }
    if ([horizentalSeparators_ count] < index +1) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trend_edit_seperator_v3"]];// autorelease];
        [self addSubview:imageView];
        [horizentalSeparators_  addObject:imageView];
    }else {
        imageView = [horizentalSeparators_ objectAtIndex:index];
    }
    return imageView;
}

- (UIImageView *)verticalSeparatorByIndex:(NSInteger)index {
    UIImageView *imageView = nil;
    if (!verticalSeparators_) {
        verticalSeparators_ = [[NSMutableArray alloc] init];
    }
    if ([verticalSeparators_ count] < index +1) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_prompt_separator"]];// autorelease];
        [self addSubview:imageView];
        [verticalSeparators_  addObject:imageView];
    }else {
        imageView = [verticalSeparators_ objectAtIndex:index];
    }
    return imageView;
}

- (void)setTopics:(NSArray *)topics {
    if (topics_ != topics) {
//        [topics_ release];
        topics_ = topics;// retain];
        
        __block KDTopicGridCell *cell = nil;
        [labels_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop) {
            cell = obj;
            cell.text = @"";
        }];
        
        KDTopicGridCell *label = nil;
        for (NSInteger i = 0; i< [topics_ count]; i++) {
            label = [self labelByIndex:i];
            label.text = topics_[i];
  
        }
        [self setNeedsLayout];
    }
 
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(labels_);
    //KD_RELEASE_SAFELY(topics_);
    //KD_RELEASE_SAFELY(horizentalSeparators_);
    //KD_RELEASE_SAFELY(verticalSeparators_);
    //[super dealloc];
}
@end
