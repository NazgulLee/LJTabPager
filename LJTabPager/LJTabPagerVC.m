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

#define MAX_PAGERVC_COUNT_IN_SCROLLVIEW 3

@interface LJTabPagerVC () <UIScrollViewDelegate, LJPagerTabBarDelegate>

@property (nonatomic) NSArray *titles;
@property (nonatomic) LJPagerTabBar *topTabBar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *presentingViews;

@end

@implementation LJTabPagerVC
{
    BOOL _isScrollCausedByDragging; //!< 标识下方的scrollView滑动是因为用户直接滑动还是因为用户点选topTabBar的tabItem导致的
    CGFloat _initialContentOffsetX; //!< 一次滑动开始时scrollView的contentOffset
    NSInteger _initialSelectedIndex;
}

@synthesize topTabBar = _topTabBar;
@synthesize titles = _titles;
@synthesize tabBarBKColor = _tabBarBKColor;
@synthesize selectedLineColor = _selectedLineColor;
@synthesize selectedTabItemColor = _selectedTabItemColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _isScrollCausedByDragging = YES;
    _initialSelectedIndex = self.topTabBar.selectedIndex;
    
    self.automaticallyAdjustsScrollViewInsets = NO; //告诉viewController不要自动调整scrollview的contentInset
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.topTabBar];
}

- (void)callDelegateAtIndex:(NSInteger)index {
    if ([self.viewControllers[index] conformsToProtocol:@protocol(LJTabPagerVCDelegate)]) {
        if ([self.viewControllers[index] respondsToSelector:@selector(hasBeenSelectedAndShown)]) {
            [self.viewControllers[index] hasBeenSelectedAndShown];
        }
    }
}

- (void)updateTitles {
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *controller = self.viewControllers[i];
        [titles addObject:controller.title];
    }
    self.titles = [NSArray arrayWithArray:titles];
}

#pragma UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isScrollCausedByDragging = YES;
    _initialContentOffsetX = scrollView.contentOffset.x;
    _initialSelectedIndex = self.selectedIndex;
    self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_NONE; // 重置scrollOrientation
    [self.topTabBar recordInitialAndDestX];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"****%f", _initialSelectedIndex * self.view.bounds.size.width + scrollView.contentOffset.x - _initialContentOffsetX);
    if (_isScrollCausedByDragging) {
        self.topTabBar.pagerContentOffsetX = _initialSelectedIndex * self.view.bounds.size.width + scrollView.contentOffset.x - _initialContentOffsetX;
    }
    if (scrollView.contentOffset.x - _initialContentOffsetX > 0) {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_RIGHT;
    } else if (scrollView.contentOffset.x - _initialContentOffsetX < 0) {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_LEFT;
    } else {
        self.topTabBar.scrollOrientation = SCROLL_ORIENTATION_NONE;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_initialSelectedIndex != self.topTabBar.selectedIndex) { // viewController切换了
        _initialSelectedIndex = self.topTabBar.selectedIndex;
        [self showViewAtIndex:self.selectedIndex];
    }
}

#pragma LJPagerTabBarDelegate
- (void)showViewAtIndex:(NSInteger)index {
    _isScrollCausedByDragging = NO;
    [self.topTabBar checkSelectedTabItemVisible];
    UIViewController *controller = self.viewControllers[index];
    if (index == self.viewControllers.count-1 || index == 0) {
        NSObject *obj = index == 0 ? self.presentingViews[0] : self.presentingViews[MAX_PAGERVC_COUNT_IN_SCROLLVIEW-1];
        if ([obj isKindOfClass:[UIView class]]) {
            ((UIView *)obj).hidden = true;
        }
        CGFloat x = index == 0 ? 0 : (MAX_PAGERVC_COUNT_IN_SCROLLVIEW-1)*self.view.bounds.size.width;
        if (controller.parentViewController == nil) {
            [self addChildViewController:controller];
            controller.view.frame = CGRectMake(x, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            [self.scrollView addSubview:controller.view];
            [controller didMoveToParentViewController:self];
        } else {
            controller.view.frame = CGRectMake(x, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            controller.view.hidden = false;
        }
        self.presentingViews[(index == 0 ? 0 : MAX_PAGERVC_COUNT_IN_SCROLLVIEW-1)] = controller.view;
        [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    } else{
        for (NSInteger i = 0; i < MAX_PAGERVC_COUNT_IN_SCROLLVIEW; i++) {
            NSObject *obj = self.presentingViews[i];
            if ([obj isKindOfClass:[UIView class]]) {
                ((UIView *)obj).hidden = true;
            }
        }
        NSInteger mid = (MAX_PAGERVC_COUNT_IN_SCROLLVIEW-1)/2;
        for (NSInteger i = 0; i < MAX_PAGERVC_COUNT_IN_SCROLLVIEW; i++) {
            UIViewController *controller = self.viewControllers[index+i-mid];
            if (controller.parentViewController != nil) {
                controller.view.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
                controller.view.hidden = false;
                self.presentingViews[i] = controller.view;
            }
            if (i == mid && controller.parentViewController == nil) {
                [self addChildViewController:controller];
                controller.view.frame = CGRectMake(i * self.view.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
                [self.scrollView addSubview:controller.view];
                [controller didMoveToParentViewController:self];
                self.presentingViews[i] = controller.view;
            }
        }
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * mid, 0) animated:NO];
    }
    
    [self callDelegateAtIndex:index]; // 用户滑动到其他viewController时调用，或者用户直接点选tabItem来切换viewController时调用（点选当前选中的tabItem也会调用）
}

- (NSInteger)pagerVCInitialSelectedIndex {
    return self.selectedIndex;
}

#pragma mark - Accessor Methods
- (void)setViewControllers:(NSArray *)viewControllers {
    NSParameterAssert(viewControllers.count > 0);
    if (_viewControllers.count > 0) { //移除旧的_viewControllers
        for (int i = 0; i < _viewControllers.count; i++) {
            UIViewController *controller = _viewControllers[i];
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
        _viewControllers = nil;
    }
    _viewControllers = viewControllers;
    NSInteger actualVCCount = viewControllers.count > MAX_PAGERVC_COUNT_IN_SCROLLVIEW ? MAX_PAGERVC_COUNT_IN_SCROLLVIEW : viewControllers.count;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * (actualVCCount), self.view.bounds.size.height);
//    for (int i = 0; i < viewControllers.count; i++) {
//        UIViewController *controller = viewControllers[i];
//        [self addChildViewController:controller];
//        controller.view.frame = CGRectMake(self.scrollView.bounds.size.width * i, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
//        [self.scrollView addSubview:controller.view];
//        [controller didMoveToParentViewController:self];
//    }
    UIViewController *controller = viewControllers[0];
    [self addChildViewController:controller];
    controller.view.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    self.presentingViews[0] = controller.view;
    [self updateTitles];
    
    [self.topTabBar removeFromSuperview];
    [self.view addSubview:self.topTabBar]; //解决先设置selectedLine颜色，再设置viewControllers产生的奇怪的bug
}

- (LJPagerTabBar *)topTabBar {
    if (!_topTabBar) {
        _topTabBar = [[LJPagerTabBar alloc] initWithTitles:self.titles frame:CGRectMake(0, 0, self.view.bounds.size.width, PAGERTABBAR_HEIGHT)]; //这里由于使用了self.view，若这时self.view还没有load，会先执行[self loadView]和[self viewDidLoad]
        _topTabBar.backgroundColor = self.tabBarBKColor;
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
        _scrollView.directionalLockEnabled = YES;
        _scrollView.delaysContentTouches = YES;
        _scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    return _scrollView;
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

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    self.topTabBar.titles = titles;
}

- (UIColor *)tabBarBKColor {
    if (!_tabBarBKColor) {
        _tabBarBKColor = [UIColor colorWithWhite:0.95 alpha:0.95];
    }
    return _tabBarBKColor;
}

- (void)setTabBarBKColor:(UIColor *)tabBarBKColor {
    _tabBarBKColor = tabBarBKColor;
    self.topTabBar.backgroundColor = tabBarBKColor;
}

- (UIColor *)selectedLineColor {
    if (!_selectedLineColor) {
        _selectedLineColor = self.topTabBar.selectedLineColor;
    }
    return _selectedLineColor;
}

- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    _selectedLineColor = selectedLineColor;
    self.topTabBar.selectedLineColor = selectedLineColor;
}

- (UIColor *)selectedTabItemColor {
    if (!_selectedTabItemColor) {
        _selectedTabItemColor = self.topTabBar.selectedTabItemColor;
    }
    return _selectedTabItemColor;
}

- (void)setSelectedTabItemColor:(UIColor *)selectedTabItemColor {
    _selectedTabItemColor = selectedTabItemColor;
    self.topTabBar.selectedTabItemColor = selectedTabItemColor;
}

+ (CGFloat)pagerTabBarHeight {
    return PAGERTABBAR_HEIGHT;
}

- (NSInteger)selectedIndex {
    return self.topTabBar.selectedIndex;
}

- (NSMutableArray *)presentingViews {
    if (!_presentingViews) {
        _presentingViews = [NSMutableArray array];
        for (NSInteger i = 0; i < MAX_PAGERVC_COUNT_IN_SCROLLVIEW; i++) {
            [_presentingViews addObject:[NSNull null]];
        }
    }
    return _presentingViews;
}
@end
