//
//  FixedBottomSheetView.h
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FixedBottomSheetView : UIView

@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *bottomBarView;


@end

NS_ASSUME_NONNULL_END
