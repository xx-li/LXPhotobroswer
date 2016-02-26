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
@property (assign, nonatomic) BOOL isShow;
@property (strong, nonatomic) UIView * curOriginView;

@end

@implementation LXFullScreenImageBrowser

#pragma mark - Setter and getter
- (UIImageView *)tempImageView {
    if (!_tempImageView) {
        UIImageView *tempView = [[UIImageView alloc] initWithFrame:self.bounds];
        tempView.clipsToBounds = YES;
        tempView.contentMode = [self.currentPhotoView imageContentMode];
        _tempImageView = tempView;
    }
    return _tempImageView;
}

- (void)show
{
    _originContentMode = UIViewContentModeScaleAspectFill;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
}

- (void) dismiss {
    
    self.curOriginView = [self.fullScreenDelegate imageLoopBrowser:self originViewForIndex:self.currentIndex];
    
    UIImage * placeholderImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:self.currentIndex];
    [self addSubview:self.tempImageView];
    self.tempImageView.image = placeholderImage;
    
    self.tempImageView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.scrollView.hidden = YES;
    
    CGRect originRect =  [self.fullScreenDelegate imageLoopBrowser:self startRectForIndex:self.currentIndex];
    CGFloat durtion = 0.15;
    [self performSelector:@selector(reset) withObject:nil afterDelay:durtion];
    
    [UIView animateWithDuration:durtion + 0.1 animations:^{
        self.tempImageView.frame = originRect;
    } completion:^(BOOL finished) {
        [self.tempImageView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)startFirstShow
{
    self.scrollView.hidden = YES;
    self.backgroundColor = [UIColor blackColor];
    
    CGRect originRect = [self.fullScreenDelegate imageLoopBrowser:self startRectForIndex:self.currentIndex];;
    UIImage * placeholderImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:self.currentIndex];
    
    //TODO:设定图片放到addSubview之后，图片特殊时，在UIViewContentModeScaleAspectFit等contentMode下图片会加载异常，原因不明；
    self.tempImageView.frame = originRect;
    [self addSubview:self.tempImageView];
    self.tempImageView.image = placeholderImage;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tempImageView.center = self.center;
        self.tempImageView.frame = self.bounds;
        self.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self.tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

- (void) reset {
    self.tempImageView.image = [self capture:self.curOriginView];
    self.tempImageView.contentMode = self.originContentMode;
}

#pragma mark 截图
- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) didMoveToWindow {
    [super didMoveToWindow];
    //防止调用多次
    if (!_isShow) {
        [self startFirstShow];
        _isShow = YES;
    }
}

@end
