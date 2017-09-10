//
//  MTRViewController.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRViewController.h"
#import "MTRTableView.h"
#import "MTRTabPagerViewController.h"

@interface MTRViewController () <UITableViewDataSource>
@property (nonatomic) MTRTableView *tableView;
@end

@implementation MTRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.tableView}]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView.mtrRecycleDataSource mtrDequeReusableCellForTableView:self.tableView withReuseIdentifier:@"cell"];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    //cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

- (NSArray *)mtrParticipatingContainerViews {
    return @[self.tableView];
}

- (MTRTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MTRTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.mtrRecycleDelegate = [MTRTabPagerViewController sharedInstance];
        _tableView.mtrRecycleDataSource = [MTRTabPagerViewController sharedInstance];
        [_tableView.mtrRecycleDataSource mtrRegisterClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
    }
    return _tableView;
}

@end
