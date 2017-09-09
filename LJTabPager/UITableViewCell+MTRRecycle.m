//
//  UITableViewCell+MTRRecycle.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/8.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "UITableViewCell+MTRRecycle.h"
#import <objc/runtime.h>

@implementation UITableViewCell (MTRRecycle)
- (NSInteger)mtrControllerIndex {
    NSNumber *index = objc_getAssociatedObject(self, @selector(mtrControllerIndex));
    if (index == nil)
        return -1;
    return [index integerValue];
}

- (void)setMtrControllerIndex:(NSInteger)mtrControllerIndex {
    NSNumber *index = [NSNumber numberWithInteger:mtrControllerIndex];
    objc_setAssociatedObject(self, @selector(mtrControllerIndex), index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)mtrReuseIdentifier {
    return objc_getAssociatedObject(self, @selector(mtrReuseIdentifier));
}

- (void)setMtrReuseIdentifier:(NSString *)mtrReuseIdentifier {
    objc_setAssociatedObject(self, @selector(mtrReuseIdentifier), mtrReuseIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableView *)mtrTableView {
    return objc_getAssociatedObject(self, @selector(mtrTableView));
}

- (void)setMtrTableView:(MTRTableView *)mtrTableView {
    objc_setAssociatedObject(self, @selector(mtrTableView), mtrTableView, OBJC_ASSOCIATION_ASSIGN);
}
@end
