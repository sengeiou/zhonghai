//
//  DSURLView.h
//  urltextview
//
//  Created by duansong on 10-10-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSURLLabel.h"

@protocol DSURLViewDelegate;

@interface DSURLView : UIView <DSURLLabelDelegate>{
	NSString					*_sourceText;
	CGFloat						_frameWidth;
	CGFloat						_frameOriginX;
	CGFloat						_frameOriginY;
	CGFloat                       FontSize;
	BOOL						_needNewLine;
//	id<DSURLViewDelegate>		_delegate;
}

@property (nonatomic, copy)		NSString				*sourceText;
@property (nonatomic, assign)	CGFloat					frameWidth;
@property (nonatomic, assign)	CGFloat					frameOriginX;
@property (nonatomic, assign)	CGFloat					frameOriginY;
@property (nonatomic, assign)	CGFloat					FontSize;
@property (nonatomic, assign)	id<DSURLViewDelegate>	delegate;

-(NSUInteger)min:(NSUInteger)location1 number2:(NSUInteger)location2; 

/*
 作用：将一段文本根据url拆分出几个字符串存放在一个数组中，比如：xxxhttp://abc.com xxxxxx 拆分成xxx；http://abc.com；xxxxxx；3个字符串存放在数组中 
 参数：source，源文本
 返回：拆分的子字符串
 */

- (NSMutableArray *)splitStringByUrl:(NSString *)source;
- (NSMutableArray *)splitStringByName:(NSString *)source;
//url,user,topic拆分
- (NSMutableArray *)splitStringByAll:(NSString *)source;
- (NSMutableArray *)splitElementArraybyTopic:(NSMutableArray *)array;
- (NSMutableArray *)splitElementArraybyUser:(NSMutableArray *)array;
/*
 作用：根据一个给定的宽度拆分字符串，如果字符串的宽度小于等于给定的宽度，返回数组只有一个source字符串元素，否则返回拆分的两个子字符串
 */

- (NSMutableArray *)splitStringBylimitWidth:(CGFloat)width source:(NSString *)source;

/*
 作用：找到一个字符串在label中的最后一个行显示的部分的子字符串在原字符串中的起点位置。比如一个字符串为“123456789abcdefghijk”,
 经过换行后在一个label中换成两行，最后一行显示“hijk”，则这个函数返回h在字符串中的index，值为16，根据这个index可以取出字符串“hijk”。
 */

- (NSInteger)findStartIndexOfLastLineText:(NSString *)source;

/*
 返回字符串的size
 */

- (CGSize)sizeForString:(NSString *)string;

/*
 返回给定字体的字符所站的高度
 */
- (CGFloat)getHeightWithFontSize:(CGFloat)fontSize;

/*
 根据拆分出的字符串布局URLView视图
 */

- (void)layoutURLViewWithElements:(NSMutableArray *)elements;

/*
 设置URLView视图的Frame
 */
- (void)setFrame;

/*
 根据url找出url相同的URLLabel，并设置颜色
 */

- (void)setUrlLabelTextColorWithUrlString:(NSString *)url color:(UIColor *)color;

@end


@protocol DSURLViewDelegate

@optional

- (void)urlWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString;
- (void)userWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString;
- (void)topicWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString;
//其他区域点击
- (void)viewTouchesBegan:(DSURLView*)view;
- (void)viewTouchesEnded:(DSURLView*)view;
- (void)viewTouchesMove:(DSURLView *)view;
- (void)viewTouchesCancle:(DSURLView *)view;

@end

