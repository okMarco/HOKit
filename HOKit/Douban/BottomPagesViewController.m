//
//  BottomPagesViewController.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "BottomPagesViewController.h"
#import "DataListViewController.h"
#import "Masonry.h"

@interface TabPageInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger maxDataCount;

@end

@implementation TabPageInfo

- (instancetype)initWithPageTitle:(NSString *)title maxDataCount:(NSInteger)maxDataCount {
    self = [super init];
    if (self) {
        _title = title;
        _maxDataCount = maxDataCount;
    }
    return self;
}

@end

@interface BottomPagesViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, strong) UIStackView *tabBarView;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray<DataListViewController *> *pages;
@property (nonatomic, strong) NSArray<TabPageInfo *> *pageInfos;
@property (nonatomic, strong) NSArray<UIButton *> *tabBtns;

@end

@implementation BottomPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageInfos = @[[[TabPageInfo alloc] initWithPageTitle:@"回复(100)" maxDataCount:100],
                   [[TabPageInfo alloc] initWithPageTitle:@"点赞(50)" maxDataCount:50],
                   [[TabPageInfo alloc] initWithPageTitle:@"转发(2)" maxDataCount:2],
                   [[TabPageInfo alloc] initWithPageTitle:@"收藏(0)" maxDataCount:0]];
    [self tabBarView];
    [self pageViewController];
}

- (UIStackView *)tabBarView {
    if (!_tabBarView) {
        NSMutableArray *tabBtns = [[NSMutableArray alloc] init];
        for (int i = 0; i < _pageInfos.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitle:_pageInfos[i].title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:25.0 / 255.0 green:25.0 / 255.0 blue:25.0 / 255.0 alpha:1] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor colorWithRed:118.0 / 255.0 green:118.0 / 255.0 blue:118.0 / 255.0 alpha:1] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tabBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [tabBtns addObject:button];
        }
        self.tabBtns = [tabBtns copy];
        _tabBarView = [[UIStackView alloc] initWithArrangedSubviews:tabBtns];
        _tabBarView.distribution = UIStackViewDistributionFillEqually;
        [self.view addSubview:_tabBarView];
        [_tabBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(40);
        }];
        
        UIView *seperatorView = [[UIView alloc] init];
        seperatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        [self.view addSubview:seperatorView];
        [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(1.0 / UIScreen.mainScreen.scale);
            make.bottom.equalTo(self.tabBarView);
        }];
    }
    return _tabBarView;
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.pageInfos.count; i++) {
            DataListViewController *pageVC = [[DataListViewController alloc] init];
            pageVC.maxDataCount = self.pageInfos[i].maxDataCount;
            pageVC.view.tag = i;
            [pages addObject:pageVC];
        }
        _pages = pages.copy;
        
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.tabBarView.mas_bottom);
        }];
        
        [self tabBtnTapped:self.tabBtns[0]];
    }
    return _pageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return viewController.view.tag == 0 ? nil : _pages[viewController.view.tag - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return viewController.view.tag == _pages.count - 1 ? nil : _pages[viewController.view.tag + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self tabSelectedAtIndex:pageViewController.viewControllers.firstObject.view.tag];
    }
}

- (void)tabBtnTapped:(UIButton *)button {
    NSInteger toIndex = button.tag;
    NSInteger currentIndex = self.pageViewController.viewControllers.firstObject.view.tag;
    if (self.pageViewController.viewControllers.count && toIndex == currentIndex) {
        return;
    }
    [self tabSelectedAtIndex:toIndex];
    UIPageViewControllerNavigationDirection direction = toIndex > currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[_pages[toIndex]] direction:direction animated:YES completion:nil];
}

- (void)tabSelectedAtIndex:(NSInteger)index {
    for (UIButton *tmpBtn in self.tabBtns) {
        if ([self.tabBtns indexOfObject:tmpBtn] == index) {
            tmpBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            tmpBtn.selected = YES;
        }else {
            tmpBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            tmpBtn.selected = NO;
        }
    }
}

@end
