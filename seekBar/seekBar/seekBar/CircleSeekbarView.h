//
//  CircleSeekbarView.h
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleSeekbarView : UIView

- (void)setAnimatedWithLastGear:(NSString *)lastGear withCurrentGear:(NSString *)currentGear;

@property (nonatomic, copy) void (^callbackCurrentGearValue)(NSString *currentGear);

@property (nonatomic, copy) void (^valueChangedAction)(void);

@end

NS_ASSUME_NONNULL_END
