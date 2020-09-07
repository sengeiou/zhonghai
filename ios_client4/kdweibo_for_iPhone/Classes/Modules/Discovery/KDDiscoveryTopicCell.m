//
//  KDDiscoveryTopicCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDDiscoveryTopicCell.h"
#import "KDDiscoveryTopicItem.h"
@interface KDDiscoveryTopicCell (){
@private
    NSInteger arrayCount;
    CGRect lineRect[4];
    UIView *lineView[4];
    
    CGRect itemsRect[4];
    KDDiscoveryTopicItem *itemsView[4];
    
}

@end

@implementation KDDiscoveryTopicCell
@synthesize avatarImageView;
@synthesize discoveryLabel;
@synthesize accessoryImageView;
@synthesize delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    avatarImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    avatarImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:avatarImageView];
    
    discoveryLabel = [[UILabel alloc]init];
    discoveryLabel.textColor = MESSAGE_ACTNAME_COLOR;
    discoveryLabel.backgroundColor = [UIColor clearColor];
    discoveryLabel.textAlignment = NSTextAlignmentLeft;
    discoveryLabel.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:discoveryLabel];
    
    accessoryImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3.png"]];
    [accessoryImageView sizeToFit];
    accessoryImageView.highlightedImage = [UIImage imageNamed:@"smallTriangle.png"];
    [self.contentView addSubview:accessoryImageView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesturerRecognizer:)];
    [self addGestureRecognizer:gestureRecognizer];
//    [gestureRecognizer release];
    
    
    
}

#define leftCapWidth 7
#define horizonalLineLength 296.f
#define verticalLineLength  30.f
#define lineLength 1.f
#define itemHeight 48
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat offsetX = 7.f;
    CGFloat offsetY = 7.f;
    CGRect rect = CGRectMake(offsetX, offsetY, 36 , 36);
    avatarImageView.frame = rect;
    
    offsetX += CGRectGetWidth(avatarImageView.frame) + 10.f;
    rect = CGRectMake(offsetX, offsetY, CGRectGetWidth(self.bounds) - offsetX - 13.f , CGRectGetHeight(rect));
    discoveryLabel.frame = rect;
    
    
    accessoryImageView.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(accessoryImageView.bounds) - 13.0f, (50.f - CGRectGetHeight(accessoryImageView.bounds)) * 0.5f, CGRectGetWidth(accessoryImageView.bounds), CGRectGetHeight(accessoryImageView.bounds));
    
    
    
    for(int i =0; i < arrayCount; i++){
        if(i == 0){
            lineRect[i] = CGRectMake(leftCapWidth, 50, horizonalLineLength, lineLength);
            lineRect[i+1] = CGRectMake(self.bounds.size.width/2, 60, lineLength, verticalLineLength );
            
            lineView[i].frame = lineRect[i];
            lineView[i+1].frame = lineRect[i+1];
            
            itemsRect[i] = CGRectMake(leftCapWidth, 51, (self.bounds.size.width- 4 * leftCapWidth)/2, itemHeight);
            itemsView[i].frame = itemsRect[i];
            
            
        }
        else if(i == 1){
            itemsRect[i] = CGRectMake(leftCapWidth + (self.bounds.size.width )/2 , 51, (self.bounds.size.width- 4 * leftCapWidth)/2, itemHeight);
            itemsView[i].frame = itemsRect[i];
            
        }
        else if(i == 2){
            lineRect[i] = CGRectMake(leftCapWidth, 100, horizonalLineLength, lineLength);
            lineRect[i+1] = CGRectMake(self.bounds.size.width/2, 110, lineLength, verticalLineLength);
            
            lineView[i].frame = lineRect[i];
            lineView[i+1].frame = lineRect[i+1];
            
            itemsRect[i] = CGRectMake(leftCapWidth, 101, (self.bounds.size.width - 4 * leftCapWidth)/2, itemHeight);
            itemsView[i].frame = itemsRect[i];
            
        }
        else if(i == 3){
            itemsRect[i] = CGRectMake(leftCapWidth + (self.bounds.size.width)/2 , 101, (self.bounds.size.width- 4 * leftCapWidth )/2, itemHeight);
            itemsView[i].frame = itemsRect[i];
            
        }
    }
    
}

- (void)handleTapGesturerRecognizer : (UITapGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint touchPoint =  [gestureRecognizer locationInView:self];
        CGRect topRect = CGRectMake(0, 0, self.bounds.size.width, 50);
        if(CGRectContainsPoint(topRect, touchPoint)){
            if([delegate respondsToSelector:@selector(kdDiscoveryDidSelectedItemAtIndexPath:)]){
                [delegate kdDiscoveryDidSelectedItemAtIndexPath:KDTopicSelectedIndexMainTopic];
            }
        }
        for(int i =0; i < arrayCount; i++){
            if(CGRectContainsPoint(itemsView[i].frame, touchPoint)){
                itemsView[i].backgroundColor = UIColorFromRGB(0xf1f2f3);
                [self performSelector:@selector(hideItemViewBackgroundColor:) withObject:itemsView[i] afterDelay:0.5f];
                
                if([delegate respondsToSelector:@selector(kdDiscoveryDidSelectedItemAtIndexPath:)]){
                    [delegate kdDiscoveryDidSelectedItemAtIndexPath:i+1];
                }
                break;
            }
        }
    }
}

- (void)hideItemViewBackgroundColor : (UIView *)view{
    [UIView beginAnimations:@"hideItemViewBackgroundColor" context:nil];
    view.backgroundColor = [UIColor clearColor];
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
    
}

- (void)setTopicsItemsWithTopicArray : (NSArray *)topicArray{
    int count = (int)[topicArray count];
    arrayCount = count;
    [self layoutBottomViewWithCount:topicArray];
    
}


- (void)layoutBottomViewWithCount : (NSArray *)topicArray{
    if(arrayCount > 4){
        arrayCount = 4;
    }
    for(int i =0; i < arrayCount; i++){
        if(i == 0){
            
            lineView[i] = [[UIView alloc]initWithFrame:CGRectZero];
            lineView[i].backgroundColor = UIColorFromRGB(0xf1f2f3);
            lineView[i+1] = [[UIView alloc]initWithFrame:CGRectZero];
            lineView[i+1].backgroundColor =  UIColorFromRGB(0xf1f2f3);
            
            itemsView[i] = [[KDDiscoveryTopicItem alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:lineView[i]];
            [self.contentView addSubview:lineView[i+1]];
            [self.contentView addSubview:itemsView[i]];
            
        }
        else if(i == 1){
            itemsView[i] = [[KDDiscoveryTopicItem alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:itemsView[i]];
            
        }
        else if(i == 2){
            
            lineView[i] = [[UIView alloc]initWithFrame:CGRectZero];
            lineView[i].backgroundColor = UIColorFromRGB(0xf1f2f3);
            lineView[i+1] = [[UIView alloc]initWithFrame:CGRectZero];
            lineView[i+1].backgroundColor = UIColorFromRGB(0xf1f2f3);
            
            itemsView[i] = [[KDDiscoveryTopicItem alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:lineView[i]];
            [self.contentView addSubview:lineView[i+1]];
            [self.contentView addSubview:itemsView[i]];
        }
        else if(i == 3){
            itemsView[i] = [[KDDiscoveryTopicItem alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:itemsView[i]];
            
        }
        [itemsView[i].titleLabel setText:topicArray[i]];
        
        
    }
}

- (void)dealloc{
    for(int i = 0; i < arrayCount; i++){
        //KD_RELEASE_SAFELY(lineView[i]);
    }
    for(int i = 0; i < arrayCount; i++){
        //KD_RELEASE_SAFELY(itemsView[i]);
    }
    //KD_RELEASE_SAFELY(accessoryImageView);
    //KD_RELEASE_SAFELY(avatarImageView);
    //KD_RELEASE_SAFELY(discoveryLabel);
    //KD_RELEASE_SAFELY(self.gestureRecognizers);
    //[super dealloc];
}
@end
