//
//  CircleIndicatorView.h
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleIndicatorView : UIView

//中间的背景颜色
@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UILabel *indicatorLabel;

@property (nonatomic, strong) UIColor *shadowColor;

@end

NS_ASSUME_NONNULL_END
