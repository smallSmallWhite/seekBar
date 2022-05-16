//
//  SeekbarConstants.h
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#define AngleToRadian2(x) (M_PI*(x)/180.0) // 把角度转换成弧度
#define pi 3.14159265358979323846
#define degreesToRadian(x) (pi * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / pi)
#define threshold 6  //按钮点击事件的角度阈值

//档位切换的范围
typedef NS_ENUM(NSInteger, SGJGearChangeScope) {
    SGJGearChangeScopeNone, //没有任何档位的切换
    SGJGearChangeScopeLow, //只在低档位之间切换
    SGJGearChangeScopeMiddle, //只在中档位之间切换
    SGJGearChangeScopeHigh,   //只在高档位之间切换
    SGJGearChangeScopeLowAndMiddle, //在低档位和中档位之间切换
    SGJGearChangeScopeMiddlAndHigh,  //在中档位和高档位之间切换
    SGJGearChangeScopeBoth           //在低中高档位之间切换
};

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//屏幕宽度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//主色
#define kMainColor  HEXCOLOR(0x75D9DF)

//新的屏幕适配方案 基于375 812屏幕做的是配
#define SCREEN_WIDTH_BILI (SCREEN_WIDTH/375.0f)
#define Width_Real(a) a*SCREEN_WIDTH_BILI

#define SCREEN_HEIGHT_BILI (SCREEN_HEIGHT/812.0f)
#define Height_Real(a) a*SCREEN_HEIGHT_BILI

//字体
#define BOLD_SYSTEM_FONT(FONTSIZE) [UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEM_FONT(FONTSIZE) [UIFont systemFontOfSize:FONTSIZE]
