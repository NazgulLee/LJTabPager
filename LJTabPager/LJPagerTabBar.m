//
//  LJPagerTabBar.m
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#define MIN_SPACING 40.0

#define ANIMATE_DURATION 0.25

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
    CGFloat _totalWidth; //所有tabItems的宽度之和
}

@synthesize selectedLineColor = _selectedLineColor;
@synthesize selectedTabItemColor = _selectedTabItemColor;

- (instancetype)initWithTitles:(NSArray *)titles frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.showsHorizontalScrollIndicator = NO;
        _scrollOrientation = SCROLL_ORIENTATION_NONE;
        [self configureViews];
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
    NSInteger direction = 0;
    NSInteger destIndex = -1;
    CGFloat destOffsetx = self.contentOffset.x;
    if (index != self.selectedIndex) {
        destIndex = index < self.selectedIndex ? index-1 : index+1;
        direction = index < self.selectedIndex ? -1 : 1;
    }
    if (destIndex >= 0 && destIndex <self.tabItems.count) {
        UIButton *destTabItem = ((UIButton *)self.tabItems[destIndex]);
        if (direction == -1) {
            destOffsetx = destTabItem.frame.origin.x - self.spacing/2;
        } else if (direction == 1) {
            destOffsetx = destTabItem.frame.origin.x + destTabItem.frame.size.width + self.spacing / 2 - self.bounds.size.width;
        }
    }
    if (destOffsetx < 0)
        destOffsetx = 0;
    if (destOffsetx > self.contentSize.width-self.bounds.size.width)
        destOffsetx = self.contentSize.width-self.bounds.size.width;
    [self highlightTabItemAtIndex:index];
    [self.pagerTabBarDelegate showViewAtIndex:index];
    CGFloat endLineWidth = ((UIButton *)self.tabItems[index]).bounds.size.width;
    CGFloat endCenterX = ((UIButton *)self.tabItems[index]).center.x;
    if (animated) {
        [UIView animateWithDuration:ANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.selectedLine.center = CGPointMake(endCenterX, self.selectedLine.center.y);
            self.selectedLine.bounds = CGRectMake(0, 0, endLineWidth, self.selectedLine.bounds.size.height);
        } completion:NULL];
    } else {
        self.selectedLine.center = CGPointMake(endCenterX, self.selectedLine.center.y);
        self.selectedLine.bounds = CGRectMake(0, 0, endLineWidth, self.selectedLine.bounds.size.height);
    }
    [self animateContentOffset:CGPointMake(destOffsetx, 0) withDuration:ANIMATE_DURATION];
    //[self setContentOffset:CGPointMake(destOffsetx, 0) animated:YES];
}

- (void)highlightTabItemAtIndex:(NSInteger)index {
    [((UIButton *)self.tabItems[self.selectedIndex]) setTitleColor:self.unSelectedColor forState:UIControlStateNormal];
    [((UIButton *)self.tabItems[index]) setTitleColor:self.selectedTabItemColor forState:UIControlStateNormal];
    self.selectedIndex = index;
}

- (NSArray *)tabItemsWithTitles:(NSArray *)titles {
    _totalWidth = 0;
    NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        UIButton *tabItem = [UIButton buttonWithType:UIButtonTypeSystem];
        tabItem.tag = i;
        [tabItem setTitle:title forState:UIControlStateNormal];
        [tabItem setTitleColor:self.unSelectedColor forState:UIControlStateNormal];
        [tabItem setTitleColor:self.selectedTabItemColor forState:UIControlStateSelected];
        [tabItem sizeToFit];
        [tabItem addTarget:self action:@selector(toogleSelectedTabItem:) forControlEvents:UIControlEventTouchUpInside];
        [tabItems addObject:tabItem];
        _totalWidth += tabItem.bounds.size.width;
    }
        return [NSArray arrayWithArray:tabItems];
}

- (void)caculateSpacing {
    self.spacing = (self.bounds.size.width - _totalWidth) / self.titles.count;
    if (self.titles.count == 1 || self.spacing >= MIN_SPACING) {
        self.contentSize = self.bounds.size;
       
    } else {
        NSInteger i;
        CGFloat visibleItemsWidth = _totalWidth;
        for (i = self.tabItems.count - 1; i > 0; i--) {
            visibleItemsWidth -= ((UIButton *)self.tabItems[i]).bounds.size.width / 2; //让最右边的tabItem只显示一半来提示用户还有更多
            self.spacing = (self.bounds.size.width - visibleItemsWidth) * 2 / (2 * i + 1);
            if (self.spacing >= MIN_SPACING) {
                break;
            } else {
                visibleItemsWidth -= ((UIButton *)self.tabItems[i]).bounds.size.width / 2;
            }
        }
        self.contentSize = CGSizeMake(self.spacing * self.titles.count + _totalWidth, self.bounds.size.height);
    }
    self.shadowView.bounds = CGRectMake(0, 0, self.contentSize.width, self.shadowView.bounds.size.height);
}

- (void)recordInitialAndDestX {
    self.tabBarInitialX = self.contentOffset.x;
    if (self.selectedIndex < self.tabItems.count - 2) {
        // 当前选中tabItem的下下个tabItem的右边界加tabItem间隔的一半，再减去屏幕宽度，作为上面的scrollView的至少要有的contentOffset
        self.tabBarRightDestX = ((UIButton *)self.tabItems[self.selectedIndex + 2]).frame.origin.x + ((UIButton *)self.tabItems[self.selectedIndex + 2]).frame.size.width + self.spacing / 2 - self.bounds.size.width;
    }
    if (1 < self.selectedIndex) {
        // 当前选中tabItem的上上个tabItem的左边界减tabItem间隔的一半，作为上面的scrollView的至多应有的contentOffset
        self.tabBarLeftDestX = ((UIButton *)self.tabItems[self.selectedIndex - 2]).frame.origin.x - self.spacing / 2;
    }
}

- (void)checkSelectedTabItemVisible {
    CGFloat selectedTabItemLeftX = ((UIButton *)self.tabItems[self.selectedIndex]).frame.origin.x;
    CGFloat selectedTabItemRightX = ((UIButton *)self.tabItems[self.selectedIndex]).frame.origin.x + ((UIButton *)self.tabItems[self.selectedIndex]).frame.size.width;
    // 若当前选中的tabItem的右边界不在屏幕中
    if (selectedTabItemRightX > self.contentOffset.x + self.bounds.size.width) {
        CGFloat expectedContentOffset = selectedTabItemRightX - self.bounds.size.width / 2;
        CGFloat maxContentOffset = self.contentSize.width - self.bounds.size.width;
        CGFloat result = expectedContentOffset > maxContentOffset ? maxContentOffset : expectedContentOffset;
        //[self setContentOffset:CGPointMake(result, 0) animated:YES];
        [self animateContentOffset:CGPointMake(result, 0) withDuration:ANIMATE_DURATION];
    }
    // 若当前选中的tabItem的左边界不在屏幕中
    if (selectedTabItemLeftX < self.contentOffset.x) {
        CGFloat expectedContentOffset = selectedTabItemLeftX - self.bounds.size.width / 2;
        CGFloat minContentOffset = 0;
        CGFloat result = expectedContentOffset < minContentOffset ? minContentOffset : expectedContentOffset;
        //[self setContentOffset:CGPointMake(result, 0) animated:YES];
        [self animateContentOffset:CGPointMake(result, 0) withDuration:ANIMATE_DURATION];
    }
}

- (void)animateContentOffset:(CGPoint)offset withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentOffset = offset;
    } completion:NULL];
}

#pragma mark - Accessor Methods
/// 根据下面的scrollView的contentOffset的变化来改变selectedLine的位置和长度，以及视情况改变tabBar的contentOffset来保证滑动结束后选中的tabItem的左边或右边能看到有其他的tabItem（如果选中的不是第一个或最后一个）
- (void)setPagerContentOffsetX:(CGFloat)pagerContentOffsetX {
    _pagerContentOffsetX = pagerContentOffsetX;
    NSInteger index = (pagerContentOffsetX + 0.5 * self.bounds.size.width) / self.bounds.size.width; //滑动超过一半就切换高亮的tabItem
    if (index != self.selectedIndex) {
        [self highlightTabItemAtIndex:index];
    }
    
    NSInteger position = pagerContentOffsetX / self.bounds.size.width; //不动或者向右滑时为当前选中的tabItem的index，往左滑时为当前选中的tabItem的左边的index
    if (position == self.tabItems.count - 1) { //防止后面position＋1溢出
        return;
    }
    CGFloat leftTabItemX = ((UIButton *)self.tabItems[position]).center.x; //滑动过程中selectedLine左边的tabItem的位置
    CGFloat rightTabItemX = ((UIButton *)self.tabItems[position + 1]).center.x; //滑动过程中selectedLine右边的tabItem的位置
    CGFloat scale = (pagerContentOffsetX - position * self.bounds.size.width) / self.bounds.size.width;
    CGFloat x = leftTabItemX + scale * (rightTabItemX - leftTabItemX); //计算selectedLine的位置
    self.selectedLine.center = CGPointMake(x, self.selectedLine.center.y);
    CGFloat leftTabItemWidth = ((UIButton *)self.tabItems[position]).bounds.size.width;
    CGFloat rightTabItemWidth = ((UIButton *)self.tabItems[position + 1]).bounds.size.width;
    CGFloat width = leftTabItemWidth + scale * (rightTabItemWidth - leftTabItemWidth); //计算selectedLine的宽度
    self.selectedLine.bounds = CGRectMake(0, 0, width, self.selectedLine.bounds.size.height);
    // scale在0.1到0.9之间才做出改变，防止快速滑动下面的scrollView，selectedLine掠过某个tabItem时scale从0突变为1或者从1突变为0造成tabBar闪烁
    if (0.1 < scale && scale < 0.9) {
        CGFloat newScale = scale * 1 / (0.9 - 0.1) - 0.1 / (0.9 - 0.1);//平滑scale的变化
        if (self.scrollOrientation == SCROLL_ORIENTATION_RIGHT) {
            if (self.tabBarRightDestX > self.contentOffset.x) {
                self.contentOffset = CGPointMake(self.tabBarInitialX + newScale * (self.tabBarRightDestX - self.tabBarInitialX), 0);
            }
        } else if (self.scrollOrientation == SCROLL_ORIENTATION_LEFT) {
            if (self.tabBarLeftDestX < self.contentOffset.x) {
                self.contentOffset = CGPointMake(self.tabBarInitialX - (1 - newScale) * (self.tabBarInitialX - self.tabBarLeftDestX), 0);
            }
        }
    } else {
        self.scrollOrientation = SCROLL_ORIENTATION_NONE;
    }
}

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
        _selectedLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 2, 0, 2)];
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

@end
