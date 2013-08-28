//
//  UrgentPlayer.m
//  Hydra
//
//  Created by Yasser Deceukelier on 18/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentPlayer.h"
#import "NSDate+Utilities.h"

#import <AVFoundation/AVFoundation.h>
#import <RestKit/RestKit.h>

#define kSongUpdateInterval 30
#define kShowUpdateInterval (30*60)
#define kDefaultSongInfo @"Geen plaat(info)"

#define kSongResourcePath @"http://urgent.fm/nowplaying/livetrack.txt"
#define kShowResourcePath @"http://urgent.fm/nowplaying/program.php"
#define kStreamResourcePath @"http://urgent.stream.flumotion.com/urgent/high.mp3.m3u"

NSString *const UrgentPlayerDidUpdateSongNotification =
    @"UrgentPlayerDidUpdateSongNotification";
NSString *const UrgentPlayerDidUpdateShowNotification =
    @"UrgentPlayerDidUpdateShowNotification";
NSString *const UrgentPlayerDidChangeStateNotification =
    @"UrgentPlayerDidChangeStateNotification";

void audioRouteChangeListenerCallback (void                   *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32                 inPropertyValueSize,
                                       const void             *inPropertyValue);

@interface UrgentPlayer ()

@property (nonatomic, strong) NSTimer *updateSongTimer;
@property (nonatomic, strong) NSTimer *updateShowTimer;

@end

@implementation UrgentPlayer

+ (UrgentPlayer *)sharedPlayer
{
    static UrgentPlayer *sharedInstance = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURL *url = [NSURL URLWithString:kStreamResourcePath];
        sharedInstance = [[UrgentPlayer alloc] initWithURL:url];
    });

    return sharedInstance;
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [super initWithContentURL:url]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(playerStateChanged:)
                       name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        [center addObserver:self selector:@selector(playerFinished:)
                       name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleRemoteEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
        case UIEventSubtypeRemoteControlStop:
            [self stop];
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self isPlaying] ? [self pause] : [self play];
            break;
        default:
            break;
    }
}

- (void)play
{
    if ([self isPlaying]) {
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
    [super play];
}

- (void)stop
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,
                                                   audioRouteChangeListenerCallback, NULL);
    [super stop];
}

- (BOOL)isPlaying
{
    return self.playbackState == MPMoviePlaybackStatePlaying;
}

- (BOOL)isPaused
{
    return self.playbackState == MPMoviePlaybackStatePaused;
}

- (void)playerStateChanged:(NSNotification *)notification
{
    [self playerStateChanged];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:UrgentPlayerDidChangeStateNotification object:self];
}

- (void)playerFinished:(NSNotification *)notification
{
    // Force the player to stop completely, otherwise restarting the player
    // does not seem to work
    [self stop];
}

#pragma mark - Timer management

- (void)playerStateChanged
{
    // Update timers
    if ([self isPlaying]) {
        // The state of updateSongTimer and updateShowTimer should always be equal
        if (![self.updateSongTimer isValid]) {
            [self scheduleTimers];
        }
    }
    else {
        [self cancelTimers];
        self.currentShow = nil;
        self.currentSong = nil;
        self.previousSong = nil;
    }

    [self updateNowPlaying];
}

- (void)updateNowPlaying
{
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    if ([self isPlaying]) {
        // Cover art
        UIImage *cover = [UIImage imageNamed:@"urgent-nowplaying.jpg"];
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:cover];

        // Meta-data
        NSString *albumTitle = @"Urgent.fm";
        if (self.currentShow) {
            albumTitle = [self.currentShow stringByAppendingString:@" - Urgent.fm"];
        }
        NSString *title;
        if (self.currentSong && ![self.currentSong isEqualToString:kDefaultSongInfo]) {
            title = self.currentSong;
        }
        else {
            title = albumTitle;
            albumTitle = @"";
        }

        center.nowPlayingInfo = @{
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyAlbumTitle: albumTitle,
            MPMediaItemPropertyArtwork: artwork
        };
    }
    else if ([self isPaused]) {
        center.nowPlayingInfo = @{
            MPMediaItemPropertyTitle: @"Urgent.fm"
        };
    }
    else {
        center.nowPlayingInfo = nil;
    }
}

- (void)scheduleTimers
{
    // Update songs every 30 seconds
    self.updateSongTimer = [NSTimer timerWithTimeInterval:kSongUpdateInterval target:self
                                                 selector:@selector(songUpdateTimerFired:)
                                                 userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateSongTimer forMode:NSDefaultRunLoopMode];
    [self.updateSongTimer fire];

    // Update show every 30 minutes
    self.updateShowTimer = [NSTimer timerWithTimeInterval:kShowUpdateInterval target:self
                                                 selector:@selector(showUpdateTimerFired:)
                                                 userInfo:nil repeats:YES];

    // Schedule the timer for the next half hour
    NSDate *next = [[NSDate date] dateByAddingMinutes:30];
    self.updateShowTimer.fireDate = [next dateBySubtractingMinutes:(next.minute % 30)];

    [[NSRunLoop currentRunLoop] addTimer:self.updateShowTimer forMode:NSDefaultRunLoopMode];
    [self.updateShowTimer fire];
}

- (void)cancelTimers
{
    [self.updateSongTimer invalidate];
    self.updateSongTimer = nil;
    [self.updateShowTimer invalidate];
    self.updateShowTimer = nil;
}

#pragma mark - Fetching resources

- (void)songUpdateTimerFired:(NSTimer *)sender
{
    DLog(@"Updating current song");
    [self fetchString:kSongResourcePath withCompletion:^(NSString *song) {
        BOOL isNoSongInfo = [song isEqualToString:kDefaultSongInfo];
        BOOL requiresNotification = ![self.currentSong isEqualToString:song];

        if (!self.currentSong && isNoSongInfo) {
            return;
        }

        // Just overwrite the currentSong value if it didn't contain info
        if ([self.currentSong isEqualToString:kDefaultSongInfo]) {
            self.currentSong = song;
        }
        else if (![self.currentSong isEqualToString:song]) {
            self.previousSong = self.currentSong;
            self.currentSong = song;
        }

        [self updateNowPlaying];
        if (requiresNotification) {
            DLog(@"currentSong = %@, previousSong = %@", self.currentSong, self.previousSong);
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:UrgentPlayerDidUpdateSongNotification object:self];
        }
    }];
}

- (void)showUpdateTimerFired:(NSTimer *)sender
{
    DLog(@"Updating current show");
    [self fetchString:kShowResourcePath withCompletion:^(NSString *show) {
        if (![self.currentShow isEqualToString:show]) {
            DLog(@"currentShow = %@", show);
            self.currentShow = show;
            [self updateNowPlaying];

            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:UrgentPlayerDidUpdateShowNotification object:self];
        }
    }];
}

- (void)fetchString:(NSString *)resource withCompletion:(void (^)(NSString *result))completion
{
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        NSURL *resourceUrl = [NSURL URLWithString:resource];

        NSError *error = nil;
        NSString *result = [NSString stringWithContentsOfURL:resourceUrl
                                                    encoding:NSISOLatin1StringEncoding
                                                       error:&error];
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        result = [result stringByTrimmingCharactersInSet:set];
        if (error) {
            NSLog(@"Error while fetching resource %@: %@", resource, error);
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    });
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
    if (![player isPlaying]) {
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
        }
        else {
            DLog(@"A route change occurred that does not require pausing of application audio.");
        }
    }
}
