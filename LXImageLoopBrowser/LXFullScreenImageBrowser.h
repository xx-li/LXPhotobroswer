//
//  LXSocialImageBrowser.h
//  LXPhotobroswerDemo
//
//  Created by 李新星 on 15/7/3.
//  Copyright (c) 2014年 xx-li. All rights reserved.
//

#import "LXImageLoopBrowser.h"

@class LXFullScreenImageBrowser;

@protocol LXFullScreenImageBrowserDelegate <NSObject>

@required
- (CGRect)imageLoopBrowser:(LXFullScreenImageBrowser *)imageLoopBrowser startRectForIndex:(NSInteger)index;
- (UIView *)imageLoopBrowser:(LXFullScreenImageBrowser *)imageLoopBrowser originViewForIndex:(NSInteger)index;


@end

@interface LXFullScreenImageBrowser : LXImageLoopBrowser

@property (weak, nonatomic) id<LXFullScreenImageBrowserDelegate> fullScreenDelegate;

@property (assign, nonatomic) UIViewContentMode originContentMode;


/**
 *  显示在window上
 */
- (void)show;

/**
 *  从window上消失
 */
- (void) dismiss;

@end
