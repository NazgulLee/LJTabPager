//
//  LJPagerTabBar.m
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#define MIN_SPACING 40.0

#import "LJPagerTabBar.h"

@interface LJPagerTabBar ()

@property (nonatomic) NSArray *tabItems;
@property (nonatomic) UIView *selectedLine;
@property (nonatomic) UIView *shadowView;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGFloat tabBarInitialX;
@property (nonatomic) CGFloat tabBarLeftDestX;
@property (nonatomic) CGFloat tabBarRightDestX;

@end

@implementation LJPagerTabBar
{
    CGFloat totalWidth; //所有tabItems的宽度之和
}

@synthesize selectedLineColor = _selectedLineColor;
@synthesize selectedTabItemColor = _selectedTabItemColor;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithTitles:(NSArray *)titles frame: (CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        NSLog(@"frame: %@", NSStringFromCGRect(frame));
        self.showsHorizontalScrollIndicator = NO;
        _scrollOrientation = SCROLL_ORIENTATION_NONE;
        [self configureViews];
        //self.bounces = NO;
        if (titles.count > 0) {
            self.titles = titles;
            [self layoutTabItems];
        }
    }
    return self;
}

- (void)configureViews {

    [self addSubview:self.shadowView];
    
    [self addSubview:self.selectedLine];
}

- (void)layoutTabItems {
    [self caculateSpacing];
    CGFloat distanceToLeftEdge = self.spacing / 2;
    for (int i = 0; i < self.tabItems.count; i++) {
        UIButton *tabItem = self.tabItems[i];
        distanceToLeftEdge += tabItem.bounds.size.width + (i > 0 ? self.spacing : 0);
        tabItem.center = CGPointMake(distanceToLeftEdge - tabItem.bounds.size.width / 2, self.bounds.size.height / 2);
        [self addSubview:tabItem];
    }
    
    [self selectTabItemAtIndex:self.selectedIndex animated:NO];
}

- (void)toogleSelectedTabItem:(UIButton *)tabItem {
    [self selectTabItemAtIndex:tabItem.tag animated:YES];
}

- (void)selectTabItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    //CGFloat startLineWidth = ((UIButton *)self.tabItems[self.selectedIndex]).bounds.size.width;
    [self highlightTabItemAtIndex:index];
    [self.pagerTabBarDelegate showViewAtIndex:index];
    CGFloat endLineWidth = ((UIButton *)self.tabItems[index]).bounds.size.width;
    CGFloat endCenterX = ((UIButton *)self.tabItems[index]).center.x;
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.selectedLine.center = CGPointMake(endCenterX, self.selectedLine.center.y);
            self.selectedLine.bounds = CGRectMake(0, 0, endLineWidth, self.selectedLine.bounds.size.height);
        } completion:NULL];
    } else {
        self.selectedLine.center = CGPointMake(endCenterX, self.selectedLine.center.y);
        self.selectedLine.bounds = CGRectMake(0, 0, endLineWidth, self.selectedLine.bounds.size.height);
    }
    
}

- (void)highlightTabItemAtIndex:(NSInteger)index {
    
    [((UIButton *)self.tabItems[self.selectedIndex]) setTitleColor:self.unSelectedColor forState:UIControlStateNormal];
    [((UIButton *)self.tabItems[index]) setTitleColor:self.selectedTabItemColor forState:UIControlStateNormal];
    self.selectedIndex = index;
}

- (NSArray *)tabItemsWithTitles:(NSArray *)titles {
    totalWidth = 0;
    NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        UIButton *tabItem = [UIButton buttonWithType:UIButtonTypeSystem];
        tabItem.tag = i;
        [tabItem setTitle:title forState:UIControlStateNormal];
        //tabItem.titleLabel.textColor = [UIColor blackColor]; // 无效
        [tabItem setTitleColor:self.unSelectedColor forState:UIControlStateNormal];
        [tabItem setTitleColor:self.selectedTabItemColor forState:UIControlStateSelected];
        [tabItem sizeToFit];
        [tabItem addTarget:self action:@selector(toogleSelectedTabItem:) forControlEvents:UIControlEventTouchUpInside];
        //tabItem.backgroundColor = [UIColor redColor];
        [tabItems addObject:tabItem];
        NSLog(@"tabItem.frame: %@", NSStringFromCGRect(tabItem.frame));
        totalWidth += tabItem.bounds.size.width;
    }
        return [NSArray arrayWithArray:tabItems];
}

- (void)caculateSpacing {
    self.spacing = (self.bounds.size.width - totalWidth) / self.titles.count;
    NSLog(@"spacing: %f", self.spacing);
    if (self.titles.count == 1 || self.spacing >= MIN_SPACING) {
        self.contentSize = self.bounds.size;
       
    } else {
        NSInteger i;
        CGFloat visibleItemsWidth = totalWidth;
        for (i = self.tabItems.count - 1; i > 0; i--) {
            NSLog(@"i: %ld", i);
            visibleItemsWidth -= ((UIButton *)self.tabItems[i]).bounds.size.width / 2; //让最右边的tabItem只显示一半来提示用户还有更多
            self.spacing = (self.bounds.size.width - visibleItemsWidth) * 2 / (2 * i + 1);
            if (self.spacing >= MIN_SPACING) {
                break;
            } else {
                visibleItemsWidth -= ((UIButton *)self.tabItems[i]).bounds.size.width / 2;
                
            }
        }
        NSLog(@"spacing: %f\ni: %ld", self.spacing, (long)i);
        self.contentSize = CGSizeMake(self.spacing * self.titles.count + totalWidth, self.bounds.size.height);
    }
    NSLog(@"contentsize: %@", NSStringFromCGSize(self.contentSize));
    self.shadowView.bounds = CGRectMake(0, 0, self.contentSize.width, self.shadowView.bounds.size.height);
}

- (void)recordInitialAndDestX {
    self.tabBarInitialX = self.contentOffset.x;
    self.scrollOrientation = SCROLL_ORIENTATION_NONE;
    if (self.selectedIndex < self.tabItems.count - 2) {
        
        self.tabBarRightDestX = ((UIButton *)self.tabItems[self.selectedIndex + 2]).frame.origin.x + ((UIButton *)self.tabItems[self.selectedIndex + 2]).frame.size.width + self.spacing / 2 - self.bounds.size.width;
    }
    if (1 < self.selectedIndex) {
        self.tabBarLeftDestX = ((UIButton *)self.tabItems[self.selectedIndex - 2]).frame.origin.x - self.spacing / 2;
    }
    
    NSLog(@"tabBarInitialX: %f", self.tabBarInitialX);
    NSLog(@"tabBarRightDestX: %f", self.tabBarRightDestX);
    NSLog(@"tabBarLeftDestX: %f", self.tabBarLeftDestX);

}

- (void)checkSelectedTabItemVisible {
    CGFloat selectedTabItemLeftX = ((UIButton *)self.tabItems[self.selectedIndex]).frame.origin.x;
    CGFloat selectedTabItemRightX = ((UIButton *)self.tabItems[self.selectedIndex]).frame.origin.x + ((UIButton *)self.tabItems[self.selectedIndex]).frame.size.width;
    if (selectedTabItemRightX > self.contentOffset.x + self.bounds.size.width) {
        CGFloat result = selectedTabItemRightX - self.bounds.size.width / 2 > self.contentSize.width - self.bounds.size.width ? self.contentSize.width - self.bounds.size.width : selectedTabItemRightX - self.bounds.size.width / 2;
        [self setContentOffset:CGPointMake(result, 0) animated:YES];
    }
    if (selectedTabItemLeftX < self.contentOffset.x) {
        CGFloat result = selectedTabItemLeftX - self.bounds.size.width / 2 < 0 ? 0 : selectedTabItemLeftX - self.bounds.size.width / 2;
        [self setContentOffset:CGPointMake(result, 0) animated:YES];
    }
}

#pragma mark - Accessor Methods

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    if (self.tabItems.count > 0) {
        NSInteger n = self.tabItems.count;
        for (NSInteger i = 0; i < n; i++) {
            [self.tabItems[i] removeFromSuperview];
        }
    }
    self.tabItems = [self tabItemsWithTitles:titles];
    [self layoutTabItems];
}

- (UIColor *)selectedLineColor {
    if (!_selectedLineColor) {
        _selectedLineColor = [UIColor colorWithRed:235/255.0 green:69/255.0 blue:47/255.0 alpha:1];
    }
    return _selectedLineColor;
}

- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    _selectedLineColor = selectedLineColor;
    self.selectedLine.backgroundColor = selectedLineColor;
}

- (UIColor *)selectedTabItemColor {
    if (!_selectedTabItemColor) {
        _selectedTabItemColor = [UIColor colorWithRed:235/255.0 green:69/255.0 blue:47/255.0 alpha:1];
    }
    return _selectedTabItemColor;
}

- (void)setSelectedTabItemColor:(UIColor *)selectedTabItemColor {
    _selectedTabItemColor = selectedTabItemColor;
    if (self.tabItems.count > 0) {
        [((UIButton *)self.tabItems[self.selectedIndex]) setTitleColor:self.selectedTabItemColor forState:UIControlStateNormal];
    }
}

- (UIColor *)unSelectedColor {
    if (!_unSelectedColor) {
        _unSelectedColor = [UIColor blackColor];
    }
    return _unSelectedColor;
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
}

- (NSInteger)selectedIndex {
    if (!_selectedIndex) {
        _selectedIndex = 0;
    }
    return _selectedIndex;
}
- (UIView *)selectedLine {
    if (!_selectedLine) {
        //((UIButton *)self.tabItems[0]).bounds.size.width
        _selectedLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 2, 0, 2)];
        NSLog(@"selectedline center: %@", NSStringFromCGPoint(_selectedLine.center));
        _selectedLine.backgroundColor = self.selectedLineColor;
    }
    return _selectedLine;
}

- (CGFloat)tabBarLeftDestX {
    if (!_tabBarLeftDestX) {
        _tabBarLeftDestX = 0;
    }
    return _tabBarLeftDestX;
}

- (CGFloat)tabBarRightDestX {
    if (!_tabBarRightDestX) {
        _tabBarRightDestX = self.contentSize.width - self.bounds.size.width;
    }
    return _tabBarRightDestX;
}
- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
        _shadowView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
    }
    return _shadowView;
}

- (void)setPagerContentOffsetX:(CGFloat)pagerContentOffsetX {
    _pagerContentOffsetX = pagerContentOffsetX;
    NSInteger index = (pagerContentOffsetX + 0.5 * self.bounds.size.width) / self.bounds.size.width; //滑动超过一半就切换高亮的tabItem
    if (index != self.selectedIndex) {
        [self highlightTabItemAtIndex:index];
    }
    
    NSInteger position = pagerContentOffsetX / self.bounds.size.width; // selectedLine左边的tabItem的index
    if (position == self.tabItems.count - 1) { //防止后面position＋1溢出
        self.selectedLine.center = CGPointMake(((UIButton *)self.tabItems[position]).center.x, self.selectedLine.center.y);
        self.selectedLine.bounds = CGRectMake(0, 0, ((UIButton *)self.tabItems[position]).bounds.size.width, self.selectedLine.bounds.size.height);
        return;
    }
    CGFloat leftTabItemX = ((UIButton *)self.tabItems[position]).center.x; //selectedLine左边的tabItem的位置
    CGFloat rightTabItemX = ((UIButton *)self.tabItems[position + 1]).center.x; //selectedLine右边的tabItem的位置
    CGFloat scale = (pagerContentOffsetX - position * self.bounds.size.width) / self.bounds.size.width;
    NSLog(@"scale: %f", scale);
    NSLog(@"position: %ld", position);
    CGFloat x = leftTabItemX + scale * (rightTabItemX - leftTabItemX); //计算selectedLine的位置
    self.selectedLine.center = CGPointMake(x, self.selectedLine.center.y);
    CGFloat leftTabItemWidth = ((UIButton *)self.tabItems[position]).bounds.size.width;
    CGFloat rightTabItemWidth = ((UIButton *)self.tabItems[position + 1]).bounds.size.width;
    CGFloat width = leftTabItemWidth + scale * (rightTabItemWidth - leftTabItemWidth); //计算selectedLine的宽度
    self.selectedLine.bounds = CGRectMake(0, 0, width, self.selectedLine.bounds.size.height);
    
    if (0 < scale && scale < 1) {
        if (self.scrollOrientation == SCROLL_ORIENTATION_RIGHT) {
            if (self.tabBarRightDestX > self.contentOffset.x) {
                self.contentOffset = CGPointMake(self.tabBarInitialX + scale * (self.tabBarRightDestX - self.tabBarInitialX), 0);
            }
        } else if (self.scrollOrientation == SCROLL_ORIENTATION_LEFT) {
            if (self.tabBarLeftDestX < self.contentOffset.x) {
                self.contentOffset = CGPointMake(self.tabBarInitialX - (1 - scale) * (self.tabBarInitialX - self.tabBarLeftDestX), 0);
            }
        }
    }


}


@end
