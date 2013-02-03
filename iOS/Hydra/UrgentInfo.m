//
//  URGentInfo.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 1/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "UrgentInfo.h"

NSString *const UrgentNowPlayingUpdateNotification = @"UrgentNowPlayingUpdateNotification";
NSString *const UrgentProgramUpdateNotification = @"UrgentProgramUpdateNotification";

@interface UrgentInfo()

@property (atomic) BOOL update;
@property (nonatomic) NSTimer* trackTimer;
@property (nonatomic) NSTimer* progTimer;

@end

@implementation UrgentInfo

+ (UrgentInfo *)sharedInfo
{
    static UrgentInfo *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[UrgentInfo alloc] init];
    }
    return sharedInstance;
}
-(id)init
{
    if (self = [super init]) {
        self.nowPlaying = nil;
        self.update = NO;
    }
    return self;

}

- (void) startUpdating
{
    self.update = YES;
    [self updateNowPlaying];
    [self updateCurrentProgram];
    if (self.trackTimer == nil)
    {
        self.trackTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(updateNowPlaying)
                                   userInfo:nil
                                    repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.trackTimer forMode:NSRunLoopCommonModes];
    }
    if (self.progTimer == nil)
    {
        self.progTimer = [NSTimer scheduledTimerWithTimeInterval:900.0
                                                           target:self
                                                         selector:@selector(updateCurrentProgram)
                                                         userInfo:nil
                                                          repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.progTimer forMode:NSRunLoopCommonModes];
    }
}

- (void) stopUpdating
{
    self.update = NO;
    
    if (self.trackTimer != nil)
    {
        [self.trackTimer invalidate];
        self.trackTimer = nil;
    }
    if (self.progTimer != nil)
    {
        [self.progTimer invalidate];
        self.progTimer = nil;
    }
}

- (NSString*) stringFromURLString:(NSString*)urlstring
{
    NSURL *urlRequest = [NSURL URLWithString:urlstring];
    NSError *err = nil;

    NSString *txt = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];

    if(err)
    {
        VLog(err);
        //Handle
    }

    return txt;
}


- (void) updateNowPlaying
{
    NSString *const url = @"http://urgent.fm/nowplaying/livetrack.txt";
    NSString *txt = [self stringFromURLString:url];

    VLog(txt);
    if ( ![txt isEqualToString:@"Geen plaat(info)"] ){
        if(self.nowPlaying == nil || ![txt isEqualToString: self.nowPlaying]){
            // song playing and is not same song
            self.prevPlaying = self.nowPlaying;
            self.nowPlaying = txt;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:UrgentNowPlayingUpdateNotification object:self];
        }
    } else {
        if ( self.nowPlaying != nil ){
            // set nowPlaying as prevPlaying
            self.prevPlaying = self.nowPlaying;
            self.nowPlaying = nil;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:UrgentNowPlayingUpdateNotification object:self];
        }
    }
}

- (void) updateCurrentProgram
{
    NSString *const url = @"http://urgent.fm/nowplaying/program.php";
    NSString *txt = [self stringFromURLString:url];

    VLog(txt);
    if (self.currentProgram == nil || ![txt isEqualToString:self.currentProgram]){
        self.currentProgram = txt;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:UrgentNowPlayingUpdateNotification object:self];
    }
}

@end
