//
//  ChatBubbleCell.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "KDCommon.h"
#import "ChatBubbleCell.h"

#import "KDWeiboAppDelegate.h"

#import "KDCache.h"

@interface ChatBubbleCell ()

@property (nonatomic, retain) ChatBubbleView *detailsView;

@end


@implementation ChatBubbleCell

@synthesize message=message_;

@dynamic avatarView;

@synthesize detailsView=detailsView_;

@synthesize delegate = delegate_;


- (void) setupChatBubbleCell {
    detailsView_ = [[ChatBubbleView alloc] initWithFrame:CGRectZero cell:self];
    [super.contentView addSubview:detailsView_];
} 

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){

        [self setupChatBubbleCell];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    detailsView_.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}

- (void) setMessage:(id<ChatBubbleCellDataSource>)message {
    if(message_ != message){
//        [message_ removeObserver:self forKeyPath:@"messageState"];
//        [message_ removeObserver:self forKeyPath:@"compositeImageSource"];
//        [message_ release];
        message_ = message;// retain];
//        [message addObserver:self forKeyPath:@"compositeImageSource" options:NSKeyValueObservingOptionNew context:NULL];
//        [message_ addObserver:self forKeyPath:@"messageState" options:NSKeyValueObservingOptionNew context:NULL];
        [detailsView_ refresh];
       
    }
}

- (KDUserAvatarView *)avatarView {
    return detailsView_.avatarView;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"messageState"]) {
        [self.detailsView determinUploading];
        //[self loadAudio];
    }else if([keyPath isEqualToString:@"compositeImageSource"]) {
        KDCompositeImageSource *cis = [change objectForKey:NSKeyValueChangeNewKey];
        if(cis && ![cis isKindOfClass:[NSNull class]]) {
            [self.detailsView.thumbnailView setImageDataSource:cis];
            [self.detailsView.thumbnailView setLoadThumbnail:YES];
        }
    }
}

#define KD_DM_CONTENT_HEIGHT   @"dm_content_height"
#define KD_DM_CONTENT_SIZE     @"dm_content_size"

+ (CGSize) directMessageSizeInCell:(id<ChatBubbleCellDataSource>)message {
    NSValue *sizeValue = [message propertyForKey:KD_DM_CONTENT_SIZE];
    return [sizeValue CGSizeValue];
}

+ (CGFloat) directMessageHeightInCell:(id<ChatBubbleCellDataSource> )message interval:(int)diff {
    if ([message hasLocationInfo]) {
        [message setProperty:[NSValue valueWithCGSize:CGSizeMake(200.0f, 203.0f)] forKey:KD_DM_CONTENT_SIZE];
        BOOL showCreationTime = (diff > CHAT_BUBBLE_TIMESTAMP_DIFF || diff == -1);
        
        if(showCreationTime) {
            [message setProperty:@(YES) forKey:@"kddmmessage_is_need_stamp"];
            return 305.0f + 23.0f;
        }else {
            return 265.0f + 23.0f;
        }
    }
    
    CGFloat height = 0.0;
    NSNumber *obj = [message propertyForKey:KD_DM_CONTENT_HEIGHT];
    
    if (obj == nil) {
        BOOL showCreationTime = (diff > CHAT_BUBBLE_TIMESTAMP_DIFF || diff == -1);
        
        NSString *textBody = message.message;
        CGFloat width, fontSize;
        if (message.isSystemMessage) {
            width = 200.0;
            fontSize = KD_DM_SYSTEM_MESSAGE_FONT_SIZE;
            
            if (showCreationTime) {
                // combine the creation time to system message body,
                // then the creation time and system message can show in same UILabel.
                // please change it in the future.
                textBody = [NSString stringWithFormat:@"%@\n%@", message.timestamp, textBody];
            
                // cache text body
                [message setProperty:textBody forKey:KD_DM_MESSAGE_TEXT_BODY];
            }
            
        } else {
            width = CHAT_BUBBLE_TEXT_WIDTH;
            fontSize = KD_DM_MESSAGE_FONT_SIZE;
        }
        
        CGSize size = [KDExpressionLabel sizeWithString:textBody constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) withType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:fontSize]];
        
        if (message.isSystemMessage) {
//            size.width = [textBody sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].width;
//            if (size.width + 6.0 < width) {
//                size.width += 6.0;
//            }
//
            size = [textBody sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
            
            size.width += 6.0f;
            
            size.height += 6.0;

        }
        
        [message setProperty:[NSValue valueWithCGSize:size] forKey:KD_DM_CONTENT_SIZE];
        
        //文字框的大小
        if(message.compositeImageSource.imageSources.count == 1 && [message.message isEqualToString:NSLocalizedString(@"SHARE_PHOTO", @"")]) {
            height = 0;
        }else {
            height = size.height;
        }
        
        height += message.isSystemMessage ? 10.0 : 20.0;
        
        if (showCreationTime && !message.isSystemMessage) {
            [message setProperty:@(YES) forKey:@"kddmmessage_is_need_stamp"];
            height += 40;
        } else {
            [message setProperty:@(NO) forKey:@"kddmmessage_is_need_stamp"];
            height += 5;
        }
        
        if ([message hasVideo]) {
            
            if ([message.compositeImageSource.imageSources count]==1) {
                height += [KDThumbnailView2 thumbnailSizeWithImageDataSource:message.compositeImageSource showAll:YES].height + 8.0f;
            }
        }
        else
        {
            if(message.compositeImageSource != nil && [message.compositeImageSource hasImageSource]){
                height += [KDThumbnailView thumbnailSizeWithImageDataSource:message.compositeImageSource].height + 8.0;
            }
            
            if(message.attachments != nil && [message.attachments count] > 0){
                height += [ChatBubbleView dmAttachmentsIndicatorButtonHeight];
            }

        }
        
  
        
        height += 20.0;
        
        //height for name
        height += 20.0f;
        
        obj = [NSNumber numberWithFloat:height];
        [message setProperty:obj forKey:KD_DM_CONTENT_HEIGHT];
        
    } else {
        height = [obj floatValue];
    }
    
    return height;
}

- (void)sendWarnningMessage {
    if(delegate_ && [delegate_ respondsToSelector:@selector(didTapWarnningImageInChatBubbleCell:)]) {
        [delegate_ didTapWarnningImageInChatBubbleCell:self];
    }
}


- (void)dealloc {
//    [message_ removeObserver:self forKeyPath:@"messageState"];
//    [message_ removeObserver:self forKeyPath:@"compositeImageSource"];
    //KD_RELEASE_SAFELY(message_);
    //KD_RELEASE_SAFELY(detailsView_);
    
    
    //[super dealloc];
}

@end
