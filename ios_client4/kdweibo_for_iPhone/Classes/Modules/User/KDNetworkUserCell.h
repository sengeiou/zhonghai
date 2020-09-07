//
//  NetworkUserCell.h
//  TwitterFon
//
//  Created by apple on 10-11-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDNetworkUserBaseCell.h"


@interface KDNetworkUserCell : KDNetworkUserBaseCell {
@private
	UILabel *statusLabel_;
    
    UIImageView *cellAccessoryImageView_;
}

@end
