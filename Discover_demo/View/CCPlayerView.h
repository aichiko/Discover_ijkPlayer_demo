//
//  CCPlayerView.h
//  Discover_demo
//
//  Created by 24hmb on 16/9/7.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

typedef void(^CCPlayerBackCallback)(void);

@interface CCPlayerView : UIView
/** 视频流地址  */
@property (nonatomic, retain) NSString *videoURL;

@property (retain, nonatomic) IJKFFMoviePlayerController<IJKMediaPlayback> *player;

/** 播放前占位图片的名称，不设置就显示默认占位图（需要在设置视频URL之前设置） */
@property (nonatomic, copy) NSString *placeholderImageName;

@property (nonatomic, copy) CCPlayerBackCallback goBackBlock;

/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL isLocked;

@end
