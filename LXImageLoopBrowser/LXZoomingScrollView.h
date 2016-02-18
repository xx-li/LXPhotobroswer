//
//  CustomScrollView.m
//
//  Created by 李新星 on 13-3-4.
//  Copyright (c) 2013年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXZoomingScrollView;


@protocol LXZoomingScrollViewDelegate <NSObject>

- (void)zoomingScrollViewSingleTap:(LXZoomingScrollView *)photoView;

@end

@interface LXZoomingScrollView : UIScrollView <UIScrollViewDelegate>

//获取当前显示的图片
@property (strong, nonatomic,readonly) UIImage * currentImage;

//图片显示模式
@property (nonatomic) UIViewContentMode imageContentMode;// default is UIViewContentModeScaleAspectFit

@property (nonatomic, assign) BOOL zoomEnabled;// 能否双击方大缩小


//代理
@property (nonatomic, weak) id<LXZoomingScrollViewDelegate> tapDelegate;

//加载网络图片的方法
- (void) lx_setImageWithURL:(NSURL *)url;
- (void) lx_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void) lx_setImageWithURL:(NSURL *)url placeholderImage:(UIImage * )placeholderImage errorImage:(UIImage *) errorImage;

@end