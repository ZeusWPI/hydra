//
//  UrgentPlayer.m
//  Hydra
//
//  Created by Yasser Deceukelier on 18/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

void audioRouteChangeListenerCallback (void                   *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32                 inPropertyValueSize,
                                       const void             *inPropertyValue);

@implementation UrgentPlayer

+ (UrgentPlayer *)sharedPlayer
{
    static UrgentPlayer *sharedInstance = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // TODO: use http://urgent.stream.flumotion.com/urgent/high.mp3.m3u
        NSURL *url = [NSURL URLWithString:@"http://195.10.10.207/urgent/high.mp3"];
        sharedInstance = [[UrgentPlayer alloc] initWithURL:url];
    });

    return sharedInstance;
}

- (id)initWithURL:(NSURL *)url_
{
    if (self = [super initWithURL:url_]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateNowPlaying:)
                       name:ASStatusChangedNotification object:self];
    }
    return self;
}

- (void)handleRemoteEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        if (self.isPlaying) {
            [self pause];
        }
        else {
            [self start];
        }
    }
}

- (void)start
{
    if (self.isPlaying) {
        return;
    }

    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Error in AVAudioSession.setCategory: %@", [error localizedDescription]);
        return;
    }

    // Registers the audio route change listener callback function
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                    audioRouteChangeListenerCallback, NULL);

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    // TODO: sometimes the app will livelock when it's called here from
    // the lock screen and an error occurs.
    [super start];
}

- (void)stop
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,
                                                   audioRouteChangeListenerCallback, NULL);
    [super stop];
}

- (void)updateNowPlaying:(NSNotification *)notification
{
    // Available since iOS5
    if ([MPNowPlayingInfoCenter class]) {
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        if (self.isPlaying) {
            UIImage *cover = [UIImage imageNamed:@"nowplaying-urgent"];
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:cover];
            center.nowPlayingInfo = @{
                // TODO: get program name
                MPMediaItemPropertyTitle: @"Urgent.fm",
                MPMediaItemPropertyArtwork: artwork
            };
        }
        else if (self.isPaused) {
            center.nowPlayingInfo =  @{
                MPMediaItemPropertyTitle: @"Urgent.fm"
            };
        }
        else {
            center.nowPlayingInfo = nil;
        }
    }
}

@end

// Audio session callback function for responding to audio route changes. If playing
// back application audio when the headset is unplugged, this callback pauses
// playback and displays an alert that allows the user to resume or stop playback.
//
// The system takes care of iPod audio pausing during route changes--this callback
// is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (void                   *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32                 inPropertyValueSize,
                                       const void             *inPropertyValue)
{
    // Ensure that this callback was invoked for a route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;

    UrgentPlayer *player = [UrgentPlayer sharedPlayer];

    // Ff application sound is not playing, there's nothing to do, so return.
    if (player.isPlaying == 0 ) {
        DLog(@"Audio route change while application audio is stopped.");
        return;
    }
    else {
        // Determines the reason for the route change, to ensure that it is not
        // because of a category change.
        CFDictionaryRef routeChangeDictionary = inPropertyValue;

        CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(
            routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));

        SInt32 routeChangeReason;
        CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);

        // "Old device unavailable" indicates that a headset was unplugged, or that the
        // device was removed from a dock connector that supports audio output. This is
        // the recommended test for when to pause audio.
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            NSLog(@"Output device removed, so application audio was paused.");
            [player pause];
        } else {
            DLog(@"A route change occurred that does not require pausing of application audio.");
        }
    }
}
