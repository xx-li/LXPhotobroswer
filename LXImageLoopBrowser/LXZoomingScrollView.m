//
//  CustomScrollView.m
//
//  Created by 李新星 on 13-3-4.
//  Copyright (c) 2013年 xx-li. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "LXZoomingScrollView.h"
#import "LXCircularProgressView.h"
#import "UIImageView+WebCache.h"


@interface LXZoomingScrollView ()

@property (strong, nonatomic)  UIImageView * imageView;
@property (strong, nonatomic) LXCircularProgressView * progressView;
@property (strong, nonatomic) UITapGestureRecognizer * photoDoubleTap;     //双击手势


@end

@implementation LXZoomingScrollView

#pragma mark - Life cycle
- (void)dealloc
{
    [_imageView sd_cancelCurrentImageLoad];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        _imageContentMode = UIViewContentModeScaleAspectFit;
        self.zoomEnabled = YES;
        self.clipsToBounds = YES;
		// 图片
		_imageView = [[UIImageView alloc] init];
        
        //图片比例不变，而且全部显示
		_imageView.contentMode = _imageContentMode;
        _imageView.center = self.center;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_imageView];
        
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0],
                               ]];
        
		// 属性
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
        //设置手指放开后的减速率
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        //点击手势识别后不将事件分发给其他UI
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTouchesRequired  = 1;

        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        _photoDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _photoDoubleTap.numberOfTapsRequired = 2;
        _photoDoubleTap.numberOfTouchesRequired  = 1;
        [self addGestureRecognizer:_photoDoubleTap];
        self.zoomEnabled = YES;
        
        [singleTap requireGestureRecognizerToFail:_photoDoubleTap];
        

    }
    return self;
}

#pragma mark - Setter and getter
- (LXCircularProgressView *)progressView {
    
    if (!_progressView) {
        _progressView = [[LXCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _progressView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
        _progressView.progress = 0;
        _progressView.hidesWhenStopped = YES;
        [_progressView stopAnimating];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30.0],
                               [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]
                               ]];
        [self bringSubviewToFront:_progressView];

    }
    
    return _progressView;
}

- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
    
    if (_imageContentMode == imageContentMode) {
        return;
    }
    
    _imageContentMode = imageContentMode;
    self.imageView.contentMode = _imageContentMode;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    if (_zoomEnabled == zoomEnabled) {
        return;
    }
    _zoomEnabled = zoomEnabled;
    _photoDoubleTap.enabled = _zoomEnabled;
    if (self.zooming) {
        self.zoomScale = 1.0f;
    }
}

-(UIImage *)currentImage {
    return _imageView.image;
}

#pragma mark - Public method
- (void)lx_setImageWithURL:(NSURL *)url {
    
    [self lx_setImageWithURL:url placeholderImage:nil];
    
}

- (void)lx_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self lx_setImageWithURL:url placeholderImage:placeholder errorImage:nil];
}

- (void) lx_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage errorImage:(UIImage *)errorImage {
    
    _photoDoubleTap.enabled = NO;
    self.zoomScale = 1;
    
    
    self.progressView.progress = 0;
    [self.progressView startAnimating];
    
    _imageView.image = placeholderImage;
    
    __weak __typeof(self)weakSelf = self;
    [_imageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageLowPriority |SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //接收到数据才设定进度
        if (receivedSize > 0) {
            strongSelf.progressView.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf.progressView stopAnimating];
        
        if (!error) {
            strongSelf.imageView.image = image;
        }
        else {
            if (errorImage) {
                strongSelf.imageView.image = errorImage;
            } else {
                strongSelf.imageView.image = placeholderImage;
            }
        }
        
        strongSelf.photoDoubleTap.enabled = _zoomEnabled;
        
        [strongSelf adjustCurrentZoomScale];

    }];
}


#pragma mark - Private method
#pragma mark 调整frame
- (void)adjustCurrentZoomScale
{
	if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
//	// 设置最小伸缩比例   TODO 在最小伸缩小于1的情况下，_imageView不居中，暂最小伸缩比例默认设定为1
//    CGFloat minScale = boundsWidth / imageWidth;
//    CGFloat heighScale = boundsHeight / imageHeight;
//	if (minScale > 1) {
//		minScale = 1;
//	}
    
    CGFloat maxWidthScale = imageWidth / boundsWidth;
    CGFloat maxHeightScale = imageHeight / boundsHeight;
    
    CGFloat maxScale = maxWidthScale > maxHeightScale ? maxWidthScale : maxHeightScale;
    if (maxScale < 1) {
        maxScale = 1;
    }

	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = 1;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (_zoomEnabled) {
        return _imageView;
    }
    else {
        return nil;
    }
}

#pragma mark - Event response
#pragma mark 单击手势
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    if ([_tapDelegate respondsToSelector:@selector(zoomingScrollViewSingleTap:)]) {
        [_tapDelegate performSelector:@selector(zoomingScrollViewSingleTap:) withObject:self];
    }
}


#pragma mark 双击手势
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
        CGPoint touchPoint = [tap locationInView:_imageView];
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, self.maximumZoomScale, self.maximumZoomScale) animated:YES];
	}
    
    
}

@end