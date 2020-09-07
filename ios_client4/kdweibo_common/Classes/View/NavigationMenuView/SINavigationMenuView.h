//
//  SINavigationMenuView.h
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIMenuTable.h"
#import "SIMenuButton.h"

@protocol SINavigationMenuDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSUInteger)index;

@end

@interface SINavigationMenuView : UIView <SIMenuDelegate>
{
    NSArray *_items;
}
@property (nonatomic, assign) id <SINavigationMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) SIMenuButton *menuButton;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)displayMenuInView:(UIView *)view;

@end
