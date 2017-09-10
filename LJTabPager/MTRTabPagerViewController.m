//
//  MTRTabPagerViewController.m
//  MTRTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRTabPagerViewController.h"
#import "MTRPagerTabBar.h"

#define CONTENT_SCROLLVIEW 1000
#define PAGERTABBAR_SCROLLVIEW 1001

const float PAGERTABBAR_HEIGHT = 40;

#define MAX_PAGERVC_COUNT_IN_SCROLLVIEW 3

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface MTRTabPagerViewController () <UIScrollViewDelegate, MTRPagerTabBarDelegate>

@property (nonatomic) NSArray *titles; /// 每次设置titles会使topTabBar重新布局
@property (nonatomic) MTRPagerTabBar *topTabBar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *onViewControllers; //!< 存放已加载的视图控制器

// MTRRecycle
@property (nonatomic) NSMutableDictionary *mtrReusableCellsDic;
@property (nonatomic) NSMutableDictionary *mtrInUsingCellsDic;
@property (nonatomic) NSMutableDictionary *mtrCellClassAndReuseIdentifierDic;
- (void)mtrRecycleViewControllers;
- (void)mtrReloadViewController:(UIViewController *)controller;
@end

@implementation MTRTabPagerViewController
{
    BOOL _isScrollCausedByDragging; //!< 标识下方的scrollView滑动是因为用户直接滑动还是因为用户点选topTabBar的tabItem导致的
    CGFloat _initialContentOffsetX; //!< 一次滑动开始时scrollView的contentOffset
    NSInteger _initialSelectedIndex; //!< 一次滑动开始时选中的index
    NSInteger _vcsNumber; //!< 视图控制器的数量
    CGRect _viewFrame;
    UIDeviceOrientation _lastOrientation;
}

@synthesize topTabBar = _topTabBar;
@synthesize titles = _titles;
@synthesize tabBarBKColor = _tabBarBKColor;
@synthesize selectedLineColor = _selectedLineColor;
@synthesize selectedTabItemColor = _selectedTabItemColor;

+ (instancetype)sharedInstance {
    static MTRTabPagerViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _isScrollCausedByDragging = YES;
    _lastOrientation = [UIDevice currentDevice].orientation;
    
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
    UIDeviceOrientation newOrientation = [UIDevice currentDevice].orientation;
    if (self.scrollView.contentSize.width == 0 || self.scrollView.contentSize.height == 0 || newOrientation != _lastOrientation) {
        _lastOrientation = newOrientation;
        for (NSInteger index = 0; index < self.onViewControllers.count; index++) {
            UIViewController *controller = self.onViewControllers[index];
            if ([controller isKindOfClass:[UIViewController class]]) {
                controller.view.hidden = YES;
            }
        }
        self.scrollView.contentSize = CGSizeMake(_vcsNumber * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
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
        if (!exceptSelected)
            [self loadVCs];
    }
}

- (void)callDelegateAtIndex:(NSInteger)index withObject:(NSNumber *)object{
    UIViewController *controller = self.onViewControllers[index];
    if ([controller isKindOfClass:[UIViewController class]]) {
        if ([controller conformsToProtocol:@protocol(MTRTabPagerVCDelegate)]) {
            if ([controller respondsToSelector:@selector(hasBeenSelectedAndShown:)]) {
                [controller performSelector:@selector(hasBeenSelectedAndShown:) withObject:object afterDelay:0];
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
    if (_isScrollCausedByDragging) {
        self.topTabBar.pagerContentOffsetX = scrollView.contentOffset.x;
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

#pragma MTRPagerTabBarDelegate
- (void)showViewAtIndex:(NSInteger)index {
    [self mtrRecycleViewControllers];
    BOOL _firstShown = NO;
    _isScrollCausedByDragging = NO;
    [self.topTabBar checkSelectedTabItemVisible];
    UIViewController *controller = self.onViewControllers[index];
    if ([controller isKindOfClass:[NSNull class]]) {
        controller = [self.vcsSource viewControllerAtIndex:index];
        self.onViewControllers[index] = controller;
        _firstShown = YES;
    }
    CGFloat targetx = index * self.scrollView.bounds.size.width;
    if (controller.parentViewController == nil) {
        [self addChildViewController:controller];
        controller.view.frame = CGRectMake(targetx, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    } else {
        controller.view.frame = CGRectMake(targetx, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        controller.view.hidden = NO;
        [self mtrReloadViewController:controller];
    }
    if (index-1 >= 0) {
        UIViewController *leftController = self.onViewControllers[index-1];
        if ([leftController isKindOfClass:[UIViewController class]] && leftController.parentViewController != nil) {
            CGSize size = self.scrollView.bounds.size;
            leftController.view.frame = CGRectMake(targetx - size.width, 0, size.width, size.height);
            leftController.view.hidden = NO;
            [self mtrReloadViewController:leftController];
        }
    }
    if (index+1 < _vcsNumber) {
        UIViewController *rightController = self.onViewControllers[index+1];
        if ([rightController isKindOfClass:[UIViewController class]] && rightController.parentViewController != nil) {
            CGSize size = self.scrollView.bounds.size;
            rightController.view.frame = CGRectMake(targetx + size.width, 0, size.width, size.height);
            rightController.view.hidden = NO;
            [self mtrReloadViewController:rightController];
        }
    }
    [self.scrollView setContentOffset:CGPointMake(targetx, 0) animated:NO];
    [self callDelegateAtIndex:index withObject:[NSNumber numberWithBool:_firstShown]];
}


#pragma mark - Accessor Methods
- (void)setVcsSource:(id<MTRTabPagerVCsSource>)vcsSource {
    
    _vcsSource = vcsSource;
}

- (MTRPagerTabBar *)topTabBar {
    if (!_topTabBar) {
        _topTabBar = [[MTRPagerTabBar alloc] init];
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

// MTRRecycle
- (NSMutableDictionary *)mtrReusableCellsDic {
    if (!_mtrReusableCellsDic) {
        _mtrReusableCellsDic = [NSMutableDictionary dictionary];
    }
    return _mtrReusableCellsDic;
}

- (NSMutableDictionary *)mtrInUsingCellsDic {
    if (!_mtrInUsingCellsDic) {
        _mtrInUsingCellsDic = [NSMutableDictionary dictionary];
    }
    return _mtrInUsingCellsDic;
}

- (NSMutableDictionary *)mtrCellClassAndReuseIdentifierDic {
    if (!_mtrCellClassAndReuseIdentifierDic) {
        _mtrCellClassAndReuseIdentifierDic = [NSMutableDictionary dictionary];
    }
    return _mtrCellClassAndReuseIdentifierDic;
}

@end

#import "UITableViewCell+MTRRecycle.h"
#import "MTRTableView.h"
@implementation MTRTabPagerViewController (MTRRecycle)

- (void)mtrRegisterClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    self.mtrCellClassAndReuseIdentifierDic[identifier] = cellClass;
}

- (UITableViewCell *)mtrDequeReusableCellForTableView:(MTRTableView *)tableView withReuseIdentifier:(NSString *)identifier {
    NSMutableSet *reusableCells = self.mtrReusableCellsDic[identifier];
    if (reusableCells.count > 0) {
        UITableViewCell *cell = [reusableCells anyObject];
        cell.mtrTableView = tableView;
        NSMutableSet *inUsingCells = self.mtrInUsingCellsDic[identifier];
        if (inUsingCells == nil) {
            inUsingCells = [NSMutableSet set];
            self.mtrInUsingCellsDic[identifier] = inUsingCells;
        }
        [inUsingCells addObject:cell];
        [reusableCells removeObject:cell];
        //[cell prepareForReuse];
        return cell;
    }
    Class cellClass = self.mtrCellClassAndReuseIdentifierDic[identifier];
    if (cellClass == nil)
        return nil;
    UITableViewCell *cell = [[cellClass alloc] init];
    static NSInteger count = 0;
    count++;
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", count];
    cell.mtrTableView = tableView;
    cell.mtrReuseIdentifier = identifier;
    NSMutableSet *inUsingCells = self.mtrInUsingCellsDic[identifier];
    if (inUsingCells == nil) {
        inUsingCells = [NSMutableSet set];
        self.mtrInUsingCellsDic[identifier] = inUsingCells;
    }
    [inUsingCells addObject:cell];
    return cell;
}

- (void)mtrRecycleReusabelCells:(NSArray *)cells {
    if (cells.count > 0) {
        for (UITableViewCell *cell in cells) {
            NSMutableSet *reusableCells = self.mtrReusableCellsDic[cell.mtrReuseIdentifier];
            if (reusableCells == nil) {
                reusableCells = [NSMutableSet set];
                self.mtrReusableCellsDic[cell.mtrReuseIdentifier] = reusableCells;
            }
            cell.mtrTableView = nil;
            [reusableCells addObject:cell];
            NSMutableSet *inUsingCells = self.mtrInUsingCellsDic[cell.mtrReuseIdentifier];
            if (inUsingCells)
                [inUsingCells removeObject:cell];
        }
    }
}

- (void)mtrRecycleViewControllers {
    for (NSInteger i = 0; i < _vcsNumber; i++) {
        UIViewController *controller = self.onViewControllers[i];
        if ([controller isKindOfClass:[UIViewController class]] && [controller conformsToProtocol:@protocol(MTRViewControllerRecycleProtocol)]) {
            NSArray *containerViews = [controller performSelector:@selector(mtrParticipatingContainerViews)];
            if (containerViews.count > 0) {
                for (UIView *view in containerViews) {
                    if ([view isKindOfClass:[MTRTableView class]]) {
                        MTRTableView *tableView = (MTRTableView *)view;
                        [self mtrRecycleReusabelCells:[tableView visibleCells]];
                    }
                }
            }
        }
    }
}

- (void)mtrReloadViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UIViewController class]] && [controller conformsToProtocol:@protocol(MTRViewControllerRecycleProtocol)]) {
        NSArray *containerViews = [controller performSelector:@selector(mtrParticipatingContainerViews)];
        if (containerViews.count > 0) {
            for (UIView *view in containerViews) {
                if ([view isKindOfClass:[MTRTableView class]]) {
                    MTRTableView *tableView = (MTRTableView *)view;
                    [tableView reloadData];
                }
            }
        }
    }
}

@end
