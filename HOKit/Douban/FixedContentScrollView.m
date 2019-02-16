//
//  FixedContentScrollView.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "FixedContentScrollView.h"
#import <pop/POP.h>
#import "NestedTableView.h"
#import "MJRefresh.h"

static NSString *const kDecelerateAnimationKey = @"decelerate";
static NSString *const kBounceAnimationKey = @"bounce";

@interface FixedContentScrollView()<POPAnimatorDelegate>

@property (nonatomic, strong) UIView *scrollIndicatorView;
@property (nonatomic, strong) UIView *scrollIndicatorContainerView;

@property (nonatomic, assign) BOOL isScrollingDown;
@property (nonatomic, assign) CGFloat startTranslationY;
@property (nonatomic, assign) CGFloat lastTranslationY;
@property (nonatomic, assign) CGRect containerViewStartBounds;
@property (nonatomic, assign) CGPoint nestedStartContentOffset;
@property (nonatomic, strong) NestedTableView *nestedScrollView;

@property (nonatomic, assign) BOOL isNestedScrollViewScrolling;


@end

@implementation FixedContentScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (UIView *)scrollIndicatorContainerView {
    if (!_scrollIndicatorContainerView) {
        _scrollIndicatorContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 0)];
        [self addSubview:_scrollIndicatorContainerView];
    }
    return _scrollIndicatorContainerView;
}

- (UIView *)scrollIndicatorView {
    if (!_scrollIndicatorView) {
        _scrollIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 0)];
        _scrollIndicatorView.layer.cornerRadius = 1;
        _scrollIndicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _scrollIndicatorView.alpha = 0;
        [self.scrollIndicatorContainerView addSubview:_scrollIndicatorView];
    }
    return _scrollIndicatorView;
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    _headerView = headerView;
    [self addSubview:_headerView];
}

- (void)setContentView:(UIView *)contentView {
    if (!contentView) {
        self.nestedScrollView = nil;
    }
    _contentView = contentView;
    [self addSubview:_contentView];
}

- (void)setNestedScrollView:(NestedTableView *)nestedScrollView {
    if (nestedScrollView == _nestedScrollView) {
        return;
    }
    if (_nestedScrollView) {
        [_nestedScrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
    _nestedScrollView = nestedScrollView;
    _nestedScrollView.scrollEnabled = NO;
    [_nestedScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:nil];
}

- (CGFloat)nestedScrollViewMaxContentOffsetY {
    return fmax(0, self.nestedScrollView.contentSize.height + self.nestedScrollView.mj_insetB - self.nestedScrollView.bounds.size.height);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [self pop_removeAllAnimations];
    [self.nestedScrollView pop_removeAllAnimations];
    return [super hitTest:point withEvent:event];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.nestedScrollView = [NestedTableView findCurrentNestedScrollViewInView:self.contentView];
            self.containerViewStartBounds = self.bounds;
            self.lastTranslationY = [panGesture translationInView:self].y;
            self.startTranslationY = [panGesture translationInView:self].y;
            self.nestedStartContentOffset = self.nestedScrollView.contentOffset;
            self.isScrollingDown = NO;
            [self showScrollIndicator];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            BOOL gestureInNestedScrollView = [panGesture locationInView:self.nestedScrollView].y > 0;
            _isScrollingDown = [panGesture translationInView:self].y > self.lastTranslationY;
            CGRect bounds = self.bounds;
            if (!_isNestedScrollViewScrolling) {
                if ((gestureInNestedScrollView && _isScrollingDown && self.nestedScrollView.contentOffset.y > 0) ||
                    bounds.origin.y > self.headerView.bounds.size.height ||
                    (bounds.origin.y == self.headerView.bounds.size.height && !_isScrollingDown)) {
                    [self scrollingContentDidChange:YES panGesture:panGesture];
                }
            }else {
                if ((self.nestedScrollView.contentOffset.y == 0 && _isScrollingDown) ||
                    (self.bounds.origin.y < self.headerView.bounds.size.height && !_isScrollingDown)) {
                    [self scrollingContentDidChange:NO panGesture:panGesture];
                }
            }
            
            if (!_isNestedScrollViewScrolling) {
                bounds.origin.y = self.containerViewStartBounds.origin.y - ([panGesture translationInView:self].y - self.startTranslationY);
                if (bounds.origin.y < 0) {
                    bounds.origin.y = bounds.origin.y / 4;
                }
                if (bounds.origin.y > self.headerView.bounds.size.height) {
                    bounds.origin.y = self.headerView.bounds.size.height;
                }
                self.bounds = bounds;
            }else {
                CGPoint newContentOffset = CGPointMake(0, self.nestedStartContentOffset.y - [panGesture translationInView:self].y - self.startTranslationY);
                if (newContentOffset.y < 0) {
                    newContentOffset.y = 0;
                }
                if (newContentOffset.y > [self nestedScrollViewMaxContentOffsetY]) {
                    newContentOffset.y = [self nestedScrollViewMaxContentOffsetY] + (newContentOffset.y - [self nestedScrollViewMaxContentOffsetY]) / 4.0;
                }
                self.nestedScrollView.contentOffset = newContentOffset;
            }
            self.lastTranslationY = [panGesture translationInView:self].y;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat velocityY = -[panGesture velocityInView:self].y;
            if (self.bounds.origin.y >= self.headerView.bounds.size.height || ([panGesture locationInView:self.nestedScrollView].y > 0 && _isScrollingDown && self.nestedScrollView.contentOffset.y > 0)) {
                if (fabs(velocityY) > 0) {
                    POPDecayAnimation *nestedDecayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPTableViewContentOffset];
                    nestedDecayAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, velocityY)];
                    nestedDecayAnimation.delegate = self;
                    [self.nestedScrollView pop_addAnimation:nestedDecayAnimation forKey:kDecelerateAnimationKey];
                }else {
                    [self viewBounceWithVelocity:self.nestedScrollView velocity:0];
                }
            }else {
                POPDecayAnimation *decayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPViewBounds];
                decayAnimation.delegate = self;
                decayAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(0, velocityY, 0, 0)];
                [self pop_addAnimation:decayAnimation forKey:kDecelerateAnimationKey];
            }
            break;
        }
        default:
            break;
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    if (finished) {
        [self hideScrollIndicator];
    }
}

- (void)animatorWillAnimate:(POPAnimator *)animator{}

- (void)animatorDidAnimate:(POPAnimator *)animator{}

- (void)scrollingContentDidChange:(BOOL)isNestedScrollViewScrolling panGesture:(UIPanGestureRecognizer *)panGesture {
    if (_isNestedScrollViewScrolling == isNestedScrollViewScrolling) {
        return;
    }
    _isNestedScrollViewScrolling = isNestedScrollViewScrolling;
    self.containerViewStartBounds = self.bounds;
    self.nestedStartContentOffset = self.nestedScrollView.contentOffset;
    self.startTranslationY = [panGesture translationInView:self].y;
}

- (void)setBounds:(CGRect)bounds {
    if (bounds.origin.y < 0) {
        POPDecayAnimation *containDecayAnimation = [self pop_animationForKey:kDecelerateAnimationKey];
        if (containDecayAnimation) {
            [self viewBounceWithVelocity:self velocity:[containDecayAnimation.velocity CGRectValue].origin.y];
            [self pop_removeAnimationForKey:kDecelerateAnimationKey];
        }
    }else if (bounds.origin.y > self.headerView.bounds.size.height) {
        bounds.origin.y = self.headerView.bounds.size.height;
        [self copyDecayAnimationFromView:self toView:self.nestedScrollView];
    }
    [super setBounds:bounds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.nestedScrollView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        [self layoutScrollIndicator];
        if (self.nestedScrollView.contentOffset.y < 0) {
            [self copyDecayAnimationFromView:self.nestedScrollView toView:self];
            self.nestedScrollView.contentOffset = CGPointZero;
        }else if (self.nestedScrollView.contentOffset.y > [self nestedScrollViewMaxContentOffsetY]) {
            POPDecayAnimation *nestedDecayAnimation = [self.nestedScrollView pop_animationForKey:kDecelerateAnimationKey];
            if (nestedDecayAnimation) {
                [self viewBounceWithVelocity:self.nestedScrollView velocity:[nestedDecayAnimation.velocity CGPointValue].y];
                [self.nestedScrollView pop_removeAnimationForKey:kDecelerateAnimationKey];
            }
        }
    }
}

- (void)viewBounceWithVelocity:(UIView *)view velocity:(CGFloat)velocity {
    velocity = velocity / 2.0;
    POPSpringAnimation *springAnimation;
    if (view == self) {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
        springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        springAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(0, velocity, 0, 0)];
    }else {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPTableViewContentOffset];
        springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, velocity)];
        springAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, [self nestedScrollViewMaxContentOffsetY])];
    }
    springAnimation.springSpeed = 5.0;
    springAnimation.springBounciness = 0;
    springAnimation.delegate = self;
    [view pop_addAnimation:springAnimation forKey:kBounceAnimationKey];
}

- (void)copyDecayAnimationFromView:(UIView *)fromView toView:(UIView *)toView {
    if (!fromView) {
        return;
    }
    POPDecayAnimation *fromDecayAnimation = [fromView pop_animationForKey:kDecelerateAnimationKey];
    if (fromDecayAnimation) {
        if (toView) {
            POPDecayAnimation *toDecayAnimation;
            if (toView == self.nestedScrollView) {
                toDecayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPTableViewContentOffset];
                toDecayAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, [fromDecayAnimation.velocity CGRectValue].origin.y)];
            }else if (toView == self) {
                toDecayAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPViewBounds];
                toDecayAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(0, [fromDecayAnimation.velocity CGPointValue].y, 0, 0)];
            }
            toDecayAnimation.delegate = self;
            [toView pop_addAnimation:toDecayAnimation forKey:kDecelerateAnimationKey];
        }
        [fromView pop_removeAnimationForKey:kDecelerateAnimationKey];
    }
}

- (void)showScrollIndicator {
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollIndicatorView.alpha = 1;
    }];
}

- (void)hideScrollIndicator {
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollIndicatorView.alpha = 0;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.origin.y = self.headerView.bounds.size.height;
    self.contentView.frame = frame;
    
    [self layoutScrollIndicator];
}

- (BOOL)isConentViewFixed {
    return self.bounds.origin.y >= self.headerView.bounds.size.height;
}

- (void)layoutScrollIndicator {
    CGRect frame = self.scrollIndicatorContainerView.frame;
    frame.origin.x = self.bounds.size.width - 3 - frame.size.width;
    frame.origin.y = self.bounds.origin.y;
    frame.size.height = self.bounds.size.height;
    self.scrollIndicatorContainerView.frame = frame;
    [self bringSubviewToFront:self.scrollIndicatorContainerView];
    
    CGFloat contentSizeHeight = self.headerView.bounds.size.height + fmaxf(self.contentView.bounds.size.height, self.nestedScrollView.contentSize.height + self.nestedScrollView.mj_insetB - self.nestedScrollView.bounds.size.height + self.contentView.bounds.size.height);
    CGFloat currentContentOffset = self.bounds.origin.y + self.nestedScrollView.contentOffset.y;
    if ([self isConentViewFixed]) {
        contentSizeHeight -= self.bounds.origin.y;
        currentContentOffset -= self.headerView.bounds.size.height;
    }
    CGFloat maxContentOffsetY = contentSizeHeight - self.bounds.size.height;
    currentContentOffset = fmin(maxContentOffsetY, fmax(0, currentContentOffset));
    if (maxContentOffsetY > 0) {
        self.scrollIndicatorView.hidden = NO;
        CGFloat indicatorHeight = fmax(40, self.bounds.size.height * (self.bounds.size.height / contentSizeHeight));
        frame = self.scrollIndicatorView.frame;
        frame.size.height = indicatorHeight;
        frame.origin.y = currentContentOffset / maxContentOffsetY * (self.bounds.size.height - indicatorHeight);
        self.scrollIndicatorView.frame = frame;
        
        [self bringSubviewToFront:self.scrollIndicatorView];
    }else {
        self.scrollIndicatorView.hidden = YES;
    }
}

- (void)dealloc
{
    if (_nestedScrollView) {
        [_nestedScrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
}


@end
