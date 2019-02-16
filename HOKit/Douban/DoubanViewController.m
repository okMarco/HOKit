//
//  DoubanViewController.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "DoubanViewController.h"
#import "FixedContentScrollView.h"
#import "FixedBottomSheetView.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>
#import "BottomPagesViewController.h"

@interface DoubanViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) FixedContentScrollView *contianerView;
@property (nonatomic, strong) FixedBottomSheetView *bottomSheetView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) BottomPagesViewController *bottomPageVC;

@end

@implementation DoubanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bottomSheetView.contentView = self.bottomPageVC.view;
    [self.loadingView startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/feafce8dec5b"]]];
}

- (FixedContentScrollView *)contianerView {
    if (!_contianerView) {
        _contianerView = [[FixedContentScrollView alloc] init];
        [_contianerView addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionNew context:nil];
        [self.view addSubview:_contianerView];
        [_contianerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    return _contianerView;
}

- (FixedBottomSheetView *)bottomSheetView {
    if (!_bottomSheetView) {
        _bottomSheetView = [[FixedBottomSheetView alloc] initWithFrame:self.view.bounds];
        _bottomSheetView.paddingTop = UIApplication.sharedApplication.statusBarFrame.size.height + 44;
        [self.view addSubview:_bottomSheetView];
    }
    return _bottomSheetView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1];
        self.contianerView.headerView = _headerView;
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contianerView);
        }];
        
        [_headerView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.headerView).insets(UIEdgeInsetsMake(0, 0, 10, 0));
            make.height.mas_greaterThanOrEqualTo(200);
        }];
    }
    return _headerView;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.hidesWhenStopped = YES;
        [self.headerView addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.headerView);
        }];
    }
    return _loadingView;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
        [_webView.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:nil];
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (BottomPagesViewController *)bottomPageVC {
    if (!_bottomPageVC) {
        _bottomPageVC = [[BottomPagesViewController alloc] init];
        _bottomPageVC.view.frame = CGRectMake(0, 0, self.contianerView.bounds.size.width, self.contianerView.bounds.size.height);
        [self addChildViewController:_bottomPageVC];
    }
    return _bottomPageVC;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.loadingView stopAnimating];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.webView.scrollView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.webView.scrollView.contentSize.height);
        }];
        if (self.webView.scrollView.contentSize.height > self.contianerView.bounds.size.height) {
            [self layoutContentView:YES];
        }else {
            [self layoutContentView:NO];
        }
    }
    if (object == self.contianerView && [keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
        if (self.contianerView.bounds.origin.y < self.contianerView.headerView.bounds.size.height - self.contianerView.bounds.size.height + 40) {
            [self layoutContentView:YES];
        }else {
            [self layoutContentView:NO];
        }
    }
}

- (void)layoutContentView:(BOOL)inBottomSheet {
    if (inBottomSheet) {
        self.bottomSheetView.contentView = self.bottomPageVC.view;
        self.contianerView.contentView = nil;
        self.bottomSheetView.hidden = NO;
    }else {
        self.contianerView.contentView = self.bottomPageVC.view;
        self.bottomSheetView.contentView = nil;
        self.bottomSheetView.hidden = YES;
    }
}

@end
