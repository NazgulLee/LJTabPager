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

const float PAGERTABBAR_HEIGHT = 40;

#define MAX_PAGERVC_COUNT_IN_SCROLLVIEW 3

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface LJTabPagerVC () <UIScrollViewDelegate, LJPagerTabBarDelegate>

@property (nonatomic) NSArray *titles; /// 每次设置titles会使topTabBar重新布局
@property (nonatomic) LJPagerTabBar *topTabBar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *viewsInScrollview; //!< 存放放置在scrollView中的视图
@property (nonatomic) NSMutableArray *onViewControllers; //!< 存放已加载的视图控制器

@end

@implementation LJTabPagerVC
{
    BOOL _isScrollCausedByDragging; //!< 标识下方的scrollView滑动是因为用户直接滑动还是因为用户点选topTabBar的tabItem导致的
    CGFloat _initialContentOffsetX; //!< 一次滑动开始时scrollView的contentOffset
    NSInteger _initialSelectedIndex; //!< 一次滑动开始时选中的index
    NSInteger _vcsNumber; //!< 视图控制器的数量
    NSInteger _actualVCCount; //!< scrollView能放置的viewController数量
    CGRect _viewFrame;
    CGRect _lastBounds;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO; //告诉viewController不要自动调整scrollview的contentInset
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self configureViews];
    _initialSelectedIndex = self.topTabBar.selectedIndex;
    [self loadVCs];
}

- (void)configureViews {
    [self.view addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.scrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.scrollView}]];
    
    [self.view addSubview:self.topTabBar];
    self.topTabBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.topTabBar}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topTabBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topTabBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:PAGERTABBAR_HEIGHT]];
}
- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        
    } else if (orientation == UIDeviceOrientationPortrait) {
        
    }
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_lastBounds.size.width != self.scrollView.bounds.size.width || _lastBounds.size.height != self.scrollView.bounds.size.height) {
        self.scrollView.contentSize = CGSizeMake(_actualVCCount * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self showViewAtIndex:self.selectedIndex];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self reloadVCsExceptSelected:YES];
}

- (void)loadVCs {
    if (self.vcsSource) {
        _vcsNumber = [self.vcsSource numberOfViewControllers];
        self.titles = [self.vcsSource titles];
        NSAssert(_vcsNumber == self.titles.count, @"[vcsSource titles].count must equal to [vcsSource numberOfViewControllers]");
        _actualVCCount = _vcsNumber > MAX_PAGERVC_COUNT_IN_SCROLLVIEW ? MAX_PAGERVC_COUNT_IN_SCROLLVIEW : _vcsNumber;
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * (_actualVCCount), self.view.bounds.size.height);
        
        [self showViewAtIndex:self.selectedIndex];
    }
}

- (void)reloadVCsExceptSelected:(BOOL)exceptSelected {
    if (self.vcsSource) {
        for (NSInteger index = 0; index < self.onViewControllers.count; index++) {
            UIViewController *controller = self.onViewControllers[index];
            if ([controller isKindOfClass:[UIViewController class]]) {
                if (index == self.selectedIndex && exceptSelected)
                    ;
                else {
                    [controller willMoveToParentViewController:nil];
                    [controller.view removeFromSuperview];
                    [controller removeFromParentViewController];
                    self.onViewControllers[index] = [NSNull null];
                }
            }
        }
        for (NSInteger index = 0; index < self.viewsInScrollview.count; index++) {
            UIView *view = self.viewsInScrollview[index];
            if ([view isKindOfClass:[UIView class]]) {
                if (exceptSelected && view == ((UIViewController *)self.onViewControllers[self.selectedIndex]).view)
                    ;
                else
                    self.viewsInScrollview[index] = [NSNull null];
            }
        }
        if (!exceptSelected)
            [self loadVCs];
    }
}

- (void)callDelegateAtIndex:(NSInteger)index withObject:(NSNumber *)object{
    UIViewController *controller = self.onViewControllers[index];
    if ([controller isKindOfClass:[UIViewController class]]) {
        if ([controller conformsToProtocol:@protocol(LJTabPagerVCDelegate)]) {
            if ([controller respondsToSelector:@selector(hasBeenSelectedAndShown:)]) {
                [controller performSelector:@selector(hasBeenSelectedAndShown:) withObject:nil afterDelay:0];
            }
        }
    }
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
    NSLog(@"****%f", _initialSelectedIndex * self.scrollView.bounds.size.width + scrollView.contentOffset.x - _initialContentOffsetX);
    if (_isScrollCausedByDragging) {
        self.topTabBar.pagerContentOffsetX = _initialSelectedIndex * self.scrollView.bounds.size.width + scrollView.contentOffset.x - _initialContentOffsetX;
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
    BOOL _firstShown = NO;
    _isScrollCausedByDragging = NO;
    [self.topTabBar checkSelectedTabItemVisible];
    for (UIView *view in self.viewsInScrollview) {
        if ([view isKindOfClass:[UIView class]]) {
            view.hidden = YES;
        }
    }
    UIViewController *controller = self.onViewControllers[index];
    if ([controller isKindOfClass:[NSNull class]]) {
        controller = [self.vcsSource viewControllerAtIndex:index];
        self.onViewControllers[index] = controller;
        _firstShown = YES;
    }
    NSInteger targetIndex;
    if (index == _vcsNumber-1 || index == 0)
        targetIndex = index == 0 ? 0 : _actualVCCount-1;
    else
        targetIndex = (_actualVCCount-1)/2;
    
    CGFloat targetx = targetIndex * self.scrollView.bounds.size.width;
    if (controller.parentViewController == nil) {
        [self addChildViewController:controller];
        controller.view.frame = CGRectMake(targetx, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    } else {
        controller.view.frame = CGRectMake(targetx, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        controller.view.hidden = NO;
    }
    self.viewsInScrollview[targetIndex] = controller.view;
    if (index-1 >= 0) {
        UIViewController *leftController = self.onViewControllers[index-1];
        if ([leftController isKindOfClass:[UIViewController class]] && leftController.parentViewController != nil) {
            CGSize size = self.scrollView.bounds.size;
            leftController.view.frame = CGRectMake(targetx - size.width, 0, size.width, size.height);
            leftController.view.hidden = NO;
            self.viewsInScrollview[targetIndex-1] = leftController.view;
        }
    }
    if (index+1 < _vcsNumber) {
        UIViewController *rightController = self.onViewControllers[index+1];
        if ([rightController isKindOfClass:[UIViewController class]] && rightController.parentViewController != nil) {
            CGSize size = self.scrollView.bounds.size;
            rightController.view.frame = CGRectMake(targetx + size.width, 0, size.width, size.height);
            rightController.view.hidden = NO;
            self.viewsInScrollview[targetIndex+1] = rightController.view;
        }
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width * targetIndex, 0) animated:NO];
    [self callDelegateAtIndex:index withObject:[NSNumber numberWithBool:_firstShown]];
}

#pragma mark - Accessor Methods
- (void)setVcsSource:(id<LJTabPagerVCsSource>)vcsSource {
    
    _vcsSource = vcsSource;
}

- (LJPagerTabBar *)topTabBar {
    if (!_topTabBar) {
        _topTabBar = [[LJPagerTabBar alloc] init];
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
    }
    return _scrollView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = [self.vcsSource titles];
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
        _selectedLineColor = [UIColor colorWithRed:235/255.0 green:69/255.0 blue:47/255.0 alpha:1];
    }
    return _selectedLineColor;
}

- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    _selectedLineColor = selectedLineColor;
    self.topTabBar.selectedLineColor = selectedLineColor;
}

- (UIColor *)selectedTabItemColor {
    if (!_selectedTabItemColor) {
        _selectedTabItemColor = [UIColor colorWithRed:235/255.0 green:69/255.0 blue:47/255.0 alpha:1];
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

- (NSMutableArray *)viewsInScrollview {
    if (!_viewsInScrollview) {
        _viewsInScrollview = [NSMutableArray array];
        for (NSInteger i = 0; i < _actualVCCount; i++) {
            [_viewsInScrollview addObject:[NSNull null]];
        }
    }
    return _viewsInScrollview;
}

- (NSMutableArray *)onViewControllers {
    if (!_onViewControllers) {
        NSInteger n = _vcsNumber;
        _onViewControllers = [NSMutableArray array];
        for (NSInteger i = 0; i < n; i++) {
            [_onViewControllers addObject:[NSNull null]];
        }
    }
    return _onViewControllers;
}

@end
