//
//  CCPlayerControlView.h
//  Discover_demo
//
//  Created by 24hmb on 16/9/8.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SliderTapBlock)(CGFloat value);

/**
 *  控制视图，快进，退后，点击等事件的实现
 */
@interface CCPlayerControlView : UIView
/**  播放按钮 */
@property (nonatomic, strong) UIButton *playButton;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView *progressView;
/** 滑杆 */
@property (nonatomic, strong) UISlider *videoSlider;
/**  返回按钮 */
@property (nonatomic, strong) UIButton *backButton;
/**  关注按钮 */
@property (nonatomic, strong) UIButton *careButton;
/**  分享按钮 */
@property (nonatomic, strong) UIButton *shareButton;
/**  选会场按钮 */
@property (nonatomic, strong) UIButton *selectButton;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton *fullScreenButton;
/** 系统菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;
/** 强制锁屏按钮 */
@property (nonatomic, strong) UIButton *lockScreenButton;
/** 快进快退label */
@property (nonatomic, strong) UILabel *horizontalLabel;
/**
 *  slider的点击事件，根据点击来设置当前播放时间
 */
@property (nonatomic, copy) SliderTapBlock tapBlock;

/**
 是否横屏，横屏则隐藏careButton和shareButton，显示selectButton
 */
@property (nonatomic, assign) BOOL isLandscape;

/** 
 *  显示top、bottom、lockScreenButton
 */
- (void)showControlView;
/** 
 *  隐藏top、bottom、lockScreenButton
 */
- (void)hideControlView;


@end
