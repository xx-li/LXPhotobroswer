//
//  LXCircularProgressView.m
//  SDWebImageViewProgress
//
//  Created by 李新星 on 14-2-23.
//  Copyright (c) 2014年 xx-li. All rights reserved.
//

#import "LXCircularProgressView.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

@interface LXCircularProgressView() {
    CAShapeLayer *_trackBgLayer;    //背景圆环图形
    UIBezierPath *_trackBgPath;     //背景图形路径
    CAShapeLayer *_trackLayer;      //圆环图像
    UIBezierPath *_trackPath;       //圆环路径
}

/**
 *  用于显示百分比
 */
@property (strong, nonatomic) UILabel * progressLabel;

/**
 *  百分比显示格式
 */
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

/**
 *  当前是否处于动画状态
 */
@property (assign) BOOL isAnimationing;

@end


@implementation LXCircularProgressView

#pragma mark - Life cycle
//初始化
- (id)initWithFrame:(CGRect)frame
       trackBgColor:(UIColor *)trackBgColor
         trackColor:(UIColor *)trackColor
       annulusWidth:(CGFloat)annulusWidth
     annulusPercent:(CGFloat)annulusPercent {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //默认设为yes
        self.hidesWhenStopped = YES;
        _isAnimationing = YES;
        
        //默认为1秒
        _animatDuration = 1;
        
        //设定形状layer
        _trackBgLayer = [CAShapeLayer new];
        _trackBgLayer.fillColor = nil;
        _trackBgLayer.frame = self.bounds;
        
        //设定进度layer
        _trackLayer = [CAShapeLayer new];
        _trackLayer.fillColor = nil;
        _trackLayer.lineCap = kCALineCapRound; //线头有圆角
        _trackLayer.frame = self.bounds;
        
        self.trackBgColor = trackBgColor;
        self.trackColor = trackColor;
        
        self.annulusPercent = 0.3;

        self.annulusWidth = annulusWidth;
        
        //添加图层
        [self.layer addSublayer:_trackBgLayer];
        [self.layer addSublayer:_trackLayer];
        
        //开始动画
        [self startIndeterminateAnimation];
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    //默认属性
    return  [self initWithFrame:frame
                   trackBgColor:[UIColor grayColor]
                     trackColor:[UIColor whiteColor]
                   annulusWidth:3
                 annulusPercent:0.3];

}

#pragma mark - Setter and getter
- (UILabel *)progressLabel {
    
    if (!_progressLabel) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        self.numberFormatter = numberFormatter;
        numberFormatter.numberStyle = NSNumberFormatterPercentStyle;
        numberFormatter.locale = NSLocale.currentLocale;
        
        _progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.font = [UIFont systemFontOfSize:8];
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_progressLabel];

    }
    return _progressLabel;
}

//设定圆环的宽度
- (void)setAnnulusWidth:(float)annulusWidth {
    
    _annulusWidth = annulusWidth;
    _trackBgLayer.lineWidth = _annulusWidth;
    _trackLayer.lineWidth = _annulusWidth;
    
    //设定宽度后要重新设定路径
    [self setBgTrack];  //设定圆环背景
    [self setTrack]; //设定圆环百分比
}

//设置圆环的百分比
- (void) setAnnulusPercent:(float)annulusPercent {
    
    _annulusPercent = annulusPercent;
    
    //设定圆环百分比后要重新设定路径
    [self setTrack]; //设定圆环百分比
}



- (void)setTrackBgColor:(UIColor *)trackBgColor {
    
    _trackBgLayer.strokeColor = trackBgColor.CGColor;
    
}

- (void)setTrackColor:(UIColor *)trackColor {
    
    _trackLayer.strokeColor = trackColor.CGColor;
    
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    self.progressLabel.text = [self.numberFormatter stringFromNumber:@(self.progress)];
}


- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    
    if (_hidesWhenStopped == hidesWhenStopped) {
        return;
    }
    _hidesWhenStopped = hidesWhenStopped;
    
    if (_hidesWhenStopped && _isAnimationing == YES) {
        self.hidden = YES;
    }
    else {
        self.hidden = NO;
    }
}

- (void)setAnimatDuration:(float)animatDuration {
    
    _animatDuration = animatDuration;
    
    //已有动画则先移除
    id animation = [_trackLayer animationForKey:@"indeterminateAnimations"];
    if (animation != nil && [animation isKindOfClass:[CABasicAnimation class]]) {
        [self stopIndeterminateAnimation];
    }
    
    [self startIndeterminateAnimation];
}


#pragma mark - Private method
//设定背景形状Layer
- (void)setBgTrack
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    
    _trackBgPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))

                                                radius:(self.bounds.size.width - _annulusWidth)/ 2
                                            startAngle:DEGREES_TO_RADIANS(0)
                                              endAngle:DEGREES_TO_RADIANS(360)
                                             clockwise:YES];
    _trackBgLayer.path = _trackBgPath.CGPath;
    
    [CATransaction commit];
}

//设定圆环layer
- (void)setTrack
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    //百分比转换
    CGFloat endRadians = 360 * _annulusPercent;
    
    _trackPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                   radius:(self.bounds.size.width - _annulusWidth)/ 2
                                               startAngle:DEGREES_TO_RADIANS(0)
                                                 endAngle:DEGREES_TO_RADIANS(endRadians)
                                                clockwise:YES];
    
    _trackLayer.path = _trackPath.CGPath;
    
    
    
    [CATransaction commit];

    
}

- (void)startIndeterminateAnimation
{
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = _animatDuration;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [_trackLayer addAnimation:rotationAnimation forKey:@"indeterminateAnimations"];
}

- (void)stopIndeterminateAnimation {
    
    [_trackLayer removeAnimationForKey:@"indeterminateAnimations"];
}


#pragma mark - Public method
- (void) startAnimating {
    
    if (_isAnimationing) {
        return;
    }
    
    self.isAnimationing = YES;
    
    self.hidden = NO;
    
    [self startIndeterminateAnimation];
    
}

- (void) stopAnimating {
    
    if (_isAnimationing == NO) {
        return;
    }
    
    self.isAnimationing = NO;
    
    [self stopIndeterminateAnimation];
    
    if (!_isAnimationing && _hidesWhenStopped) {
        self.hidden = YES;
    }
    
}

- (BOOL)isAnimating {
    
    return _isAnimationing;
}

#pragma mark - Override method
- (void)layoutSubviews {
    [super layoutSubviews];
    _trackBgLayer.frame = self.bounds;
    _trackLayer.frame = self.bounds;
    _progressLabel.frame = self.bounds;
}

@end
