//
//  KDPersonAppListView.m
//  kdweibo
//
//  Created by fang.jiaxin on 15/8/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonAppListView.h"
#import "KDAppDataModel.h"
#import "KDPersonalAppView.h"

#define kAppViewOrigin(x,y)         CGRectMake(x, y, kAppViewWidth, kAppViewHeight)
//#define kSearchbarHeight            50.0f                       //搜索栏高度
#define kSearchbarHeight            0.0f                        //没有搜索栏
#define kAppIconWidth               48.0f                       //已添加应用图标宽
#define kAppIconHeight              48.0f + 38.0f                      //已添加应用图标高
#define kAppViewWidth               (kAppIconWidth  + 5)       //已添加应用视图的宽 （左右边距 ＋ 图标宽度）
#define kAppViewHeight              (kAppIconHeight + 7)   //已添加应用视图的高 （上边距 ＋ 图标高度 ＋ 下边距
//#define kAppViewXMagin              (33 - 5 * 2)                //已添加应用视图的横向间距  （图标间距 － 视图内图标的左右连距）
//#define kAppViewStartX              10                          //已添加应用视图的第行的x起始坐标
#define kTopMargin                  6.0f                        //最上边的间距
#define kWholeViewBGHeight          MainHeight - 44 - 44 - kSearchbarHeight - 5   //应用整个视图的高度 (手机屏幕高度 － 导航栏高 － 切换页签高 － 搜索栏高 － 调整高度

@interface KDPersonAppListView()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) KDPersonalAppView *currentAppView;
@end

@implementation KDPersonAppListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    //先移除数据
    if(!self.rectArray)
    {
        self.rectArray = [[NSMutableArray alloc] init];
        self.viewArray = [[NSMutableArray alloc] init];;
    }
    else
    {
        [self.rectArray removeAllObjects];
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KDPersonalAppView *view = obj;
            [view removeFromSuperview];
        }];
        [self.viewArray removeAllObjects];
    }
    self.lastFrame = CGRectZero;
    self.tempAppView = nil;
    
    int count = [self getCountOneCell];
    float space = (self.frame.size.width - count*kAppViewWidth)/(count+1);
    float startOriginX = space-10;
    space = (self.frame.size.width - count*kAppViewWidth - 2*startOriginX)/(count-1);
    float nextOriginX = startOriginX;
    float nextOriginY = 15.0;
    for (int i = 0; i < [self.dataArray count]; i++)
    {
        KDAppDataModel * appDM = [self.dataArray objectAtIndex:i];
        
        CGRect frame = kAppViewOrigin(nextOriginX, nextOriginY);
        KDPersonalAppView * appView = [[KDPersonalAppView alloc]initWithAppDataModel:appDM frame:frame delFlag:appDM.delFlag];
        
        //保存坐标位置
        [self.rectArray addObject:[NSValue valueWithCGRect:frame]];
        
        //是否显示新功能标志
        [appView setIsFeatureFuc:appDM.isFeatureFuc];
        
        appView.delegate = self;
        [self addSubview:appView];
        nextOriginX += (kAppViewWidth + space);
        if (nextOriginX >= self.bounds.size.width - startOriginX)
        {
            nextOriginX = startOriginX;
            nextOriginY += kAppViewHeight;
        }
        
        //保存控件
        [self.viewArray addObject:appView];
    }
}

-(CGPoint)getNextIconLocation
{
    if(self.rectArray.count>0)
    {
        int count = [self getCountOneCell];
        float space = (self.frame.size.width - count*kAppViewWidth)/(count+1);
        float startOriginX = space-10;
        space = (self.frame.size.width - count*kAppViewWidth - 2*startOriginX)/(count-1);

        CGPoint location = ((NSValue *)[self.rectArray lastObject]).CGRectValue.origin;
        location.x += (kAppViewWidth + space);
        if (location.x >= self.bounds.size.width - startOriginX)
        {
            location.x = startOriginX;
            location.y += kAppViewHeight;
        }
        
        location.x+=5;
        location.y+=7;
        return location;
    }
    
    int count = [self getCountOneCell];
    float space = (self.frame.size.width - count*kAppViewWidth)/(count+1);
    float startOriginX = space-10;
    return CGPointMake(startOriginX, 15.0);
}

-(CGSize)getIconSize
{
    return CGSizeMake(kAppViewWidth-5, kAppViewHeight-7);
}


-(int)getCountOneCell
{
    int count = 4;
//    if(self.frame.size.width>=414)
//        count = 4;
    return count;
}

-(void)goToAppWithDataModel:(KDAppDataModel *)appDM
{
    if (_appDelegate && [_appDelegate respondsToSelector:@selector(goToAppWithDataModel:)])
            [_appDelegate goToAppWithDataModel:appDM];
}

-(void)longPressAppView
{
    if(_appDelegate && [_appDelegate respondsToSelector:@selector(longPressAppView)])
        [_appDelegate longPressAppView];
}

-(void)appViewMoving:(KDPersonalAppView *)appView andState:(UIGestureRecognizerState)state
{
    self.currentAppView = appView;
    
    //假如拖动结束
    if(state == UIGestureRecognizerStateEnded)
    {
        self.currentAppView = nil;
        
        if(self.tempAppView)
        {
            [self.tempAppView removeFromSuperview];
            self.tempAppView = nil;
        }
        
        __weak KDPersonAppListView *selfInBlock = self;
        
        [UIView animateWithDuration:0.5 animations:^{
            [selfInBlock.viewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                KDPersonalAppView *view = obj;
                if(idx<selfInBlock.rectArray.count)
                {
                    view.frame = ((NSValue *)(selfInBlock.rectArray[idx])).CGRectValue;
                }
                else
                {
                    NSLog(@"");
                }
            }];
        } completion:^(BOOL finished) {
            
        }];
        
        return;
    }

    
    //上下左右四个点
    CGPoint centerPointUp = CGPointMake(appView.center.x, appView.center.y - appView.frame.size.height/4);
    CGPoint centerPointDown = CGPointMake(appView.center.x, appView.center.y + appView.frame.size.height/4);
    CGPoint centerPointLeft = CGPointMake(appView.center.x - appView.frame.size.width/4, appView.center.y);
    CGPoint centerPointRight = CGPointMake(appView.center.x + appView.frame.size.width/4, appView.center.y);
    
    //假如没有移动过
    if(self.lastFrame.origin.x == 0 && self.lastFrame.origin.y == 0)
        self.lastFrame = appView.frame;
    
    
    //假如处于屏幕上下边缘，需要上下滚动可见区域
    if ([self isPanningNearEdge])
    {
        [self startCountingIfNeed];
        return;
    }
    else if (self.displayLink)
    {
        [self stopCounting];
    }
    
    
    //假如在上一个位置处，那就没必要再显示临时图标了
    if(CGRectContainsPoint(self.lastFrame, centerPointUp)
       ||CGRectContainsPoint(self.lastFrame, centerPointDown)
        ||CGRectContainsPoint(self.lastFrame, centerPointLeft)
        ||CGRectContainsPoint(self.lastFrame, centerPointRight)
                              )
        return;
    
    
    //判断当前处于哪个位置
    __block int currentIndex = -1;
    __weak KDPersonAppListView *selfInBlock = self;
    [self.rectArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = ((NSValue *)obj).CGRectValue;
        if(CGRectContainsPoint(frame, centerPointUp)
           ||CGRectContainsPoint(frame, centerPointDown)
           ||CGRectContainsPoint(frame, centerPointLeft)
           ||CGRectContainsPoint(frame, centerPointRight)
           )
        {
            selfInBlock.lastFrame = frame;
            currentIndex = (int)idx;
            *stop = YES;
        }
    }];
    
    
   
    if(currentIndex!=-1)
    {
//        //先移除旧的临时图标
//        if(self.tempAppView)
//           [self.tempAppView removeFromSuperview];
//        
//        //添加新的临时图标
//        self.tempAppView = [[KDPersonalAppView alloc]initWithAppDataModel:appView.appDM frame:appView.frame delFlag:appView.appDM.delFlag];
//        [self.tempAppView setIsFeatureFuc:appView.appDM.isFeatureFuc];
//        self.tempAppView.alpha = 0.3;
//        [self addSubview:self.tempAppView];
        
        //调整位置
        int appViewIndex = (int)[self.viewArray indexOfObject:appView];
        if(appViewIndex != currentIndex)
        {
           [self.viewArray removeObject:appView];
           [self.viewArray insertObject:appView atIndex:currentIndex];
        }
    }
//    else
//    {
//        //假如不处于任何一个区域就移除临时图标
//        if(self.tempAppView)
//        {
//            [self.tempAppView removeFromSuperview];
//            self.tempAppView = nil;
//        }
//    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
//        //显示临时图标位置
//        if(currentIndex!=-1 && self.tempAppView)
//            self.tempAppView.frame = (((NSValue *)(self.rectArray[currentIndex])).CGRectValue);
        
        [self.viewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            KDPersonalAppView *view = obj;
            //正在拖动的图标不能归位
            if(view != appView)
            {
                if(idx<selfInBlock.rectArray.count)
                {
                    view.frame = ((NSValue *)(selfInBlock.rectArray[idx])).CGRectValue;
                }
                else
                {
                    NSLog(@"");
                }
            }
        }];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setIsEditing:(BOOL)isEditing
{
    if(_isEditing != isEditing)
    {
        _isEditing = isEditing;
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KDAppDataModel *appDM = (KDAppDataModel *)obj;
            appDM.delFlag = isEditing;
            
            KDPersonalAppView *view = _viewArray[idx];
            view.isEditing = isEditing;
        }];
    }
}


-(BOOL)isPanningNearEdge
{
    CGPoint offset = self.contentOffset;
    CGFloat currentY = self.currentAppView.frame.origin.y;
    
    
    if(currentY < offset.y+64+20 && offset.y>-64)
    {
        //上边缘
        return YES;
    }
    else if(CGRectGetMaxY(self.currentAppView.frame) > offset.y+self.bounds.size.height-20 && CGRectGetMaxY(self.currentAppView.frame)<self.contentSize.height)
    {
        //下边缘
        return YES;
    }

    return NO;
}

- (void)startCountingIfNeed {
    if (self.displayLink) {
        return;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollUpOrDown)];
    self.displayLink.frameInterval = 3;  // 1秒60帧，3帧为1/20秒
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopCounting {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)scrollUpOrDown {
    if (![self isPanningNearEdge]) {
        [self stopCounting];
        return;
    }
    
    CGPoint offset = self.contentOffset;
    CGFloat currentY = self.currentAppView.frame.origin.y;
    
    if(currentY < offset.y+64+20 && offset.y>-64)
    {
        //下滑
        CGRect appViewFrame = self.currentAppView.frame;
        offset.y = MAX(-64, offset.y-20);
        appViewFrame.origin.y = MAX(0, appViewFrame.origin.y-20);
        [UIView animateWithDuration:0.1 animations:^{
            [self setContentOffset:offset];
            //self.currentAppView.frame = appViewFrame;
        }];
    }
    else if(CGRectGetMaxY(self.currentAppView.frame) > offset.y+self.bounds.size.height-20 && CGRectGetMaxY(self.currentAppView.frame)<self.contentSize.height)
    {
        //上滑
        CGRect appViewFrame = self.currentAppView.frame;
        offset.y = MIN(self.contentSize.height-self.bounds.size.height, offset.y+20);
        appViewFrame.origin.y = MIN(self.contentSize.height-self.currentAppView.frame.size.height, appViewFrame.origin.y+20);
        [UIView animateWithDuration:0.1 animations:^{
            [self setContentOffset:offset];
            //self.currentAppView.frame = appViewFrame;
        }];
    }
    
}

-(NSMutableArray *)getSortDataArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.viewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KDPersonalAppView *view = obj;
        [array addObject:view.appDM];
    }];
    
    return array;
}

-(NSMutableArray *)getSortAppIdsArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.viewArray.count];
    [self.viewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDPersonalAppView *view = (KDPersonalAppView *)obj;
        if(view.appDM.appType == KDAppTypePublic)
        {
            if(view.appDM.pid)
                [array addObject:view.appDM.pid];
        }
        else
        {
            if(view.appDM.appClientID)
            {
                NSString *appID = [view.appDM.appClientID substringToIndex:[view.appDM.appClientID length] - 2];
                [array addObject:appID];
            }
        }
    }];
    return array;
}

@end
