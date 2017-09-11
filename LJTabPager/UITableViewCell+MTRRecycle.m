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
- (UIView *)mtrSuperView {
    return objc_getAssociatedObject(self, @selector(mtrSuperView));
}
- (void)setMtrSuperView:(UIView *)mtrSuperView {
    objc_setAssociatedObject(self, @selector(mtrSuperView), mtrSuperView, OBJC_ASSOCIATION_ASSIGN);
}
- (CGRect)mtrFrame {
    NSValue *frameValue = objc_getAssociatedObject(self, @selector(mtrFrame));
    return [frameValue CGRectValue];
}
- (void)setMtrFrame:(CGRect)mtrFrame {
    NSValue *frameValue = [NSValue valueWithCGRect:mtrFrame];
    objc_setAssociatedObject(self, @selector(mtrFrame), frameValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
