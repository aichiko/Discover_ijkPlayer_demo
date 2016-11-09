//
//  CCPlayerView.m
//  Discover_demo
//
//  Created by 24hmb on 16/9/7.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "CCPlayerView.h"
#import "CCPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>

#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

static const CGFloat CCPlayerAnimationTimeInterval = 7.0f;
static const CGFloat CCPlayerControlBarAutoFadeOutTimeInterval = 0.35f;

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

@interface CCPlayerView ()<UIGestureRecognizerDelegate>
/**
 *  IJKFFOptions，ijkplayer的配置属性
 */
@property (nonatomic, strong) IJKFFOptions *options;

@property (nonatomic, strong) RACSignal *timeSignal;
/**
 *  控制视图
 */
@property (nonatomic, strong) CCPlayerControlView *controlView;
/** slider 上次的值 */
@property (nonatomic, assign) CGFloat sliderLastValue;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection panDirection;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) NSTimeInterval sumTime;
/** 是否在调节音量 YES为调节音量，NO则为调节亮度  */
@property (nonatomic, assign) BOOL isVolume;
/** 音量滑杆 */
@property (nonatomic, strong) UISlider *volumeViewSlider;
/** 是否显示controlView*/
@property (nonatomic, assign) BOOL isMaskShowing;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

/** 是否为全屏 */
@property (nonatomic, assign) BOOL isFullScreen;

@end

@implementation CCPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [self removeMovieNotificationObservers];
    [self.player shutdown];
    self.player = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializationPlayer];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializationPlayer];
    }
    return self;
}

#pragma mark - layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    //self.playerLayer.frame = self.bounds;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // 只要屏幕旋转就显示控制层
    self.isMaskShowing = NO;
    // 延迟隐藏controlView
    [self animateShow];
    
    // 4s，屏幕宽高比不是16：9的问题,player加到控制器上时候
    if (iPhone4s) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset([UIScreen mainScreen].bounds.size.width*2/3);
        }];
    }
    // fix iOS7 crash bug
    [self layoutIfNeeded];
}

- (void)initializationPlayer {
    UIImage *image = [UIImage imageNamed:@"loading@3x"];
    self.layer.contents = (id)image.CGImage;
    [self configPlayer];
    // 每次播放视频都解锁屏幕锁定
    [self unLockTheScreen];
}

- (void)configPlayer{
    
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    [self addSubview:self.controlView];
    [_controlView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    [self controlViewAction];
    
    // 获取系统音量
    [self configureVolume];
    
    self.isFullScreen = NO;
    _isMaskShowing = YES;
    // 监测设备方向
    [self listeningRotating];
    //创建单击手势，双击手势
    [self createGesture];
    // 延迟隐藏controlView
    [self autoFadeOutControlBar];
}

- (void)listeningRotating {
    @weakify(self)
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIDeviceOrientationDidChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notification) {
        //NSLog(@"%@",notification.userInfo);
        @strongify(self)
        if (self.isLocked) {
            self.isFullScreen = YES;
            return;
        }
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortraitUpsideDown:{
                //
                self.controlView.fullScreenButton.selected = YES;
                self.isFullScreen = YES;
                self.controlView.isLandscape = YES;
//                [self.controlView.backButton setImage:ZFPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
                // 设置返回按钮的约束
//                [self.controlView.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.top.mas_equalTo(20);
//                    make.leading.mas_equalTo(7);
//                    make.width.height.mas_equalTo(40);
//                }];
            }
                break;
            case UIInterfaceOrientationPortrait:{
                //
                self.controlView.fullScreenButton.selected = NO;
                self.isFullScreen = NO;
                self.controlView.isLandscape = NO;
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:{
                //
                self.controlView.fullScreenButton.selected = YES;
                self.isFullScreen = YES;
                self.controlView.isLandscape = YES;
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                //
                self.controlView.fullScreenButton.selected = YES;
                self.isFullScreen = YES;
                self.controlView.isLandscape = YES;
            }
                break;
            default:
                break;
        }
        // 设置显示or不显示锁定屏幕方向按钮
        self.controlView.lockScreenButton.hidden = !self.isFullScreen;
    }];
}


/**
 *  创建手势
 */
- (void)createGesture
{
    // 单击
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    self.tap.delegate = self;
    [self addGestureRecognizer:self.tap];
    
    // 双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    [self.doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:self.doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    //self.tap.delaysTouchesBegan = YES;
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
}


- (void)controlViewAction {
    
    /**
     使用这种方式会使点击方法运行过慢，需要换成代理来实现
     */
    @weakify(self)
    /**
     *  更新播放时间的定时器，视图释放时信号消失
     */
    self.timeSignal = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal];
    [self.timeSignal subscribeNext:^(id x) {
        @strongify(self)
        /**
         *  这里计时器会有半秒的误差，所以加上0.5
         */
        self.controlView.currentTimeLabel.text = [self stringWithNSTimerinterval:self.player.currentPlaybackTime];
        CGFloat current = (CGFloat)self.player.currentPlaybackTime/self.player.duration;
        self.controlView.videoSlider.value = current;
        self.controlView.progressView.progress = (CGFloat)self.player.playableDuration/self.player.duration;
    }];
    /**
     *  返回按钮点击事件
     */
    [[[[self.controlView.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        if (self.isLocked) {
            [self unLockTheScreen];
            return;
        }else {
            //如果为全屏播放，则先返回竖屏。
            if (!self.isFullScreen) {
                // player加到控制器上，只有一个player时候
                [self pause];
                if (self.goBackBlock) {
                    self.goBackBlock();
                }
            }else {
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
    }];
    /**
     *  播放按钮点击事件
     */
    [[[[self.controlView.playButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(UIButton *button) {
        @strongify(self)
        if (button.selected) {
            [self.player pause];
        }else {
            [self.player play];
        }
        button.selected = !button.selected;
    }];
    /**
     *  全屏按钮点击事件
     */
    [[[[self.controlView.fullScreenButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(UIButton *button) {
        @strongify(self)
        if (self.isLocked) {
            [self unLockTheScreen];
            return;
        }
        if (button.selected) {
            NSLog(@"退出全屏！！！");
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
            button.selected = NO;
        }else {
            NSLog(@"进入全屏！！！");
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            button.selected = YES;
        }
    }];
    /**
     *  锁屏按钮点击事件
     */
    [[[[self.controlView.lockScreenButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(UIButton *button) {
        @strongify(self)
        button.selected = !button.selected;
        self.isLocked = button.selected;
        // 调用AppDelegate单例记录播放状态是否锁屏，在TabBarController设置哪些页面支持旋转
        //ZFPlayerShared.isLockScreen = button.selected;
        
        // 根据UserDefaults的值，在TabBarController设置哪些页面支持旋转
        NSUserDefaults *settingsData = [NSUserDefaults standardUserDefaults];
        if (button.selected) {
            [settingsData setObject:@"1" forKey:@"lockScreen"];
        }else {
            [settingsData setObject:@"0" forKey:@"lockScreen"];
        }
        [settingsData synchronize];
    }];
    
#warning slider 滑动事件
    // slider开始滑动事件
    [[[self.controlView.videoSlider rac_signalForControlEvents:UIControlEventTouchDown] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        //滑动是禁止掉自动隐藏controlView事件
        @strongify(self)
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
    // slider滑动中事件
    [[[[self.controlView.videoSlider rac_signalForControlEvents:UIControlEventValueChanged] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(UISlider *slider) {
        @strongify(self)
        //NSLog(@"slider.value === %f",slider.value);
        
        if (self.player.isPreparedToPlay) {
            [self pause];//先暂停
            NSString *style = @"";
            CGFloat value   = slider.value - self.sliderLastValue;
            if (value > 0) { style = @">>"; }
            if (value < 0) { style = @"<<"; }
            if (value == 0) { return; }
            //每次拖动都要更新slider的最终值，用于下次判断为快进或者快退
            self.sliderLastValue = slider.value;
            
            NSTimeInterval currentValue = self.player.duration * slider.value;
            NSLog(@"slider.value === %f currentValue === %f",slider.value,currentValue);
            //self.player.currentPlaybackTime = currentValue;
            if (self.player.duration > 0) {
                self.controlView.currentTimeLabel.text = [self stringWithNSTimerinterval:currentValue];
                self.controlView.horizontalLabel.hidden = NO;
                self.controlView.horizontalLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, [self stringWithNSTimerinterval:currentValue], [self stringWithNSTimerinterval:self.player.duration]];
            }else {
                // 此时设置slider值为0
                slider.value = 0;
            }
        }else { // player状态加载失败
            // 此时设置slider值为0
            slider.value = 0;
        }
    }];
    // slider滑动结束事件
    [[[[self.controlView.videoSlider rac_signalForControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(UISlider *slider) {
        // 滑动结束延时隐藏controlView
        @strongify(self)
        [self autoFadeOutControlBar];
        NSTimeInterval currentValue = self.player.duration * slider.value;
        self.player.currentPlaybackTime = currentValue;
        [self play];//开始播放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.controlView.horizontalLabel.hidden = YES;
        });
    }];
    
    self.controlView.tapBlock = ^(CGFloat value){
        @strongify(self)
        self.controlView.videoSlider.value = value;
        NSTimeInterval currentValue = self.player.duration * value;
        NSLog(@"slider.value === %f currentValue === %f",self.controlView.videoSlider.value,currentValue);
        self.player.currentPlaybackTime = currentValue;
        self.controlView.currentTimeLabel.text = [self stringWithNSTimerinterval:currentValue];
    };
}

/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    _volumeViewSlider = nil;
    for (UIView *view in volumeView.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
//    NSError *setCategoryError = nil;
//    BOOL success = [[AVAudioSession sharedInstance]
//                    setCategory: AVAudioSessionCategoryPlayback
//                    error: &setCategoryError];
//    
//    if (!success) { /* handle the error in setCategoryError */ }
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机暂停播放
            [self pause];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

/**
 *  解锁屏幕方向锁定
 */
- (void)unLockTheScreen
{
    // 调用AppDelegate单例记录播放状态是否锁屏
    //ZFPlayerShared.isLockScreen       = NO;
    self.controlView.lockScreenButton.selected = NO;
    self.isLocked = NO;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}


#pragma mark 屏幕转屏相关

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        self.isFullScreen = YES;
    }else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        self.isFullScreen = NO;
    }
}

/**
 *  播放
 */
- (void)play
{
    self.controlView.playButton.selected = YES;
    //self.isPauseByUser = NO;
    [self.player play];
}

/**
 * 暂停
 */
- (void)pause
{
    self.controlView.playButton.selected = NO;
    //self.isPauseByUser = YES;
    [self.player pause];
}

#pragma mark - Action

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        self.isMaskShowing ? ([self hideControlView]) : ([self animateShow]);
    }
}

/**
 *  双击播放/暂停
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    // 显示控制层
    [self animateShow];
    [self startAction:self.controlView.playButton];
}

/**
 *  播放、暂停按钮事件
 *
 *  @param button UIButton
 */
- (void)startAction:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [self play];
    } else {
        [self pause];
    }
}


#pragma mark - ShowOrHideControlView

- (void)autoFadeOutControlBar
{
    if (!self.isMaskShowing) { return; }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:CCPlayerAnimationTimeInterval];
}

/**
 *  取消延时隐藏controlView的方法
 */
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  隐藏控制层
 */
- (void)hideControlView
{
    @weakify(self)
    if (!self.isMaskShowing) { return; }
    [UIView animateWithDuration:CCPlayerControlBarAutoFadeOutTimeInterval animations:^{
        @strongify(self)
        [self.controlView hideControlView];
        if (self.isFullScreen) { //全屏状态
            self.controlView.backButton.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }else {
            self.controlView.backButton.alpha = 1.0;
        }
    }completion:^(BOOL finished) {
        @strongify(self)
        self.isMaskShowing = NO;
    }];
}

/**
 *  显示控制层
 */
- (void)animateShow
{
    @weakify(self)
    if (self.isMaskShowing) { return; }
    [UIView animateWithDuration:CCPlayerControlBarAutoFadeOutTimeInterval animations:^{
        @strongify(self)
        self.controlView.backButton.alpha = 1.0;
        if (self.player.playbackState == IJKMPMoviePlaybackStateStopped) {
            [self.controlView hideControlView];
        } // 播放完了
        else {
            [self.controlView showControlView];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        @strongify(self)
        self.isMaskShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

#pragma mark - UIPanGestureRecognizer手势方法
/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint velocityPoint = [pan velocityInView:self];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (x > y) {
                // 水平移动
                // 取消隐藏
                self.controlView.horizontalLabel.hidden = NO;
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                self.sumTime = self.player.currentPlaybackTime;
                
                // 暂停视频播放
                [self pause];
            }else {// 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    // 移动中一直显示快进label
                    self.controlView.horizontalLabel.hidden = NO;
                    [self horizontalMoved:velocityPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:velocityPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 隐藏视图
                        self.controlView.horizontalLabel.hidden = YES;
                    });
                    // 快进、快退时候把开始播放按钮改为播放状态
                    //self.controlView.playButton.selected = YES;
                    //self.isPauseByUser                 = NO;
                    
                    self.player.currentPlaybackTime = self.sumTime;
                    // 把sumTime滞空，不然会越加越多
                    // 继续播放
                    [self play];
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.controlView.horizontalLabel.hidden = YES;
                    });
                    break;
                }
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}
    
/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) { style = @"<<"; }
    if (value > 0) { style = @">>"; }
    if (value == 0) { return; }
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    if (self.sumTime > self.player.duration) { self.sumTime = self.player.duration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    self.controlView.currentTimeLabel.text = [self stringWithNSTimerinterval:self.sumTime];
    self.controlView.horizontalLabel.hidden = NO;
    // 更新slider的进度
    self.controlView.videoSlider.value = (CGFloat)self.sumTime/self.player.duration;
    self.controlView.horizontalLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, [self stringWithNSTimerinterval:self.sumTime], [self stringWithNSTimerinterval:self.player.duration]];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - setting

- (void)setVideoURL:(NSString *)videoURL {
    _videoURL = videoURL;
    //[self.player stop];
    if (_player) {
        [self removeMovieNotificationObservers];
        [_player.view removeFromSuperview];
        [_player shutdown];
        _player = nil;
    }
    [self.controlView.activity startAnimating];
    self.player = [[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:_videoURL] withOptions:self.options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.autoresizesSubviews = YES;
    self.player.shouldAutoplay = YES;
    //self.player.shouldShowHudView = YES;
    [self insertSubview:self.player.view belowSubview:self.controlView];
    [self.player.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
        NSLog(@"%f,%f",self.player.currentPlaybackTime,self.player.duration);
        [self.controlView.activity stopAnimating];
        self.controlView.playButton.selected = YES;
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        [self.controlView.activity startAnimating];
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    [self pause];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    // 加载完成后，再添加平移手势
    // 添加平移手势，用来控制音量、亮度、快进快退
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    self.controlView.totalTimeLabel.text = [self stringWithNSTimerinterval:self.player.duration];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
 *  应用退到后台
 */
- (void)appDidEnterBackground
{
    //self.didEnterBackground = YES;
    [_player pause];
    //self.state = ZFPlayerStatePause;
    [self cancelAutoFadeOutControlBar];
    self.controlView.playButton.selected = NO;
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayGround
{
    //self.didEnterBackground = NO;
    self.isMaskShowing = NO;
    self.controlView.playButton.selected = YES;
    //self.isPauseByUser                 = NO;
    [self play];
    // 延迟隐藏controlView
    [self animateShow];
}


#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

#pragma mark - setting
/**
 *  设置播放视频前的占位图
 *
 *  @param placeholderImageName 占位图的图片名称
 */
- (void)setPlaceholderImageName:(NSString *)placeholderImageName {
    _placeholderImageName = placeholderImageName;
    if (placeholderImageName) {
        UIImage *image = [UIImage imageNamed:_placeholderImageName];
        self.layer.contents = (id)image.CGImage;
    }else {
        UIImage *image = [UIImage imageNamed:@"loading@3x"];
        self.layer.contents = (id)image.CGImage;
    }
}

#pragma mark - getting

- (IJKFFOptions *)options {
    if (!_options) {
        _options = [IJKFFOptions optionsByDefault];
        //[options setPlayerOptionIntValue:256    forKey:@"videotoolbox-max-frame-width"];
        [_options setPlayerOptionIntValue:60     forKey:@"max-fps"];
        
        //只播放视频，没有声音
        //[options setPlayerOptionValue:@"1" forKey:@"an"];
        //开启硬解码
        [_options setPlayerOptionIntValue:1  forKey:@"videotoolbox"];
        // 帧速率(fps) （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
        //[_options setPlayerOptionIntValue:29.97 forKey:@"r"];
        // -vol——设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推
        [_options setPlayerOptionIntValue:256 forKey:@"vol"];
    }
    return _options;
}

- (CCPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[CCPlayerControlView alloc]init];
    }
    return _controlView;
}

#pragma mark - Private Method

- (NSString *)stringWithNSTimerinterval:(NSTimeInterval)interval {
    NSInteger min = interval/60;
    NSInteger sec = (NSInteger)interval%60;
    return [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
}

@end
