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
    BOOL isScrollCausedByDragging;//下方的scrollView滑动是因为用户直接滑动还是因为用户点选topTabBar的tabItem导致的
    NSInteger selectedControllerIndex;
    CGFloat initialContentOffsetX;//一次滑动开始时scrollView的contentOffset
}

@synthesize topTabBar = _topTabBar;
@synthesize titles = _titles;
@synthesize tabBarBKColor = _tabBarBKColor;
@synthesize selectedLineColor = _selectedLineColor;
@synthesize selectedTabItemColor = _selectedTabItemColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isScrollCausedByDragging = YES;
    selectedControllerIndex = self.topTabBar.selectedIndex;
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; //告诉viewController不要自动调整scrollview的contentInset
    
    [self.view addSubview:self.scrollView];
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

- (void)updateTitles {
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *controller = self.viewControllers[i];
        [titles addObject:controller.title];
    }
    self.titles = [NSArray arrayWithArray:titles];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (isScrollCausedByDragging) {
        self.topTabBar.pagerContentOffsetX = scrollView.contentOffset.x;
    }
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
    [self callDelegateAtIndex:index]; // 用户滑动到其他viewController时调用，或者用户直接点选tabItem来切换viewController时调用（点选当前选中的tabItem也会调用）
}

#pragma mark - Accessor Methods

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

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers.count > 0) {
        for (int i = 0; i < _viewControllers.count; i++) {
            UIViewController *controller = _viewControllers[i];
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
        _viewControllers = nil;
    }
    _viewControllers = viewControllers;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * viewControllers.count, self.view.bounds.size.height);
    for (int i = 0; i < viewControllers.count; i++) {
        UIViewController *controller = viewControllers[i];
        [self addChildViewController:controller];
        controller.view.frame = CGRectMake(self.scrollView.bounds.size.width * i, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
    }
    
    [self updateTitles];
    
    [self.topTabBar removeFromSuperview];
    [self.view addSubview:self.topTabBar]; //解决先设置selectedLine颜色，再设置viewControllers产生的奇怪的bug
    //[self.view setNeedsDisplay];
    
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

- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    _selectedLineColor = selectedLineColor;
    self.topTabBar.selectedLineColor = selectedLineColor;
}

- (UIColor *)selectedLineColor {
    if (!_selectedLineColor) {
        _selectedLineColor = self.topTabBar.selectedLineColor;
    }
    return _selectedLineColor;
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

//- (void)setTitles:(NSArray *)titles {
//    _titles = titles;
//    self.topTabBar.titles = titles;
//}

+ (CGFloat)pagerTabBarHeight {
    return PAGERTABBAR_HEIGHT;
}

- (NSInteger)selectedIndex {
    return self.topTabBar.selectedIndex;
}

@end
