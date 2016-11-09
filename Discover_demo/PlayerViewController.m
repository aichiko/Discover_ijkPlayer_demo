//
//  PlayerViewController.m
//  Discover_demo
//
//  Created by 24hmb on 16/9/7.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "PlayerViewController.h"
#import "CCPlayerView.h"
#import "CCPlayerControlView.h"
#import "UITabBarController+CCPlayerRotation.h"
#import "UIViewController+CCPlayerRotation.h"
#import "UINavigationController+CCPlayerRotation.h"

@interface PlayerViewController ()

@property (nonatomic, strong) CCPlayerView *playerView;

@end

@implementation PlayerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    //[[self.navigationController.navigationBar.subviews objectAtIndex:0] setAlpha:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //[[self.navigationController.navigationBar.subviews objectAtIndex:0] setAlpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupPlayer];
    
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardAction:)];
    
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction:)];
    
    self.navigationItem.rightBarButtonItems = @[forwardItem,playItem];
}

- (void)forwardAction:(UIBarButtonItem *)forwardItem {
    _playerView.player.currentPlaybackTime += 100;
}

- (void)playAction:(UIBarButtonItem *)playItem {
    _playerView.videoURL = @"http://video.24hmb.com/mp4/R6914-R.mp4";
    //http://video.24hmb.com/mp4/R6916-R.mp4
}

- (void)setupPlayer {
    @weakify(self)
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor redColor];
    [self.view addSubview:topView];
    [topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_offset(20);
    }];
    
    _playerView = [[CCPlayerView alloc]init];
    [self.view addSubview:_playerView];
    [_playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.left.equalTo(self.view);
        // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
        make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
    }];
    //http://video.24hmb.com/mp4/R6914-R.mp4
    _playerView.videoURL = @"http://playv.upuday.com/ghlive/924173/playlist.m3u8";
    _playerView.goBackBlock = ^{
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    UIButton *changeVideoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [changeVideoButton setTitle:@"changeVideo" forState:UIControlStateNormal];
    [self.view addSubview:changeVideoButton];
    [changeVideoButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [[[changeVideoButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        self.playerView.videoURL = @"http://video.24hmb.com/mp4/R6924-R.mp4";
    }];
}

#pragma mark - 转屏相关

// 是否支持自动转屏
- (BOOL)shouldAutorotate
{
    return _playerView?!_playerView.isLocked:NO;//暂时用playerView的参数来控制，之后可以用单例来控制
}

// 支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
        //if use Masonry,Please open this annotation
        
         [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.view).offset(20);
         }];
         
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.view.backgroundColor = [UIColor blackColor];
        //if use Masonry,Please open this annotation
        
         [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.view).offset(0);
         }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
