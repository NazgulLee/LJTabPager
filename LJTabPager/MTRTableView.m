//
//  MTRTableView.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/8.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRTableView.h"
#import "UITableViewCell+MTRRecycle.h"

@implementation MTRTableView
{
    NSMutableSet *_cachedPresentingCells;
}

- (void)layoutSubviews {
    [super layoutSubviews]; //[self registerClass:<#(nullable Class)#> forCellReuseIdentifier:<#(nonnull NSString *)#>]
    if (self.superview) {
        CGRect rect = [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].delegate.window];
        if (rect.origin.x+rect.size.width > 0 && rect.origin.x < [UIScreen mainScreen].bounds.size.width) {
            if (!self.pauseRecycling) {
                NSArray *presentingCellsPaths = [self indexPathsForVisibleRows];
                NSMutableSet *presentingCells = [NSMutableSet set];
                for (NSIndexPath *path in presentingCellsPaths)
                    [presentingCells addObject:[self cellForRowAtIndexPath:path]];
                if (_cachedPresentingCells.count != 0) {
                    [_cachedPresentingCells minusSet:presentingCells];
                    NSMutableSet *deleteSet = [NSMutableSet set];
                    for (UITableViewCell *cell in _cachedPresentingCells) {
                        if (cell.mtrTableView && cell.mtrTableView != self)
                            [deleteSet addObject:cell];
                    }
                    [_cachedPresentingCells minusSet:deleteSet];
                    NSArray *reusableCells = [_cachedPresentingCells allObjects];
                    if (reusableCells.count > 0 && self.reuseDelegate && [self.reuseDelegate respondsToSelector:@selector(mtrRecycleCells:)])
                        [self.reuseDelegate mtrRecycleCells:reusableCells];
                }
                _cachedPresentingCells = presentingCells;
            }
        }
    }
    
    
    
}

@end
