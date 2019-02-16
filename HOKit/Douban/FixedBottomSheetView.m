//
//  FixedBottomSheetView.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "FixedBottomSheetView.h"
#import "Masonry.h"
#import <pop/POP.h>
#import "NestedTableView.h"

static NSString *const kBounceAnimationKey = @"bounce";

@interface FixedBottomSheetView()
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIView *roundCornerBgView;
@property (nonatomic, strong) NestedTableView *nestedScrollVIew;

@property (nonatomic, assign) CGFloat lastTranslationY;
@property (nonatomic, assign) BOOL shouldNestedScrollViewScroll;

@property (nonatomic, assign) CGFloat maxOriginY;


@end

@implementation FixedBottomSheetView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.bottomBarView];
    [self bringSubviewToFront:self.indicatorView];
    
    self.roundCornerBgView.frame = CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width, self.bounds.size.height);
    self.bottomBarView.frame = CGRectMake(0, self.bounds.size.height - self.bottomBarView.frame.size.height + self.bounds.origin.y, self.bounds.size.width, self.bottomBarView.frame.size.height);
    self.contentView.frame = CGRectMake(0, self.roundCornerBgView.frame.origin.y + 10, self.bounds.size.width, self.bounds.size.height - self.bottomBarView.bounds.size.height - _paddingTop - 10);
    self.maxOriginY = self.contentView.bounds.size.height - 50 + 10 + self.bottomBarView.bounds.size.height;
}

- (UIView *)roundCornerBgView {
    if (!_roundCornerBgView) {
        _roundCornerBgView = [[UIView alloc] init];
        _roundCornerBgView.backgroundColor = [UIColor whiteColor];
        _roundCornerBgView.layer.cornerRadius = 20;
        _roundCornerBgView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
        _roundCornerBgView.layer.shadowOpacity = 1;
        _roundCornerBgView.layer.shadowRadius = 5;
        [self addSubview:_roundCornerBgView];
    }
    return _roundCornerBgView;
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        _indicatorView.layer.cornerRadius = 2.0;
        [self addSubview:_indicatorView];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.roundCornerBgView).offset(10);
            make.height.mas_equalTo(5);
            make.width.mas_equalTo(40);
        }];
    }
    return _indicatorView;
}

- (void)setContentView:(UIView *)contentView {
    if (!contentView) {
        self.nestedScrollVIew = nil;
    }
    _contentView = contentView;
    [self addSubview:_contentView];
}

- (void)setNestedScrollVIew:(NestedTableView *)nestedScrollVIew {
    if (_nestedScrollVIew) {
        [_nestedScrollVIew removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
    _nestedScrollVIew = nestedScrollVIew;
    _nestedScrollVIew.scrollEnabled = YES;
    [_nestedScrollVIew addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setBottomBarView:(UIView *)bottomBarView {
    _bottomBarView = bottomBarView;
    [self insertSubview:bottomBarView belowSubview:self.indicatorView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitedView = [super hitTest:point withEvent:event];
    if (hitedView == self) {
        return nil;
    }
    return hitedView;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGFloat currentTranslationY = [panGesture translationInView:self].y;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self pop_removeAllAnimations];
            self.nestedScrollVIew = [NestedTableView findCurrentNestedScrollViewInView:self.contentView];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!_shouldNestedScrollViewScroll) {
                if (self.bounds.origin.y >= _maxOriginY) {
                    self.shouldNestedScrollViewScroll = YES;
                }
            }else {
                if (self.nestedScrollVIew.contentOffset.y <= 0) {
                    self.shouldNestedScrollViewScroll = NO;
                }
            }
            
            CGRect bounds = self.bounds;
            if (_shouldNestedScrollViewScroll) {
                bounds.origin.y = _maxOriginY;
            }else {
                CGFloat dy = currentTranslationY - _lastTranslationY;
                bounds.origin.y -= dy;
                if (bounds.origin.y > _maxOriginY) {
                    bounds.origin.y = _maxOriginY;
                }
            }
            self.bounds = bounds;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat velocityY = [panGesture velocityInView:self].y;
            CGFloat finalOriginY;
            if (self.bounds.origin.y < self.bounds.size.height / 2.0) {
                if (velocityY < -100) {
                    finalOriginY = self.bounds.size.height - 50;
                }else {
                    finalOriginY = 0;
                }
            }else {
                if (velocityY > 100) {
                    finalOriginY = 0;
                }else {
                    finalOriginY = self.bounds.size.height - 50;
                }
            }
            if (self.bounds.origin.y != finalOriginY) {
                POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
                springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, finalOriginY, self.bounds.size.width, self.bounds.size.height)];
                springAnimation.springBounciness = 0;
                springAnimation.springSpeed = 5.0;
                springAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(0, velocityY, 0, 0)];
                [self pop_addAnimation:springAnimation forKey:kBounceAnimationKey];
            }
            break;
        }
        default:
            break;
    }
    self.lastTranslationY = currentTranslationY;
}

- (void)setBounds:(CGRect)bounds {
    if (bounds.origin.y > _maxOriginY || self.nestedScrollVIew.contentOffset.y > 0) {
        [self pop_removeAnimationForKey:kBounceAnimationKey];
        bounds.origin.y = _maxOriginY;
    }
    CGFloat alpha = 0.2 * bounds.origin.y / (self.bounds.size.height - 50);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
    [super setBounds:bounds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        if (!_shouldNestedScrollViewScroll) {
            if (self.nestedScrollVIew.contentOffset.y != 0) {
                self.nestedScrollVIew.contentOffset = CGPointZero;
            }
        }
    }
}

- (void)dealloc
{
    if (_nestedScrollVIew) {
        [_nestedScrollVIew removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
}

@end
