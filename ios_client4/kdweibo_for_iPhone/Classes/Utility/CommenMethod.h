//
//  CommenMethod.h
//  TwitterFon
//
//  Created by apple on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommenMethod : NSObject 

+(id)getMainViewFromNib:(Class)classClass owner:(id)owner;

+(NSString *)getStringSeperaByCommaWithStrArr:(NSArray *)stringArr;

//get the heigh of lab when it chang it's size enough to show the text 
+(CGFloat)getHeightByLableWithMaxHeight:(CGFloat)height
                                  lable:(UILabel *)lable;

//these method get string that limit by line,width,font,height in dURL
+(NSString *)getTheRightStringWithOringString:(NSString*)originString
                                         line:(NSInteger)line
                                     fontSize:(CGFloat)fontSize
                                        width:(float)width
                                 isFirstCheck:(BOOL)isFirstCheck;


+ (void)jumToProfileViewControllerWithUserName:(NSString *)userName;



+ (void)addCheckVesionFinishNotification:(id)taget
                                  action:(SEL)action;

+ (void)removeCheckVesionFinishNotification:(id)taget;

+ (void)postCheckVesionFinishNotification;

@end


