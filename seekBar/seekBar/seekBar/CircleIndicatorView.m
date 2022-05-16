//
//  CircleIndicatorView.m
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#import "CircleIndicatorView.h"
#import "SeekbarConstants.h"
#import "Masonry.h"


@implementation CircleIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUIComponments];
        [self layoutUIComponments];
    }
    return self;
}

- (void)createUIComponments
{
    _centerView = [[UIView alloc] init];
    _centerView.backgroundColor = kMainColor;
    _centerView.layer.cornerRadius = Width_Real(20)/2;
    _centerView.layer.masksToBounds = YES;
    [self addSubview:_centerView];
    
    _indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _indicatorLabel.font = BOLD_SYSTEM_FONT(Width_Real(13));
    _indicatorLabel.textAlignment = NSTextAlignmentCenter;
    _indicatorLabel.textColor = [UIColor whiteColor];
    // 这句话只是为了持有 indicatorLabel，防止因它释放而导致 indicatorLabel 没有机会往 layer 上绘制文字，从而导致 indicatorLabel.layer 是没有内容的，透明的遮罩是不能显示出遮罩盖住的内容的
    [self addSubview:_indicatorLabel];
}

- (void)layoutUIComponments
{
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.centerY.equalTo(self).offset(0);
        make.width.height.equalTo(@(Width_Real(20)));
    }];
    
    [_indicatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.centerY.equalTo(self).offset(0);
        make.width.height.equalTo(@(Width_Real(20)));
    }];
    
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    self.layer.shadowOpacity = 1;
    self.layer.cornerRadius = Width_Real(28)/2;
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 1.0;
    self.layer.shadowColor = [_shadowColor colorWithAlphaComponent:1.0].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,1);
    self.layer.shadowRadius = 6;
}

@end
