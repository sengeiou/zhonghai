//
//  KDTimelineSectionItem.h
//  kdweibo
//
//  Created by kyle on 2016/11/30.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//----------------banner---------------//
typedef NS_ENUM(NSInteger, KDTimelineSectionType){
    KDTimelineSectionNetwork = 0,   //无网
    KDTimelineSectionVoice = 1,     //
    KDTimelineSectionTrust = 2,     //
    KDTimelineSectionAds = 3,       //
    KDTimelineSectionPeople = 4,    //
    KDTimelineSectionRelation = 5,   //
    KDTimelineSectionGroupList
};

@interface KDTimelineSectionItem : NSObject

@property (nonatomic, assign) KDTimelineSectionType sectionType;



@end
