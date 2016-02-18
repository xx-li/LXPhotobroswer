//
//  LXCircularProgressView.h
//  SDWebImageViewProgress
//
//  Created by 李新星 on 14-2-23.
//  Copyright (c) 2014年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCircularProgressView : UIControl

- (id)initWithFrame:(CGRect)frame
       trackBgColor:(UIColor *)trackBgColor
         trackColor:(UIColor *)trackColor
       annulusWidth:(CGFloat)annulusWidth
     annulusPercent:(CGFloat)annulusPercent;

@property (nonatomic, strong) UIColor *trackBgColor;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic) float annulusWidth;
@property (nonatomic) float annulusPercent;     //圆环的百分比 0～1之间的数

@property (nonatomic) float  animatDuration;    //转一圈所用的时间

@property (nonatomic) float progress;//0~1之间的数

//模仿系统UIActivityIndicatorView 接口，效果一样。
@property(nonatomic) BOOL hidesWhenStopped;

- (void)startAnimating;

- (void)stopAnimating;

- (BOOL)isAnimating;



@end
