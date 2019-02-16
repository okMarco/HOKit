//
//  DataListViewController.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "DataListViewController.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "NestedTableView.h"

@interface DataListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) NSInteger dataCount;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NestedTableView *tableView;

@end

@implementation DataListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = @[@"Just like the real UIScrollView, our class has a contentSize property that must be set from the outside to define the extent of the scrollable area. When we adjust the bounds, we make sure to only allow valid values.",
              @"The frame rectangle … describes the view’s location and size in its superview’s coordinate system.",
              @"It looks as though the view has moved down by 100 points, and this is in fact true in relation to its own coordinate system. The view’s actual position on the screen (or in its superview, to put it more accurately) remains fixed, however, as that is determined by its frame, which has not changed:",
              @"Next, we will modify the origin of the bounds rectangle:",
              @"当我们修改一个View的bounds时，View在其本身的坐标系中的位置发生了改变，但是其子View在该坐标系中的位置没有改变，所以它的子View和它本身的相对位置发生了改变，相当于子View移动了，但是子View的frame并没有改变。"];
    _dataCount = 15;
    if (_maxDataCount > 0) {
        [self tableView];
    }else {
        self.emptyLabel.hidden = NO;
    }
}

- (NestedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[NestedTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 100;
        _tableView.estimatedSectionFooterHeight = _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.tableFooterView = [UIView new];
        __weak typeof(self) weakSelf = self;
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.tableView.mj_footer endRefreshing];
                strongSelf.dataCount += 20;
                if (strongSelf.dataCount > strongSelf.maxDataCount) {
                    strongSelf.dataCount = strongSelf.maxDataCount;
                    [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [strongSelf.tableView reloadData];
            });
        }];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.hidden = YES;
        _emptyLabel.text = @"暂无数据";
        _emptyLabel.font = [UIFont boldSystemFontOfSize:15];
        _emptyLabel.textColor = [UIColor grayColor];
        [self.view addSubview:_emptyLabel];
        [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(10);
        }];
    }
    return _emptyLabel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataCount >= _maxDataCount) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    return fmin(_dataCount, _maxDataCount);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = _data[indexPath.row % _data.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
