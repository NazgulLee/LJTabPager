//
//  MTRTableView.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRTableView.h"
#import "UITableViewCell+MTRRecycle.h"

@implementation MTRTableView
{
    NSArray *_mtrCachedCells;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *presentingCells = [self visibleCells];
    NSMutableSet *mtrCachedCellSet = [NSMutableSet setWithArray:_mtrCachedCells];
    NSSet *presentingCellsSet = [NSSet setWithArray:presentingCells];
    [mtrCachedCellSet minusSet:presentingCellsSet];
    NSMutableSet *deleteSet = [NSMutableSet set];
    for (UITableViewCell *cell in mtrCachedCellSet) {
        if (cell.mtrTableView == nil || cell.mtrTableView != self)
            [deleteSet addObject:cell];
    }
    [mtrCachedCellSet minusSet:deleteSet];
    if (mtrCachedCellSet.count > 0)
        [self.mtrRecycleDelegate mtrRecycleReusabelCells:[mtrCachedCellSet allObjects]];
    _mtrCachedCells = presentingCells;
}

@end
