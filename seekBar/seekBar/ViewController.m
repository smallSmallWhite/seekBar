//
//  ViewController.m
//  seekBar
//
//  Created by SGJ on 2022/5/16.
//

#import "ViewController.h"
#import "CircleSeekbarView.h"
#import "seekBar/SeekbarConstants.h"

@interface ViewController ()

@property (nonatomic, strong) CircleSeekbarView *circleSeekbarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _circleSeekbarView = [[CircleSeekbarView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, Width_Real(200))];
    [self.view addSubview:_circleSeekbarView];
    
}


@end
