//
//  CustomScrollView.h
//  UIScrollViewDemo5
//
//  Created by 李新星 on 13-9-6.
//  Copyright (c) 2013年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXZoomingScrollView.h"

@class LXImageLoopBrowser;

@protocol LXImageLoopBrowserDelegate <NSObject>

@optional
- (void) imageLoopBrowser:(LXImageLoopBrowser *)imageLoopBrowser didOnceTapAtIndex:(NSUInteger)index;
- (void) imageLoopBrowser:(LXImageLoopBrowser *)imageLoopBrowser didMoveAtIndex:(NSUInteger)toIndex moveFromIndex:(NSUInteger)fromIndex;
- (UIImage *)imageLoopBrowser:(LXImageLoopBrowser *)imageLoopBrowser placeholderImageForIndex:(NSInteger)index;

@end

@interface LXImageLoopBrowser : UIView

@property (nonatomic, strong, readonly) UIScrollView * scrollView;

@property (nonatomic, strong, readonly) UIPageControl * pageControl;

/*! 所有的图片 */
@property (nonatomic, copy) NSArray * imageUrls;

/*! 当前显示图片下标  */
@property (assign, nonatomic) NSInteger currentIndex;

/*! 加载失败显示图片 */
@property (nonatomic, strong) UIImage * errorImage;

/*! 当前图片  */
@property (nonatomic, strong, readonly) UIImage * currentImage;

/*! 当前用于显示图片的视图 */
@property (strong, nonatomic,readonly) LXZoomingScrollView * currentPhotoView;

/*! 能否双击方大缩小 */
@property (nonatomic, assign) BOOL zoomEnabled;

/**
 图片显示模式
 默认是UIViewContentModeScaleAspectFit
 */
@property (nonatomic) UIViewContentMode imageContentMode;

/*! 代理 */
@property (weak, nonatomic) id<LXImageLoopBrowserDelegate> delegate;

/*! 从缓存中获取图片  */
- (UIImage *) getImageAtIndex:(NSInteger)index;

@end
