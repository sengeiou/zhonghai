//
//  SingleLineScaleLab.h
//  TwitterFon
//
//  Created by Guohuan Xu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
@protocol SingleLineScaleLabDelegate;
@interface SingleLineScaleLab : UILabel
{
//    id<SingleLineScaleLabDelegate>delegate_;
}
@property(assign,nonatomic)    id<SingleLineScaleLabDelegate>delegate_;

@end

@protocol SingleLineScaleLabDelegate
@optional
-(void)singleLineScaleLab:(SingleLineScaleLab *)singleLineScaleLab
                textWidth:(CGFloat)textWidth;
@end