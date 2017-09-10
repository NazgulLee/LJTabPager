//
//  UITableViewCell+MTRRecycle.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "UITableViewCell+MTRRecycle.h"
#import <objc/runtime.h>

@implementation UITableViewCell (MTRRecycle)
- (MTRTableView *)mtrTableView {
    return objc_getAssociatedObject(self, @selector(mtrTableView));
}
- (void)setMtrTableView:(MTRTableView *)mtrTableView {
    objc_setAssociatedObject(self, @selector(mtrTableView), mtrTableView, OBJC_ASSOCIATION_ASSIGN);
}
- (NSString *)mtrReuseIdentifier {
    return objc_getAssociatedObject(self, @selector(mtrReuseIdentifier));
}
- (void)setMtrReuseIdentifier:(NSString *)mtrReuseIdentifier {
    objc_setAssociatedObject(self, @selector(mtrReuseIdentifier), mtrReuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
