//
//  LJTabPagerVC.m
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "LJTabPagerVC.h"
#import "LJPagerTabBar.h"

#define CONTENT_SCROLLVIEW 1000
#define PAGERTABBAR_SCROLLVIEW 1001

#define PAGERTABBAR_HEIGHT 40

@interface LJTabPagerVC () <UIScrollViewDelegate, LJPagerTabBarDelegate>

@property (nonatomic) NSArray *titles;
@property (nonatomic) LJPagerTabBar *topTabBar;
@property (nonatomic) UIScrollView *scrollView;

@end

@implementation LJTabPagerVC
{
    BOOL isScrollCausedByDragging;
    NSInteger selectedControllerIndex;
    CGFloat initialContentOffsetX;
}

@synthesize topTabBar = _topTabBar;
@synthesize titles = _titles;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isScrollCausedByDragging = YES;
    selectedControllerIndex = self.topTabBar.selectedIndex;
    //self.titles = @[@"个性推荐", @"歌单", @"主播电台", @"排行榜"];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; //告诉viewController不要自动调整scrollview的contentInset
    
    [self.view addSubview:self.scrollView];
    //[self.scrollView setContentOffset:CGPointMake(0, 0)];
    [self.view addSubview:self.topTabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)callDelegateAtIndex:(NSInteger)index {
    if ([self.viewControllers[index] conformsToProtocol:@protocol(LJTabPagerVCDelegate)]) {
        //NSLog(@"conformsToProtocol");
        if ([self.viewControllers[index] respondsToSelector:@selector(hasBeenSelectedAndShown)]) {
            //NSLog(@"respondsToSelector");
            [self.viewControllers[index] hasBeenSelectedAndShown];
        }
    }
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"content offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
    //NSLog(@"%s", __FUNCTION__);
    if (isScrollCausedByDragging) {
        self.topTabBar.pagerContentOffsetX = scrollView.contentOffset.x;
    }
//    if (1 < self.topTabBar.selectedIndex && self.topTabBar.selectedIndex < self.viewControllers.count - 2) {
//        if (scrollView.contentOffset.x - initialContentOffsetX > 0) {
//            self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_RIGHT;
//        } else if (scrollView.contentOffset.x - initialContentOffsetX < 0) {
//            self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_LEFT;
//        } else {
//            self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_NONE;
//        }
//    } else {
//        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_NONE;
//    }
    if (scrollView.contentOffset.x - initialContentOffsetX > 0) {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_RIGHT;
    } else if (scrollView.contentOffset.x - initialContentOffsetX < 0) {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_LEFT;
    } else {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_NONE;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrollCausedByDragging = YES;
    initialContentOffsetX = scrollView.contentOffset.x;
    [self.topTabBar recordInitialAndDestX];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"%s", __FUNCTION__);
    if (selectedControllerIndex != self.topTabBar.selectedIndex) { // 由用户左右滑动导致的viewController切换
        selectedControllerIndex = self.topTabBar.selectedIndex;
        [self.topTabBar checkSelectedTabItemVisible]; 
        [self callDelegateAtIndex:selectedControllerIndex];
    }
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"%s", __FUNCTION__);
//}

#pragma LJPagerTabBarDelegate

- (void)showViewAtIndex:(NSInteger)index {
    isScrollCausedByDragging = NO;
    [self.topTabBar checkSelectedTabItemVisible];
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * index, 0) animated:NO];
    [self callDelegateAtIndex:index]; // 用户直接点选tabItem导致的viewController切换，不过即便没切换也调用
}

#pragma mark - Accessor Methods

- (LJPagerTabBar *)topTabBar {
    if (!_topTabBar) {
        _topTabBar = [[LJPagerTabBar alloc] initWithTitles:self.titles frame:CGRectMake(0, 64, self.view.bounds.size.width, PAGERTABBAR_HEIGHT)];
        _topTabBar.pagerTabBarDelegate = self;
    }
    return _topTabBar;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.tag = CONTENT_SCROLLVIEW;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        //_scrollView.clipsToBounds = YES;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.delaysContentTouches = YES;
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.viewControllers.count, self.view.bounds.size.height);
        _scrollView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height);
        _scrollView.backgroundColor = [UIColor yellowColor];
    }
    return _scrollView;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    for (int i = 0; i < viewControllers.count; i++) {
        UIViewController *controller = viewControllers[i];
        [self addChildViewController:controller];
        controller.view.frame = CGRectMake(self.scrollView.bounds.size.width * i, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (NSArray *)titles {
    if (!_titles) {
        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
        for (int i = 0; i < self.viewControllers.count; i++) {
            UIViewController *controller = self.viewControllers[i];
            [titles addObject:controller.title];
        }
        _titles = [NSArray arrayWithArray:titles];
    }
    return _titles;
}

//- (void)setTitles:(NSArray *)titles {
//    _titles = titles;
//    self.topTabBar.titles = titles;
//}

@end
