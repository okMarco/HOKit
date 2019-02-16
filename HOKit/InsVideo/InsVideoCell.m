//
//  InsVideoCell.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "InsVideoCell.h"
#import "Ins3DFlowLayout.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface InsVideoCell()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation InsVideoCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _imageView;
}

- (void)setImageUrl:(NSString *)imageUrl {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    Ins3DLayoutAttributes *ins3DLayoutAttributes = (Ins3DLayoutAttributes *)layoutAttributes;
    CGFloat originX = layoutAttributes.indexPath.row * layoutAttributes.size.width;
    CGFloat anchorPointX = 0;
    if (ins3DLayoutAttributes.angle > 0) {
        anchorPointX = 1;
    }
    self.layer.anchorPoint = CGPointMake(anchorPointX, 0.5);
    CGPoint position = self.layer.position;
    position.x = anchorPointX * layoutAttributes.size.width + originX;
    self.layer.position = position;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 1000;
    self.layer.transform = CATransform3DRotate(transform, ins3DLayoutAttributes.angle, 0, -1, 0);
}


@end
