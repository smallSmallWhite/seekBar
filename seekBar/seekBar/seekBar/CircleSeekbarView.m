//
//  CircleSeekbarView.m
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#import "CircleSeekbarView.h"
#import "SeekbarConstants.h"
#import "CircleIndicatorView.h"
#import "UIView+Extension.h"

@interface CircleSeekbarView ()

{
    /** 起始 */
    CGFloat _startAngle;
    /** 结束 */
    CGFloat _endAngle;
}


//点击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIView *bgImageView;

//中间圆的圆心
@property (nonatomic, assign) CGPoint circleCenter;
//外圆环的半径
@property (nonatomic, assign) CGFloat outerCircleAadius;
//初始档位
@property (nonatomic, strong) NSString *lastGearType;
//当前选中的档位
@property (nonatomic, strong) NSString *currentGearType;

@property (nonatomic, assign) SGJGearChangeScope changeScope;

//顺时针时的角度集合
@property (nonatomic, strong) NSMutableArray *clockwiseArray;

//判断是顺时针，还是逆时针 默认是顺时针
@property (nonatomic, assign) BOOL closeWise;

/** 底层显示层 */
@property (nonatomic, strong) CAShapeLayer *lowBottomLayer;
/** 顶层显示层 */
@property (nonatomic, strong) CAShapeLayer *lowTopLayer;
//第一条线段的进度
@property (nonatomic, assign) CGFloat lowProgress;

//第二条线段相关
@property (nonatomic, strong) CAShapeLayer *middleBottomLayer;
/** 顶层显示层 */
@property (nonatomic, strong) CAShapeLayer *middleTopLayer;
//第二条线段的进度
@property (nonatomic, assign) CGFloat middleProgress;

//第三条线相关
@property (nonatomic, strong) CAShapeLayer *highBottomLayer;
/** 顶层显示层 */
@property (nonatomic, strong) CAShapeLayer *highTopLayer;
//第三条线段的进度
@property (nonatomic, assign) CGFloat highProgress;

@property (nonatomic, strong) CircleIndicatorView *circleIndictorView;


//是否开启震动
@property (nonatomic, assign) BOOL shock;

@end

@implementation CircleSeekbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUIComponments];
    }
    return self;
}

- (void)createUIComponments
{
    _shock = NO;
    _circleCenter = CGPointMake(self.width/2, self.height - 27);
    _outerCircleAadius = (self.width - Width_Real(40) * 2) / 2;
    _lowProgress = 0.0;
    _middleProgress = 0.0;
    _highProgress = 0.0;
    _changeScope = SGJGearChangeScopeNone;
    _lastGearType = @"01";
    _currentGearType = @"01";

    
    [self.layer addSublayer:self.lowBottomLayer];
    [self.layer addSublayer:self.lowTopLayer];

    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:M_PI endAngle:M_PI + AngleToRadian2(56.0) clockwise:YES];
    _lowBottomLayer.path = bottomPath.CGPath;

    [self.layer addSublayer:self.middleBottomLayer];
    [self.layer addSublayer:self.middleTopLayer];

    UIBezierPath *bottomPath1 = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:M_PI + AngleToRadian2(63) endAngle:M_PI + AngleToRadian2(117.0) clockwise:YES];
    _middleBottomLayer.path = bottomPath1.CGPath;

    [self.layer addSublayer:self.highBottomLayer];
    [self.layer addSublayer:self.highTopLayer];

    UIBezierPath *bottomPath2 = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:M_PI + AngleToRadian2(124) endAngle:M_PI + AngleToRadian2(180.0) clockwise:YES];
    _highBottomLayer.path = bottomPath2.CGPath;
    
    
    //添加指示线
    for (int i = 0; i < 3; i++) {
        
        if (i == 0) {
            [self addLayer1WithColor:HEXCOLOR(0xFF7B4B) withAngleTemp:30];
        }
        else if (i == 1) {
            [self addLayer1WithColor:HEXCOLOR(0xFFE86A) withAngleTemp:90];
        }
        else if (i == 2) {
            [self addLayer1WithColor:kMainColor withAngleTemp:150];
        }
    }
    
    [self createIndicatorLabel];
    
//    _bgImageView = [[UIView alloc] initWithFrame:CGRectMake((self.width - self.outerCircleAadius * 2 - 10)/2, self.height - _circleCenter.y, self.outerCircleAadius * 2 + 30, self.height)];
    _bgImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
    _bgImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgImageView];
    
    
    
    // 添加点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.bgImageView addGestureRecognizer:self.tapGesture];
    
    //添加滑动手势
    UILongPressGestureRecognizer *pan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
    [self.bgImageView addGestureRecognizer:pan];
    pan.minimumPressDuration = 0;
    pan.allowableMovement = CGFLOAT_MAX;
    
//    [self setLowerProgress:(AngleToRadian2(10) / AngleToRadian2(56))];
    [self setLowerProgress:1.0 isCanSetZero:YES];
    [self setMiddlerProgress:0.0 isCanSetZero:YES];
    [self setHigherProgress:0.0 isCanSetZero:YES];

    [self showAccessoryOnLine];

    
}

#pragma mark 手势回调
- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    //判断点是否在圆上
    BOOL isCircle = [self pointIsInCircle:point];
    
    if (isCircle) {
        CGFloat angle = angleBetweenPoints1(self.circleCenter, point);
        
//        _currentGearType = @"";
        if (angle >= -10 - threshold && angle <= -10 + threshold) {
            
            _currentGearType = @"01";
        }
        else if (angle >= -30 - threshold && angle <= -30 + threshold)
        {
            _currentGearType = @"01";
        }
        else if (angle >= -50 - threshold && angle <= -50 + threshold)
        {
            _currentGearType = @"01";
        }
        else if (angle >= -70 - threshold && angle <= -70 + threshold)
        {
            _currentGearType = @"02";
        }
        else if (abs(angle) >= 84 && abs(angle) <= 92)
        {
            _currentGearType = @"02";
        }
        else if (angle >= 70 - threshold && angle <= 70 + threshold)
        {
            _currentGearType = @"02";
        }
        else if (angle >= 50 - threshold && angle <= 50 + threshold)
        {
            _currentGearType = @"03";
        }
        else if (angle >= 30 - threshold && angle <= 30 + threshold)
        {
            _currentGearType = @"03";
        }
        else if (angle >= 10 - threshold && angle <= 10 + threshold)
        {
            _currentGearType = @"03";
        }
        
        //只有档位真正发生改变时，才进行赋值操作
        if (![_currentGearType isEqualToString:@""]) {
            
            self.shock = YES;
            [self animatedWithLastGear:_lastGearType withCurrentGear:_currentGearType];
        }
    }
    else
    {
//        [HUD hrz_showAutoMsg:@"点击到圆内"];
    }
}

- (void)touchAction:(UILongPressGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
//        [HUD hrz_showAutoMsg:[NSString stringWithFormat:@"当前的档位是%@",self.currentGearType]];
        if (self.callbackCurrentGearValue) {
            self.callbackCurrentGearValue(self.currentGearType);
        }
    }
    
    if (point.y > _circleCenter.y) {
//        [HUD hrz_showAutoMsg:@"滑动区域超出范围"];
        return;
    }
    
    CGFloat angle = angleBetweenPoints1(self.circleCenter, point);
    
    BOOL isCircle = [self panPointIsInCircle:point];
    
    if (isCircle) {
        
//        _currentGearType = @"";
        if (angle >= -10 - threshold && angle <= -10 + threshold) {
            
            _currentGearType = @"01";
        }
        else if (angle >= -30 - threshold && angle <= -30 + threshold)
        {
            _currentGearType = @"01";
        }
        else if (angle >= -50 - threshold && angle <= -50 + threshold)
        {
            _currentGearType = @"01";
        }
        else if (angle >= -70 - threshold && angle <= -70 + threshold)
        {
            _currentGearType = @"02";
        }
        else if (abs(angle) >= 84 && abs(angle) <= 92)
        {
            _currentGearType = @"02";
        }
        else if (angle >= 70 - threshold && angle <= 70 + threshold)
        {
            _currentGearType = @"02";
        }
        else if (angle >= 50 - threshold && angle <= 50 + threshold)
        {
            _currentGearType = @"03";
        }
        else if (angle >= 30 - threshold && angle <= 30 + threshold)
        {
            _currentGearType = @"03";
        }
        else if (angle >= 10 - threshold && angle <= 10 + threshold)
        {
            _currentGearType = @"03";
        }
        
        //只有档位真正发生改变时，才进行赋值操作
        if (![_currentGearType isEqualToString:@""]) {
            
            self.shock = YES;
            [self animatedWithLastGear:_lastGearType withCurrentGear:_currentGearType];
        }
    }
    else
    {
        
    }
}

//绘制中间的分隔线
- (void)addLayer1WithColor:(UIColor *)color withAngleTemp:(CGFloat)angleTemp {
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = CGRectMake(0, 0, self.width, self.height);
    
    [self.layer addSublayer:layer];
    
    CAShapeLayer * maskLayer= [CAShapeLayer layer];
    maskLayer.frame = CGRectMake(0, 0, layer.bounds.size.width,layer.bounds.size.height);
    
    NSArray *rectangleFourKeyPointArray = nil;
    
    
    rectangleFourKeyPointArray = [self calculateFourKeyPointForRectangleWithCircleCenter:CGPointMake((self.width - Width_Real(52) * 2) / 2 + Width_Real(52), self.height - 27) innerCircleRadius:(self.width - Width_Real(52) * 2) / 2 - Width_Real(6) rectangleWidht:Width_Real(2) rectangleHeight:Width_Real(6) angle:angleTemp];
    
    CGPoint topLeftPoint = ((NSValue *)rectangleFourKeyPointArray[0]).CGPointValue;
    CGPoint topRightPoint = ((NSValue *)rectangleFourKeyPointArray[1]).CGPointValue;
    CGPoint bottomRightPoint = ((NSValue *)rectangleFourKeyPointArray[2]).CGPointValue;
    CGPoint bottomLeftPoint = ((NSValue *)rectangleFourKeyPointArray[3]).CGPointValue;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:topLeftPoint];
    [path addLineToPoint:topRightPoint];
    [path addLineToPoint:bottomRightPoint];
    [path addLineToPoint:bottomLeftPoint];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    
    layer.mask = maskLayer;
    
}

/**
 计算矩形的四个顶点坐标
 
 @param cirlceCenter 圆心
 @param innerCircleRadius 内圆半径
 @param rectangleWidht 矩形宽
 @param rectangleHeight 矩形高
 @param angle 矩形绕圆心的角度
 @return 数组，包含四个顶点坐标（顺时针，上左，上右，下右，下左）
 */
- (NSArray *)calculateFourKeyPointForRectangleWithCircleCenter:(CGPoint)cirlceCenter innerCircleRadius:(CGFloat)innerCircleRadius rectangleWidht:(CGFloat)rectangleWidht rectangleHeight:(CGFloat)rectangleHeight angle:(CGFloat)angle {
    CGFloat cirlceCenterX = cirlceCenter.x;
    CGFloat cirlceCenterY = cirlceCenter.y;
    
    CGFloat tempAngle = angle;
    CGFloat tempRadian = AngleToRadian2(tempAngle);
    
    CGFloat middlePointX_LeftLine = cirlceCenterX + innerCircleRadius * cos(tempRadian);
    CGFloat middlePointY_LeftLine = cirlceCenterY - innerCircleRadius * sin(tempRadian);
    
    CGFloat topLeftPointX = middlePointX_LeftLine - rectangleWidht / 2 * sin(tempRadian);
    CGFloat topLeftPointY = middlePointY_LeftLine - rectangleWidht / 2 * cos(tempRadian);
    NSValue *topLeftPointValue = [NSValue valueWithCGPoint:CGPointMake(topLeftPointX, topLeftPointY)];
    
    CGFloat topRightPointX = topLeftPointX + rectangleHeight * cos(tempRadian);
    CGFloat topRightPointY = topLeftPointY - rectangleHeight * sin(tempRadian);
    NSValue *topRightPointValue = [NSValue valueWithCGPoint:CGPointMake(topRightPointX, topRightPointY)];
    
    CGFloat bottomLeftPointX = middlePointX_LeftLine + rectangleWidht / 2 * sin(tempRadian);
    CGFloat bottomLeftPointY = middlePointY_LeftLine + rectangleWidht / 2 * cos(tempRadian);
    NSValue *bottomLeftPointValue = [NSValue valueWithCGPoint:CGPointMake(bottomLeftPointX, bottomLeftPointY)];
    
    CGFloat bottomRightPointX = bottomLeftPointX + rectangleHeight * cos(tempRadian);
    CGFloat bottomRightPointY = bottomLeftPointY - rectangleHeight * sin(tempRadian);
    NSValue *bottomRightPointValue = [NSValue valueWithCGPoint:CGPointMake(bottomRightPointX, bottomRightPointY)];
    
    NSArray *pointArray = @[topLeftPointValue, topRightPointValue, bottomRightPointValue, bottomLeftPointValue];
    
    return pointArray;
}

#pragma mark === 永久闪烁的动画 ======
- (CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

CGFloat angleBetweenPoints1(CGPoint first, CGPoint second) {
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return radiansToDegrees(rads);
    //degs = degrees(atan((top - bottom)/(right - left)))
}

//圆心到点的距离>?半径
- (BOOL)pointIsInCircle:(CGPoint)point  {
    CGPoint center = _circleCenter;
    double dx = fabs(point.x - center.x);
    double dy = fabs(point.y - center.y);
    double dis = hypot(dx, dy);
    
    if (dis >= _outerCircleAadius - 20 && dis <= _outerCircleAadius + 20) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)panPointIsInCircle:(CGPoint)point  {
    
    return YES;
}

#pragma mark 点击事件回调
- (void)animatedWithLastGear:(NSString *)lastGear withCurrentGear:(NSString *)currentGear
{
    //判断是顺时针，还是逆时针
    if (lastGear == nil || currentGear == nil) {
        return;
    }
    
    if (![self judgeGear:lastGear] || ![self judgeGear:currentGear]) {
//        [HUD hrz_showAutoMsg:[NSString stringWithFormat:@"当前的档位是%@,即将切换到的档位是%@",lastGear,currentGear]];
        return;
    }
    
    //判断是顺时针，还是逆时针,默认是顺时针
    if ([currentGear integerValue] > [lastGear integerValue]) {
        self.closeWise = YES;
    }
    else
    {
        self.closeWise = NO;
    }
    
    if (self.shock) {
        
        if (self.valueChangedAction) {
            self.valueChangedAction();
        }
    }
    
    NSInteger currentGearValue = [currentGear integerValue];
    NSInteger lastGearValue = [lastGear integerValue];
    
    if ((currentGearValue == 1 && lastGearValue == 3) || (currentGearValue == 3 && lastGearValue == 1)) {
        self.changeScope = SGJGearChangeScopeBoth;
    }
    else if ((currentGearValue == 1 && lastGearValue == 2) || (currentGearValue == 2 && lastGearValue == 1))
    {
        self.changeScope = SGJGearChangeScopeLowAndMiddle;
    }
    else if ((currentGearValue == 2 && lastGearValue == 3) || (currentGearValue == 3 && lastGearValue == 2))
    {
        self.changeScope = SGJGearChangeScopeMiddlAndHigh;
    }
    
    NSInteger endAngle = 0.0;
    endAngle = [self transforAngleByGear:self.currentGearType];
    
    switch (self.changeScope) {
        case SGJGearChangeScopeLow:
        {
//            NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue];
//            [self setLowerProgress:(AngleToRadian2(endAngle) / AngleToRadian2(56.0))];
            [self setLowerProgress:1.0 isCanSetZero:NO];
            [self setMiddlerProgress:0.0 isCanSetZero:YES];
            [self setHigherProgress:0.0 isCanSetZero:YES];
            [self showAccessoryOnLine];
//            self.lastGearType = self.currentGearType;
        }
            break;
        case SGJGearChangeScopeMiddle:
        {
//            NSInteger endAngle = 0.0;
//            if ([_currentGearType isEqualToString:@"04"]) {
//                endAngle = 10.0;
//            }
//            else
//            {
//                endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 63;
//            }
//            [self setMiddlerProgress:(AngleToRadian2(endAngle) / AngleToRadian2(54.0)) isCanSetZero:NO];
            [self setMiddlerProgress:1.0 isCanSetZero:NO];
            [self setLowerProgress:0.0 isCanSetZero:YES];
            [self setHigherProgress:0.0 isCanSetZero:YES];
            [self showAccessoryOnLine];
//            self.lastGearType = self.currentGearType;
        }
            break;
        case SGJGearChangeScopeHigh:
        {
//            NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 124;
            [self setHigherProgress:1.0 isCanSetZero:NO];
            [self setLowerProgress:0.0 isCanSetZero:YES];
            [self setMiddlerProgress:0.0 isCanSetZero:YES];
            [self showAccessoryOnLine];
//            self.lastGearType = self.currentGearType;
        }
            break;
        case SGJGearChangeScopeBoth:
        {
            if (self.closeWise) {
                //档位从低到高
//                NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 124;
                [self setHigherProgress:1.0 isCanSetZero:NO];
                [self setLowerProgress:0.0 isCanSetZero:YES];
                [self setMiddlerProgress:0.0 isCanSetZero:YES];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            else
            {
                //档位从高到低
//                NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue];
                [self setLowerProgress:1.0 isCanSetZero:NO];
                [self setMiddlerProgress:0.0 isCanSetZero:YES];
                [self setHigherProgress:0.0 isCanSetZero:YES];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            
        }
            break;
        case SGJGearChangeScopeLowAndMiddle:
        {
            if (self.closeWise) {
                //档位从低到高
//                NSInteger endAngle = 0.0;
//                if ([_currentGearType isEqualToString:@"04"]) {
//                    endAngle = 10.0;
//                }
//                else
//                {
//                    endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 63;
//                }
//                [self setMiddlerProgress:(AngleToRadian2(endAngle) / AngleToRadian2(54.0)) isCanSetZero:NO];
                [self setMiddlerProgress:1.0 isCanSetZero:NO];
                [self setLowerProgress:0.0 isCanSetZero:YES];
                [self setHigherProgress:0.0 isCanSetZero:YES];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            else
            {
                //档位从高到低
//                NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue];
                [self setLowerProgress:1.0 isCanSetZero:NO];
                [self setMiddlerProgress:0.0 isCanSetZero:YES];
                [self setHigherProgress:0.0 isCanSetZero:YES];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            
        }
            break;
        case SGJGearChangeScopeMiddlAndHigh:
        {
            if (self.closeWise) {
                //档位从低到高
//                NSInteger endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 124;
//                [self setHigherProgress:(AngleToRadian2(endAngle) / AngleToRadian2(56.0)) isCanSetZero:NO];
                [self setHigherProgress:1.0 isCanSetZero:NO];
                [self setLowerProgress:0.0 isCanSetZero:YES];
                [self setMiddlerProgress:0.0 isCanSetZero:YES];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            else
            {
                //档位从高到低
//                NSInteger endAngle = 0.0;
//                if ([_currentGearType isEqualToString:@"04"]) {
//                    endAngle = 10.0;
//                }
//                else
//                {
//                    endAngle = [self.clockwiseArray[currentGearValue - 1] intValue] - 54;
//                }
                [self setHigherProgress:0.0 isCanSetZero:YES];
                [self setLowerProgress:0.0 isCanSetZero:YES];
                [self setMiddlerProgress:1.0 isCanSetZero:NO];
                [self showAccessoryOnLine];
//                self.lastGearType = self.currentGearType;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark -初始化圆形指示条
- (void)createIndicatorLabel
{
    _circleIndictorView = [[CircleIndicatorView alloc] initWithFrame:CGRectMake(0, 0, Width_Real(28), Width_Real(28))];
    _circleIndictorView.indicatorLabel.text = [NSString stringWithFormat:@"%ld", [self.currentGearType integerValue]];
    [self addSubview:_circleIndictorView];
    
    NSInteger endAngle = 0.0;
    endAngle = [self transforAngleByGear:self.currentGearType];
    
    CGFloat redDotCenterY = _circleCenter.y - sin(AngleToRadian2(endAngle)) * _outerCircleAadius;
    CGFloat redDotCenterX = Width_Real(40) + (_outerCircleAadius - cos(AngleToRadian2(endAngle)) * _outerCircleAadius);
    
    CGPoint dotCircleCenter = CGPointMake(redDotCenterX, redDotCenterY);
    _circleIndictorView.center = dotCircleCenter;
}

//指示条赋值以及位置确定
- (void)showAccessoryOnLine
{
    NSInteger currentGearValue = [self.currentGearType integerValue];
    NSInteger endAngle = 0.0;
    endAngle = [self transforAngleByGear:self.currentGearType];
    
    // 1.添加圆点
    if (currentGearValue == 1) {
        
        CGFloat redDotCenterY = _circleCenter.y - sin(AngleToRadian2(endAngle)) * _outerCircleAadius;
        CGFloat redDotCenterX = Width_Real(40) + (_outerCircleAadius - cos(AngleToRadian2(endAngle)) * _outerCircleAadius);
        CGPoint dotCircleCenter = CGPointMake(redDotCenterX, redDotCenterY);

        _circleIndictorView.indicatorLabel.text = [NSString stringWithFormat:@"%ld", currentGearValue];
        _circleIndictorView.centerView.backgroundColor = kMainColor;
        _circleIndictorView.center = dotCircleCenter;
//        _circleIndictorView.indicatorLabel.center = dotCircleCenter;

    }
    else if (currentGearValue == 2)
    {
        CGFloat redDotCenterY = 0.0;
        CGFloat redDotCenterX = 0.0;
            
        redDotCenterY = _circleCenter.y - sin(AngleToRadian2(endAngle)) * _outerCircleAadius;
        redDotCenterX = Width_Real(40) + (_outerCircleAadius - cos(AngleToRadian2(endAngle)) * _outerCircleAadius);
        
        CGPoint dotCircleCenter = CGPointMake(redDotCenterX, redDotCenterY);
        _circleIndictorView.indicatorLabel.text = [NSString stringWithFormat:@"%ld", currentGearValue];
        _circleIndictorView.centerView.backgroundColor = HEXCOLOR(0xFFE86A);
        _circleIndictorView.center = dotCircleCenter;
//        _circleIndictorView.indicatorLabel.center = dotCircleCenter;
    }
    else if (currentGearValue == 3)
    {
        CGFloat redDotCenterY = 0.0;
        CGFloat redDotCenterX = 0.0;
            
        redDotCenterY = _circleCenter.y - sin(AngleToRadian2(endAngle)) * _outerCircleAadius;
        redDotCenterX = Width_Real(40) + (_outerCircleAadius - cos(AngleToRadian2(endAngle)) * _outerCircleAadius);
        
        CGPoint dotCircleCenter = CGPointMake(redDotCenterX, redDotCenterY);
        
        _circleIndictorView.indicatorLabel.text = [NSString stringWithFormat:@"%ld", currentGearValue];
        _circleIndictorView.centerView.backgroundColor = HEXCOLOR(0xFF7B4B);
        _circleIndictorView.center = dotCircleCenter;
//        _circleIndictorView.indicatorLabel.center = dotCircleCenter;
    }
    
}



#pragma mark -根据当前的档位返回对应的角度
- (CGFloat)transforAngleByGear:(NSString *)gear
{
    NSInteger endAngle = 0.0;
    if ([gear isEqualToString:@"01"]) {
        endAngle = 30;
        _circleIndictorView.shadowColor = kMainColor;
    }
    else if ([gear isEqualToString:@"02"])
    {
        endAngle = 90;
        _circleIndictorView.shadowColor = HEXCOLOR(0xFFE86A);
        
    }
    else if ([gear isEqualToString:@"03"])
    {
        endAngle = 150;
        _circleIndictorView.shadowColor = HEXCOLOR(0xFF7B4B);
        
    }
    return endAngle;
}

#pragma mark - 设置进度条的进度
- (void)setLowerProgress:(CGFloat)progress isCanSetZero:(BOOL)setZero {
    
    if (progress > 1.0) {
        _lowProgress = 1.0;
        return;
    }
    
    if (!setZero) {
        
        if (progress < AngleToRadian2(10)/AngleToRadian2(56)) {
            _lowProgress = progress;
            return;
        }
    }
    
    _lowProgress = progress;
    
    _startAngle = M_PI;
    _endAngle = _startAngle + _lowProgress * AngleToRadian2(56);
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    _lowTopLayer.path = topPath.CGPath;
}

- (void)setMiddlerProgress:(CGFloat)progress isCanSetZero:(BOOL)setZero
{
    if (progress > 1.0) {
        _middleProgress = 1.0;
        return;
    }
    
    if (!setZero) {
        
        if (progress < AngleToRadian2(10)/AngleToRadian2(54)) {
            _middleProgress = progress;
            return;
        }
    }
    _middleProgress = progress;
    _startAngle = M_PI + AngleToRadian2(63);
    _endAngle = _startAngle + _middleProgress * AngleToRadian2(54);
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    _middleTopLayer.path = topPath.CGPath;
}

- (void)setHigherProgress:(CGFloat)progress isCanSetZero:(BOOL)setZero
{
    if (progress > 1.0) {
        _highProgress = 1.0;
        return;
    }
    
    if (!setZero) {
        
        if (progress < AngleToRadian2(6)/AngleToRadian2(56)) {
            _highProgress = progress;
            return;
        }
    }
    _highProgress = progress;
    _startAngle = M_PI + AngleToRadian2(124);
    _endAngle = _startAngle + _highProgress * AngleToRadian2(56);
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithArcCenter:_circleCenter radius:_outerCircleAadius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    _highTopLayer.path = topPath.CGPath;
}

- (void)setAnimatedWithLastGear:(NSString *)lastGear withCurrentGear:(NSString *)currentGear
{
    _lastGearType = lastGear;
    _currentGearType = currentGear;
    _shock = NO;
    [self animatedWithLastGear:_lastGearType withCurrentGear:_currentGearType];
}

//判断档位是否在01-09之间
- (BOOL)judgeGear:(NSString *)gear
{
    if ([gear isEqualToString:@"01"] || [gear isEqualToString:@"02"] || [gear isEqualToString:@"03"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -懒加载
- (NSMutableArray *)clockwiseArray
{
    if (!_clockwiseArray) {
        _clockwiseArray = [NSMutableArray arrayWithObjects:@"10",@"30",@"56",@"63",@"90",@"117",@"130",@"150",@"180", nil];
    }
    return _clockwiseArray;
}

- (CAShapeLayer *)lowBottomLayer
{
    if (!_lowBottomLayer) {
        _lowBottomLayer = [CAShapeLayer layer];
        _lowBottomLayer.lineCap = kCALineCapRound;
        _lowBottomLayer.fillColor = [UIColor clearColor].CGColor;
        _lowBottomLayer.strokeColor = [kMainColor colorWithAlphaComponent:0.4].CGColor;
        _lowBottomLayer.lineWidth = Width_Real(9);
    }
    return _lowBottomLayer;
}

- (CAShapeLayer *)lowTopLayer
{
    if (!_lowTopLayer) {
        _lowTopLayer = [CAShapeLayer layer];
        _lowTopLayer.lineCap = kCALineCapRound;
        _lowTopLayer.fillColor = [UIColor clearColor].CGColor;
        _lowTopLayer.strokeColor = kMainColor.CGColor;
        _lowTopLayer.lineWidth = Width_Real(9);
    }
    return _lowTopLayer;
}

- (CAShapeLayer *)middleBottomLayer
{
    if (!_middleBottomLayer) {
        _middleBottomLayer = [CAShapeLayer layer];
        _middleBottomLayer.lineCap = kCALineCapRound;
        _middleBottomLayer.fillColor = [UIColor clearColor].CGColor;
        _middleBottomLayer.strokeColor = [HEXCOLOR(0xFFE86A) colorWithAlphaComponent:0.4].CGColor;
        _middleBottomLayer.lineWidth = Width_Real(9);
    }
    return _middleBottomLayer;
}

- (CAShapeLayer *)middleTopLayer
{
    if (!_middleTopLayer) {
        _middleTopLayer = [CAShapeLayer layer];
        _middleTopLayer.lineCap = kCALineCapRound;
        _middleTopLayer.fillColor = [UIColor clearColor].CGColor;
        _middleTopLayer.strokeColor = HEXCOLOR(0xFFE86A).CGColor;
        _middleTopLayer.lineWidth = Width_Real(9);
    }
    return _middleTopLayer;
}

- (CAShapeLayer *)highBottomLayer
{
    if (!_highBottomLayer) {
        _highBottomLayer = [CAShapeLayer layer];
        _highBottomLayer.lineCap = kCALineCapRound;
        _highBottomLayer.fillColor = [UIColor clearColor].CGColor;
        _highBottomLayer.strokeColor = [HEXCOLOR(0xFF7B4B) colorWithAlphaComponent:0.4].CGColor;
        _highBottomLayer.lineWidth = Width_Real(9);
    }
    return _highBottomLayer;
}

- (CAShapeLayer *)highTopLayer
{
    if (!_highTopLayer) {
        _highTopLayer = [CAShapeLayer layer];
        _highTopLayer.lineCap = kCALineCapRound;
        _highTopLayer.fillColor = [UIColor clearColor].CGColor;
        _highTopLayer.strokeColor = HEXCOLOR(0xFF7B4B).CGColor;
        _highTopLayer.lineWidth = Width_Real(9);
    }
    return _highTopLayer;
}

@end
