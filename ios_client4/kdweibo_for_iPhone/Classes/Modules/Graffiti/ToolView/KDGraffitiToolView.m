//
//  KDGraffitiToolView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDGraffitiToolView.h"

@interface KDGraffitiToolView()

@end

@implementation KDGraffitiToolView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.1];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [self addSubview:self.drawBtn];
    [self addSubview:self.textBtn];
    [self addSubview:self.cutBtn];
    [self addSubview:self.sendBtn];
    
}

#pragma mark - action
- (void)clickDraw {
    if (self.delegate && [self.delegate respondsToSelector:@selector(choosePencil)]) {
        [self.delegate choosePencil];
    }
}

- (void)clickText {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseText)]) {
        [self.delegate chooseText];
    }
}

- (void)clickCut {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseCut)]) {
        [self.delegate chooseCut];
    }
}

- (void)clickSend {
    if (self.delegate && [self.delegate respondsToSelector:@selector(send)]) {
        [self.delegate send];
    }
}

#pragma mark - lazy load
- (UIButton *)drawBtn {
    if (!_drawBtn) {
        _drawBtn = [[UIButton alloc] initWithFrame:CGRectMake(12, 8, 26, 26)];
        [_drawBtn setImage:[UIImage imageNamed:@"graffiti_draw"] forState:UIControlStateNormal];
        [_drawBtn setImage:[UIImage imageNamed:@"graffiti_draw_selected"] forState:UIControlStateSelected];
        [_drawBtn addTarget:self action:@selector(clickDraw) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _drawBtn;
}
- (UIButton *)textBtn {
    if (!_textBtn) {
        _textBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 8, 26, 26)];
        [_textBtn setImage:[UIImage imageNamed:@"graffiti_text"] forState:UIControlStateNormal];
        [_textBtn setImage:[UIImage imageNamed:@"graffiti_text_selected"] forState:UIControlStateSelected];
        [_textBtn setImage:[UIImage imageNamed:@"graffiti_text_selected"] forState:UIControlStateHighlighted];
        [_textBtn addTarget:self action:@selector(clickText) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _textBtn;
}
- (UIButton *)cutBtn {
    if (!_cutBtn) {
        _cutBtn = [[UIButton alloc] initWithFrame:CGRectMake(88, 8, 26, 26)];
        [_cutBtn setImage:[UIImage imageNamed:@"graffiti_cut"] forState:UIControlStateNormal];
        [_cutBtn setImage:[UIImage imageNamed:@"graffiti_cut_selected"] forState:UIControlStateSelected];
        [_cutBtn setImage:[UIImage imageNamed:@"graffiti_cut_selected"] forState:UIControlStateHighlighted];
        [_cutBtn addTarget:self action:@selector(clickCut) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cutBtn;
}
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"Global_Send")];
        _sendBtn.frame = CGRectMake(self.frame.size.width - 12 - 75, 8, 75, 26);
        [_sendBtn addTarget:self action:@selector(clickSend) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendBtn;
}

@end
