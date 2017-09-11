//
//  MTRTableView.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRTableView.h"
#import "UITableViewCell+MTRRecycle.h"

@interface MTRTableView ()
@property (nonatomic, readwrite) BOOL mtrCallingLayoutSubviews;
@end

@implementation MTRTableView
{
    NSArray *_mtrCachedCells;
}

- (void)layoutSubviews {
//    NSArray *presentingCells = [self visibleCells];
//    for (UITableViewCell *cell in presentingCells) {
//        NSLog(@"!!%@", NSStringFromCGRect(cell.frame));
//        if (cell.frame.origin.y != cell.mtrFrame.origin.y)
//            NSLog(@"????cell.frame.origin.y != cell.mtrFrame.origin.y %@", NSStringFromCGRect([cell mtrFrame]));
//    }
    self.mtrCallingLayoutSubviews = YES;
    [super layoutSubviews];
    NSLog(@"%@", [(UIViewController *)[self.nextResponder nextResponder] title]);
    NSArray *presentingCells = [self visibleCells];
    for (UITableViewCell *cell in presentingCells)
        NSLog(@"!!%@", NSStringFromCGRect(cell.frame));
    NSLog(@"-------------------");
    for (UITableViewCell *cell in presentingCells)
        NSLog(@"!!%@", NSStringFromCGRect(cell.mtrFrame));
    if ([self mtrIsClean]) {
        for (UITableViewCell *cell in presentingCells) {
            cell.mtrSuperView = cell.superview;
            if (CGRectIsEmpty(cell.mtrFrame))
                cell.mtrFrame = cell.frame;
            // 屏幕旋转可能引起tableview调整visibleCells的frame（在layoutSubviews前完成），若visibleCells已被复用，则可能引起问题。
            else if (cell.mtrFrame.size.width != cell.frame.size.width){
                CGRect newFrame = cell.frame;
                newFrame.origin = cell.mtrFrame.origin;
                cell.frame = newFrame;
                cell.mtrFrame = newFrame;
            }
        }
    }
    NSLog(@"-------------------");
    for (UITableViewCell *cell in presentingCells)
        NSLog(@"!!%@", NSStringFromCGRect(cell.frame));
//    else {
//        
//        for (UITableViewCell *cell in presentingCells)
//            cell.frame = cell.mtrFrame;
//    }
    
    NSMutableSet *mtrCachedCellSet = [NSMutableSet setWithArray:_mtrCachedCells];
    NSSet *presentingCellsSet = [NSSet setWithArray:presentingCells];

    [mtrCachedCellSet minusSet:presentingCellsSet];
    NSMutableSet *deleteSet = [NSMutableSet set];
    for (UITableViewCell *cell in mtrCachedCellSet) {
        // mtrTableView为nil说明已回收，mtrTableView != self说明cell已被其他tableview复用
        if (cell.mtrTableView == nil || cell.mtrTableView != self)
            [deleteSet addObject:cell];
        // cell已被其他tableview复用但是被原来的tableview发送了removeFromSuperview消息
        if (cell.superview == nil && cell.mtrTableView != self) {
            [cell.mtrSuperView addSubview:cell];
        }
    }
    [mtrCachedCellSet minusSet:deleteSet];
    if (mtrCachedCellSet.count > 0)
        [self.mtrRecycleDelegate mtrRecycleReusabelCells:[mtrCachedCellSet allObjects]];
    _mtrCachedCells = presentingCells;
    self.mtrCallingLayoutSubviews = NO;
}

- (BOOL)mtrIsClean {
    for (UITableViewCell *cell in self.visibleCells) {
        if (cell.mtrTableView != self)
            return NO;
    }
    return YES;
}

@end
