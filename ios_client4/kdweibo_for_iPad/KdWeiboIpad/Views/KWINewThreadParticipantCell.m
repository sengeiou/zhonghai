//
//  KWINewThreadParticipantCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWINewThreadParticipantCell.h"

#import "KDUser.h"
#import "KWIAvatarV.h"

@implementation KWINewThreadParticipantCell
{
    IBOutlet UIView *_avatarPhV;    
    IBOutlet UILabel *_nameV;
    IBOutlet UIButton *_checkBtn;
    
    BOOL _isFakeSelected;
}

@synthesize user = _user;

+ (KWINewThreadParticipantCell *)cellForUser:(KDUser *)user
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWINewThreadParticipantCell *cell = (KWINewThreadParticipantCell *)[nib objectAtIndex:0];
    
    return [cell initWithUser:user];
}

- (id)initWithUser:(KDUser *)user
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(self) {
        self.user = user;
        
        KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:user.profileImageUrl size:48];
        [avatarV replacePlaceHolder:_avatarPhV];
        
        _nameV.text = user.username;
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapped:)] autorelease];
        [self addGestureRecognizer:tgr];
        
    }
    return self;
}

- (void)dealloc {
    [_avatarPhV release];
    [_nameV release];
    [_checkBtn release];
    [super dealloc];
}

/*- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    _checkBtn.selected = selected;
    
    NSString *event = selected?@"KWINewThreadParticipantCell.selected":@"KWINewThreadParticipantCell.deselected";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:event 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.user forKey:@"user"]];
}*/

- (void)_onTapped:(UITapGestureRecognizer *)tgr
{
    [self _setFakeSelected:!_isFakeSelected];
}

- (void)_setFakeSelected:(BOOL)selected
{
    //_isFakeSelected = selected;
    _checkBtn.selected = _isFakeSelected = selected;
    
    NSString *event = selected?@"KWINewThreadParticipantCell.selected":@"KWINewThreadParticipantCell.deselected";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:event 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.user forKey:@"user"]];
}

// use to change looking
- (void)setFakeSelected
{
    _checkBtn.selected = _isFakeSelected = YES;
}

@end
