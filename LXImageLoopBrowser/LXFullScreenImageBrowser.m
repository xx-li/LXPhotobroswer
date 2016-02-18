//
//  LXSocialImageBrowser.m
//  LXPhotobroswerDemo
//
//  Created by 李新星 on 15/7/3.
//  Copyright (c) 2014年 xx-li. All rights reserved.
//

#import "LXFullScreenImageBrowser.h"

@interface LXFullScreenImageBrowser()

@property (strong, nonatomic) UIImageView * tempImageView;

@end

@implementation LXFullScreenImageBrowser

#pragma mark - Setter and getter
- (UIImageView *)tempImageView {
    if (!_tempImageView) {
        UIImageView *tempView = [[UIImageView alloc] initWithFrame:self.bounds];
        tempView.contentMode = [self.currentPhotoView imageContentMode];
    }
    return _tempImageView;
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
}

- (void) dismiss {
    
    UIImage * placeholderImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:self.currentIndex];
    
    [self addSubview:self.tempImageView];
    self.tempImageView.image = placeholderImage;
    
    self.scrollView.hidden = YES;
    
    CGRect targetTemp =  [self.fullScreenDelegate imageLoopBrowser:self startRectForIndex:self.currentIndex];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.tempImageView.frame = targetTemp;
        
    } completion:^(BOOL finished) {
        [self.tempImageView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)startFirstShow
{
    self.scrollView.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
    CGRect rect = [self.fullScreenDelegate imageLoopBrowser:self startRectForIndex:self.currentIndex];;
    UIImage * placeholderImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:self.currentIndex];
    //TODO:设定图片放到addSubview之后，图片特殊时，在UIViewContentModeScaleAspectFit等contentMode下图片会加载异常，原因不明；
    self.tempImageView.frame = rect;
    self.tempImageView.image = placeholderImage;
    [self addSubview:self.tempImageView];


    [UIView animateWithDuration:0.3 animations:^{
        self.tempImageView.center = self.center;
        self.tempImageView.bounds = self.bounds;
        self.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self.tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}


- (void) didMoveToWindow {
    [super didMoveToWindow];
    [self startFirstShow];
    
}

@end
