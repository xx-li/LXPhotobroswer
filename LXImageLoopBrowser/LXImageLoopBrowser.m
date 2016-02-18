//
//  CustomScrollView.h
//  UIScrollViewDemo5
//
//  Created by 李新星 on 13-9-6.
//  Copyright (c) 2013年 xx-li. All rights reserved.
//

#import "LXImageLoopBrowser.h"

#import "LXZoomingScrollView.h"
#import <SDWebImageManager.h>

#define IMAGEVIEW_TAG           1000
#define kLXCurImgUrl            @"kLXCurImgUrl"
#define kLXCurPlaceholderImg    @"kLXCurPlaceholderImg"


@interface LXImageLoopBrowser ()<UIScrollViewDelegate, LXZoomingScrollViewDelegate>
{
    // 当前需要展示的3张图片
    NSMutableArray * _curImgArr;
    UIView * _contentView;
    BOOL _isShowAtWindow;
}



@end

@implementation LXImageLoopBrowser

- (void)dealloc
{
    NSLog(@"LXImageLoopBrowser dealloc");
}

#pragma mark - Life cycle
//从xib初始化会调用此方法
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self loadScrollImageUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadScrollImageUI];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

//加载ScrollView上的UIImageView
- (void) loadScrollImageUI {
    
    _zoomEnabled = YES;
    _imageContentMode = UIViewContentModeScaleAspectFit;
    _curImgArr = [[NSMutableArray alloc] init];
    _currentIndex = 0;
    
    _scrollView = [[UIScrollView alloc] init];
    
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_scrollView];
    
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                           ]];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
//    _contentView.layer.borderWidth = 1;
//    _contentView.layer.borderColor = [UIColor orangeColor].CGColor;

    [_scrollView addSubview:_contentView];
    [_scrollView addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:_scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual  toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:3 constant:0],
                           [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual  toItem:_scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]
                           ]];

    NSLayoutConstraint * leftConstraint = nil;
    LXZoomingScrollView * tempView = nil;
    for (int i = 0; i < 3; i++) {
        
        LXZoomingScrollView * photoView = [[LXZoomingScrollView alloc] init];
        photoView.tag = IMAGEVIEW_TAG + i;
        photoView.translatesAutoresizingMaskIntoConstraints = NO;
        photoView.zoomEnabled = _zoomEnabled;
        photoView.tapDelegate = self;
        photoView.imageContentMode = _imageContentMode;
        [_contentView addSubview:photoView];
        
        if (tempView) {
            leftConstraint = [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:tempView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        } else {
            leftConstraint = [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        }

        [_contentView addConstraints:@[
                                      leftConstraint,
                                      [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                      [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:_contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                      [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual  toItem:_contentView attribute:NSLayoutAttributeWidth multiplier:1.0/3.0 constant:0]
                                      ]];
        
        tempView = photoView;
    }
    
    _currentPhotoView =  (LXZoomingScrollView *)[_contentView viewWithTag:IMAGEVIEW_TAG + 1];
    _pageControl = [[UIPageControl alloc] init];
    [self addSubview:_pageControl];
}

#pragma mark - Setter and getter
- (void)setImageUrls:(NSArray *)imageUrls {
    
    if (_imageUrls == imageUrls) {
        return;
    }
    
    _imageUrls = [imageUrls copy];
    _currentIndex = 0;
    _pageControl.numberOfPages = _imageUrls.count;
    [self loadData];
    [self refreshScrollView];
    
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    if (_zoomEnabled == zoomEnabled) {
        return;
    }
    _zoomEnabled = zoomEnabled;
    
    for (int i = 0; i < 3; i++) {
        LXZoomingScrollView * scaleView = (LXZoomingScrollView *)[_scrollView viewWithTag:IMAGEVIEW_TAG + i];
        scaleView.zoomEnabled = _zoomEnabled;
    }
}

- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
    if (_imageContentMode == imageContentMode) {
        return;
    }
    _imageContentMode = imageContentMode;
    
    for (int i = 0; i < 3; i++) {
        LXZoomingScrollView * scaleView = (LXZoomingScrollView *)[_scrollView viewWithTag:IMAGEVIEW_TAG + i];
        scaleView.imageContentMode = _imageContentMode;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex == currentIndex) {
        return;
    }
    
    if (currentIndex < _imageUrls.count) {
        _currentIndex = currentIndex;
        [self loadData];
        [self refreshScrollView];
    }
    else {
        NSLog(@"越界！");
    }
    
    _pageControl.currentPage = _currentIndex;
}



- (UIImage *)currentImage {
    LXZoomingScrollView * imgView = (LXZoomingScrollView *)[_contentView viewWithTag:IMAGEVIEW_TAG + 1];
    return imgView.currentImage;
}

#pragma mark - Private method


// 索引值必须保证在数组不越界的范围之内 0－_imageUrls.count-1
- (NSInteger) beyondBounds:(NSInteger)index
{
    // 第一张往左滑
    if (index < 0) {
        index = _imageUrls.count-1;
    } else if (index >= _imageUrls.count) { // 最后一张往右滑
        index = 0;
    }
    
    return index;
}

//每一次都向数组中添加3张图片数据
- (void)loadData
{
    [_curImgArr removeAllObjects];
    
    if (_imageUrls.count < 1) {
        _scrollView.scrollEnabled = NO;
        return;
    } else if (_imageUrls.count == 1) {
        _scrollView.scrollEnabled = NO;
    } else {
        _scrollView.scrollEnabled = YES;
    }
    
    NSInteger prePage = [self beyondBounds:_currentIndex-1];
    NSInteger curPage = [self beyondBounds:_currentIndex];
    NSInteger nextPage = [self beyondBounds:_currentIndex+1];
    
    UIImage * preImage;
    UIImage * curImage;
    UIImage * nextImage;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoopBrowser:placeholderImageForIndex:)]) {
        preImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:prePage];
        curImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:curPage];
        nextImage = [self.delegate imageLoopBrowser:self placeholderImageForIndex:nextPage];
    }
    
    NSMutableDictionary * preDic = [NSMutableDictionary dictionary];
    [preDic setValue:[_imageUrls objectAtIndex:prePage] forKey:kLXCurImgUrl];
    [preDic setValue:preImage forKey:kLXCurPlaceholderImg];

    NSMutableDictionary * curDic = [NSMutableDictionary dictionary];
    [curDic setValue:[_imageUrls objectAtIndex:curPage] forKey:kLXCurImgUrl];
    [curDic setValue:curImage forKey:kLXCurPlaceholderImg];

    NSMutableDictionary * nextDic = [NSMutableDictionary dictionary];
    [nextDic setValue:[_imageUrls objectAtIndex:nextPage] forKey:kLXCurImgUrl];
    [nextDic setValue:nextImage forKey:kLXCurPlaceholderImg];

    // 添加图片
    [_curImgArr addObject:preDic];
    [_curImgArr addObject:curDic];
    [_curImgArr addObject:nextDic];
}

//刷新显示图片
- (void) refreshScrollView
{
    
    //刷新显示图片
    for (int i = 0; i < 3; i++) {
        
        LXZoomingScrollView * imgView = (LXZoomingScrollView *)[_scrollView viewWithTag:IMAGEVIEW_TAG + i];
        
        NSDictionary * imageDic = _curImgArr[i];
       
        NSURL * imagUrl = [NSURL URLWithString:[imageDic objectForKey:kLXCurImgUrl]];
        UIImage * placeholderImage = [imageDic objectForKey:kLXCurPlaceholderImg];
        
        [imgView lx_setImageWithURL:imagUrl placeholderImage:placeholderImage errorImage:_errorImage];
    }

    // 滚动到第2屏数据  才是当前页面
    // 第1屏是前1张图片  第2屏才是当前页面  第3屏是下1屏
    _scrollView.contentOffset =CGPointMake(_scrollView.frame.size.width, 0);
    
}

#pragma mark - Delegate
#pragma mark UIScrollViewDelegate
// 停止减速调用
// 停止减速的瞬间判断 scrollView的偏移量 决定是否加载新的图片数据
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSUInteger oldPage = _currentIndex;
    // 加载下一页  每次滑动后scrollView的偏移量已经是1*scrollView.frame.size.width
    if (scrollView.contentOffset.x >= 2 * scrollView.frame.size.width) {
        
        _currentIndex = [self beyondBounds:_currentIndex + 1];
        
        [self loadData];
        [self refreshScrollView];
        if ([self.delegate respondsToSelector:@selector(imageLoopBrowser:didMoveAtIndex:moveFromIndex:)]) {
            [self.delegate imageLoopBrowser:self didMoveAtIndex:_currentIndex moveFromIndex:oldPage];
        }
    }
    
    // 加载上一页
    if (scrollView.contentOffset.x <= 0) {
       
        _currentIndex = [self beyondBounds:_currentIndex - 1];
        
        [self loadData];
        [self refreshScrollView];
        
        if ([self.delegate respondsToSelector:@selector(imageLoopBrowser:didMoveAtIndex:moveFromIndex:)]) {
            [self.delegate imageLoopBrowser:self didMoveAtIndex:_currentIndex moveFromIndex:oldPage];
        }
    }
    
    
    _pageControl.currentPage = _currentIndex;
    
}

#pragma mark LXZoomingScrollViewDelegate
- (void) zoomingScrollViewSingleTap:(LXZoomingScrollView *)photoView {
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageLoopBrowser:didOnceTapAtIndex:)]) {
        [_delegate imageLoopBrowser:self didOnceTapAtIndex:_currentIndex];
    }
}




#pragma mark - Public method
- (UIImage *) getImageAtIndex:(NSInteger)index {
    
    UIImage * image = nil;
    
    if (_imageUrls.count > index) {
        
        NSURL * imageUrl = [NSURL URLWithString:_imageUrls[index]];
        NSString * key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageUrl];
        image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
        if (!image) {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        }
    }
    
    return image;
}

#pragma mark - Override method
- (void) layoutSubviews {
    [super layoutSubviews];
    //AutoLayout 改变Frame的时候，会把ScrollView的 contentOffset和ContentSize设为0， 需要在此做此操作显示中间的LXZoomingScrollView
    _scrollView.contentOffset =CGPointMake(_scrollView.frame.size.width, 0);
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 40, CGRectGetWidth(self.frame), 20);
    
}


@end





