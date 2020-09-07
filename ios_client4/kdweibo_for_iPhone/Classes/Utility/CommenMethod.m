//
//  CommenMethod.m
//  TwitterFon
//
//  Created by apple on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "CommenMethod.h"

#import "ProfileViewController.h"
#import "KDDefaultViewControllerContext.h"


#define CHECK_VESION_FINISH_NOTIFICATION_NAME @"CHECK_VESION_FINISH_NOTIFICATION_NAME"

#define KD_LOGIN_USER_DOWNLOAD_DATA_NOTIFY_NAME @"KD_LOGIN_USER_DOWNLOAD_DATA_NOTIFY_NAME"


@implementation CommenMethod

+(id)getMainViewFromNib:(Class)classClass owner:(id)owner
{
    NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(classClass) owner:nil options:nil];
    if (nibArr!=nil && [nibArr count] != 0) {
        return     [nibArr objectAtIndex:0];
    }
    return  nil;
}

//get string seperad by coma
+(NSString *)getStringSeperaByCommaWithStrArr:(NSArray *)stringArr
{
	NSMutableString *varListString=[NSMutableString string];
	for (int i = 0; i < [stringArr count]; i++) {
		if (i!=0) {
			[varListString appendString:@","];
		}
		[varListString appendString:[stringArr objectAtIndex:i]];
		
	}
    
	return varListString;
}

//get the heigh of lab when it chang it's size enough to show the text 
+(CGFloat)getHeightByLableWithMaxHeight:(CGFloat)height
                                  lable:(UILabel *)lable
{
    CGRect maxFrame = lable.frame;
    maxFrame.size.height = height;
	CGRect frame=[lable textRectForBounds:maxFrame
                   limitedToNumberOfLines:lable.numberOfLines];
    return frame.size.height;
}

//these method get string that limit by line,width,font,height in dURL
+(BOOL)isSmallThanMaxHeight:(NSString *)text
                       line:(NSInteger)line
                   fontSize:(CGFloat)fontSize
                      width:(CGFloat)width
{
    UIFont *textFon = [UIFont systemFontOfSize:fontSize];
    CGSize lineLabSize = [@" "sizeWithFont:textFon];
    CGFloat lineHeight = lineLabSize.height;    
    CGSize testTextSize = [text sizeWithFont:textFon constrainedToSize:CGSizeMake(width, lineHeight*line*2) lineBreakMode:NSLineBreakByCharWrapping];
    if (testTextSize.height<=lineHeight*line) {
        return YES;
    }
    else {
        return NO;
    }
}
//these method get string that limit by line,width,font,height in dURL
+(NSString *)getTheRightStringWithOringString:(NSString*)originString
                                         line:(NSInteger)line
                                     fontSize:(CGFloat)fontSize
                                        width:(float)width
                                 isFirstCheck:(BOOL)isFirstCheck
{
    if (isFirstCheck) {
        BOOL isSmallFirst = [CommenMethod isSmallThanMaxHeight:originString line:line fontSize:fontSize width:width];
        if (isSmallFirst) {
            return [NSString stringWithFormat:@"%@",originString];
        }
    }
    NSString *testString = [originString substringToIndex:[originString length] - 1];
    NSString *testStringWithAddC = [NSString stringWithFormat:@"%@...",testString];
    BOOL isSmall = [CommenMethod isSmallThanMaxHeight:testStringWithAddC line:line fontSize:fontSize width:width];
    
    if (isSmall) {
        return testStringWithAddC;
    }
    else {
        return [CommenMethod getTheRightStringWithOringString:testString
                                                         line:line 
                                                     fontSize:fontSize
                                                        width:width
                                                 isFirstCheck:NO];
    }
}

+ (void)jumToProfileViewControllerWithUserName:(NSString *)userName
{
    if (userName == nil) {
        return;
    }
    
    __block KDUser *target = nil;
    [KDUser syncUserWithName:userName completionBlock:^(KDUser *user){
        target = user;
    }];
    
    ProfileViewController *pvc = nil;
    if (target != nil) {
        pvc = [[ProfileViewController alloc] initWithUser:target] ;//autorelease];
    
    } else {
        pvc = [[ProfileViewController alloc] initWithUserName:userName];// autorelease];
    }

    UIViewController *tvc = [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController];
    [tvc.navigationController pushViewController:pvc animated:true];
}


+ (void)addCheckVesionFinishNotification:(id)taget
                                 action:(SEL)action
{
    [[NSNotificationCenter defaultCenter] addObserver:taget selector:action name:CHECK_VESION_FINISH_NOTIFICATION_NAME object:nil];
}

+ (void)removeCheckVesionFinishNotification:(id)taget
{
    [[NSNotificationCenter defaultCenter] removeObserver:taget name:CHECK_VESION_FINISH_NOTIFICATION_NAME object:nil];
}

+ (void)postCheckVesionFinishNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_VESION_FINISH_NOTIFICATION_NAME object:nil];
}

@end
