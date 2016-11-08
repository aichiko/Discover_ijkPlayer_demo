//
//  CCPlayerControlView.m
//  Discover_demo
//
//  Created by 24hmb on 16/9/8.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "CCPlayerControlView.h"

@interface CCPlayerControlView ()

@property (nonatomic, strong) UILabel *titleLabel;
/** bottomView*/
@property (nonatomic, strong) UIImageView *bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView *topImageView;

@end

@implementation CCPlayerControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    
    [self addSubview:self.topImageView];
    [self addSubview:self.bottomImageView];
    [self addSubview:self.activity];
    [self addSubview:self.lockScreenButton];
    [self addSubview:self.horizontalLabel];
    [self addSubview:self.backButton];
    
    
    [self.topImageView addSubview:self.titleLabel];
    [self.topImageView addSubview:self.careButton];
    [self.topImageView addSubview:self.shareButton];
    [self.topImageView addSubview:self.selectButton];
    
    [self.bottomImageView addSubview:self.playButton];
    [self.bottomImageView addSubview:self.progressView];
    [self.bottomImageView addSubview:self.videoSlider];
    [self.bottomImageView addSubview:self.currentTimeLabel];
    [self.bottomImageView addSubview:self.totalTimeLabel];
    [self.bottomImageView addSubview:self.fullScreenButton];
    [self.bottomImageView addSubview:self.videoSlider];
    
    [self subviewsConstrains];
    
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
    [self.videoSlider addGestureRecognizer:sliderTap];
    
    [self resetControlView];
}

- (void)subviewsConstrains {
    [_topImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [_bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.mas_top).offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right).mas_offset(2);
        make.width.mas_lessThanOrEqualTo(200);
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    [_careButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.mas_equalTo(-60);
    }];

    [_shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.mas_equalTo(-15);
    }];
    
    [_selectButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.right.mas_equalTo(-30);
    }];
    
    [_currentTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.playButton.mas_trailing).offset(-3);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-5);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
    
    [_totalTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenButton.mas_leading).offset(3);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [_videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).mas_offset(4);
        make.right.equalTo(self.totalTimeLabel.mas_left).mas_offset(-4);
        make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    
    [_activity mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [_lockScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
    
    [_horizontalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(33);
        make.center.equalTo(self);
    }];
}

#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView
{
    self.videoSlider.value = 0;
    self.progressView.progress = 0;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
    self.backgroundColor = [UIColor clearColor];
    self.horizontalLabel.hidden = YES;
}

- (void)showControlView
{
    self.topImageView.alpha = 1;
    self.bottomImageView.alpha = 1;
    self.lockScreenButton.alpha = 1;
}

- (void)hideControlView
{
    self.topImageView.alpha = 0;
    self.bottomImageView.alpha = 0;
    self.lockScreenButton.alpha = 0;
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]] && self.tapBlock) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        self.tapBlock(tapValue);
    }
}

#pragma mark - setting

- (void)setIsLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    if (_isLandscape) {
        self.selectButton.hidden = NO;
        self.careButton.hidden = YES;
        self.shareButton.hidden = YES;
    }else {
        self.selectButton.hidden = YES;
        self.careButton.hidden = NO;
        self.shareButton.hidden = NO;
    }
}

#pragma mark - getting

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CCPlayer_top_shadow"]];
        _topImageView.userInteractionEnabled = YES;
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CCPlayer_bottom_shadow"]];
        _bottomImageView.userInteractionEnabled = YES;
    }
    return _bottomImageView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"meetPlay_back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.text = @"视频标题";
    }
    return _titleLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"CCPlayer_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"CCPlayer_pause"] forState:UIControlStateSelected];
    }
    return _playButton;
}

- (UIButton *)careButton {
    if (!_careButton) {
        _careButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_careButton setImage:[UIImage imageNamed:@"meetPlay_like"] forState:UIControlStateNormal];
        [_careButton setImage:[UIImage imageNamed:@"meetPlay_just_like@2x"] forState:UIControlStateSelected];
    }
    return _careButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"meetPlay_share"] forState:UIControlStateNormal];
    }
    return _shareButton;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setTitle:@"选会场" forState:UIControlStateNormal];
        [_selectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return _selectButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc]init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"CCPlayer_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"CCPlayer_shrinkscreen"] forState:UIControlStateSelected];
    }
    return _fullScreenButton;
}

- (UIButton *)lockScreenButton {
    if (!_lockScreenButton) {
        _lockScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockScreenButton setImage:[UIImage imageNamed:@"CCPlayer_unlock-nor"] forState:UIControlStateNormal];
        [_lockScreenButton setImage:[UIImage imageNamed:@"CCPlayer_lock-nor"] forState:UIControlStateSelected];
    }
    return _lockScreenButton;
}

- (UISlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc]init];
        [_videoSlider setThumbImage:[UIImage imageNamed:@"CCPlayer_slider"] forState:UIControlStateNormal];
        _videoSlider.maximumValue = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _videoSlider;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.color = [UIColor redColor];
    }
    return _activity;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (UILabel *)horizontalLabel {
    if (!_horizontalLabel) {
        _horizontalLabel = [[UILabel alloc]init];
        _horizontalLabel.textColor = [UIColor whiteColor];
        _horizontalLabel.textAlignment = NSTextAlignmentCenter;
        _horizontalLabel.font = [UIFont systemFontOfSize:15.0];
        _horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CCPlayer_management_mask"]];
    }
    return _horizontalLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
