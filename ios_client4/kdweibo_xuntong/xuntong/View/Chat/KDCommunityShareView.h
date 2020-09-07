//
//  KDCommunityShareView.h
//  kdweibo
//
//  Created by AlanWong on 14-7-29.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageFileDataModel;

@class MessageNewsEachDataModel;

typedef enum KDCommunityShareType{
    KDCommunityShareTypeText = 0,
    KDCommunityShareTypeImage,
    KDCommunityShareTypeFile,
    KDCommunityShareTypeNew
}KDCommunityShareType;

typedef enum KDCommunityShareButtonIndex{
    KDCommunityShareButtonCancel = 0,
    KDCommunityShareButtonConfirm
}KDCommunityShareButtonIndex;

@protocol KDCommunityShareViewDelegate <NSObject>
-(void)shareViewDidSelectButtonAtIndex:(KDCommunityShareButtonIndex)buttonindex;
@end

@interface KDCommunityShareView : UIView
@property(nonatomic,assign)BOOL isForIPhone5;
@property(nonatomic, weak)id<KDCommunityShareViewDelegate> delegate;
@property(nonatomic, assign)KDCommunityShareType type;
//分享文本需要赋值的属性
@property(nonatomic, strong)NSString * contentText;
//分享图片需要赋值的属性
@property(nonatomic, strong)NSString * imagePath;  //缓存路径
//分享新闻需要赋值的属性
@property(nonatomic, strong)MessageNewsEachDataModel * theNewDataMedel;
//分享文件赋值的属性
@property(nonatomic, strong)MessageFileDataModel * fileDataModel;
@property(nonatomic, copy)NSString * personUrl; // url地址



-(void)setFileImageByExtName:(NSString *)extName;
-(id)initWithFrame:(CGRect)frame type:(KDCommunityShareType)type isForIPhone5:(BOOL)isForIPhone5;
-(void)becomeFirstResponderShareView;
-(void)resignFirstResponderShareView;
@end
