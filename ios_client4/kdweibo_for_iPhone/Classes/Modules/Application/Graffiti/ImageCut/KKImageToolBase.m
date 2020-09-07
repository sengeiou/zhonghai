//
//  KKImageToolBase.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKImageToolBase.h"

@implementation KKImageToolBase


- (id)initWithImageEditor:(KDImageEditorViewController*)editor {
    self = [super init];
    if(self){
        self.editor   = editor;
    }
    return self;
}

- (void)setup
{
    
}

- (void)cleanup
{
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}

@end
