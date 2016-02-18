//
//  ViewController.m
//  LXPhotobroswerDemo
//
//  Created by 李新星 on 15/11/25.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "ViewController.h"
#import "LXFullScreenImageBrowser.h"
#import <SDImageCache.h>
#import <UIButton+WebCache.h>
#import "TestSigleton.h"

@interface ViewController () <LXImageLoopBrowserDelegate, LXFullScreenImageBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIButton *imageBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageBtn sd_setImageWithURL:[NSURL URLWithString:@"http://112.74.194.40:8180/careu-server/common/resource!bbsdownload.action?ures_id=299"] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    TestSigleton * test1 = [TestSigleton sharedTestSigleton];
    TestSigleton * test2 = [[TestSigleton alloc] init];
    TestSigleton * test3 = [TestSigleton new];

    NSLog(@"\nTestSigleton1:%@\nTestSigleton2:%@  test3:%@", test1, test2, test3);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)start:(id)sender {
    
    LXFullScreenImageBrowser * browser = [[LXFullScreenImageBrowser alloc] initWithFrame:[UIScreen mainScreen].bounds];
    browser.delegate = self;
    browser.fullScreenDelegate = self;
    browser.originContentMode =UIViewContentModeScaleAspectFill;
    browser.imageUrls = @[@"http://112.74.194.40:8180/careu-server/common/resource!bbsdownload.action?ures_id=299"];
    browser.currentIndex = 0;
    browser.zoomEnabled = YES;
    browser.imageContentMode = UIViewContentModeScaleAspectFit;
    [browser show];
}

#pragma mark - LXImageLoopBrowserDelegate
- (void)imageLoopBrowser:(LXImageLoopBrowser *)imageLoopBrowser didOnceTapAtIndex:(NSUInteger)index {
    
    LXFullScreenImageBrowser * browser = (LXFullScreenImageBrowser *)imageLoopBrowser;
    if ([browser respondsToSelector:@selector(dismiss)]) {
        [browser dismiss];
    }
}

- (UIImage *)imageLoopBrowser:(LXImageLoopBrowser *)imageLoopBrowser placeholderImageForIndex:(NSInteger)index {
    return [self.imageBtn currentImage];
}

- (CGRect)imageLoopBrowser:(LXFullScreenImageBrowser *)imageLoopBrowser startRectForIndex:(NSInteger)index {
    return self.imageBtn.frame;
}


@end
