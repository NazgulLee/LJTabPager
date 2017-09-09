//
//  MTRTableView.h
//  LJTabPager
//
//  Created by 李剑 on 2017/9/8.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTRTabPagerReuseDelegate <NSObject>
- (void)mtrRecycleCells:(NSArray *)cells;

@end

@interface MTRTableView : UITableView
@property (nonatomic, weak) id<MTRTabPagerReuseDelegate> reuseDelegate;
//@property (nonatomic, copy) NSString *recycleIdentifier;
@property (nonatomic) BOOL mtrIsDirty;
@property (nonatomic) BOOL pauseRecycling;
@end
