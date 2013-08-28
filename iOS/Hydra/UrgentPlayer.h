//
//  UrgentPlayer.h
//  Hydra
//
//  Created by Yasser Deceukelier on 18/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

extern NSString *const UrgentPlayerDidUpdateSongNotification;
extern NSString *const UrgentPlayerDidUpdateShowNotification;
extern NSString *const UrgentPlayerDidChangeStateNotification;

@interface UrgentPlayer : MPMoviePlayerController

@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *previousSong;
@property (nonatomic, strong) NSString *currentShow;

+ (UrgentPlayer *)sharedPlayer;

- (void)handleRemoteEvent:(UIEvent *)event;
- (BOOL)isPlaying;
- (BOOL)isPaused;

@end
