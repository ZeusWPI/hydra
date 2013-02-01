//
//  URGentInfo.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 1/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "UrgentInfo.h"

NSString *const UrgentNowPlayingUpdateNotification = @"UrgentNowPlayingUpdateNotification";

@interface UrgentInfo()

@property (atomic) BOOL update;
@property (nonatomic) NSTimer* timer;

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

    if (self.timer == nil)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(updateNowPlaying)
                                   userInfo:nil
                                    repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void) stopUpdating
{
    self.update = NO;
    
    if (self.timer != nil)
    {
        [self.timer invalidate];
    }
}

- (void) updateNowPlaying
{
    NSString *const url = @"http://urgent.fm/nowplaying/livetrack.txt";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *err = nil;

    NSString *txt = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];

    if(err)
    {
        VLog(err);
        //Handle 
    }
    VLog(txt);
    if ( ![txt isEqualToString:@"Geen plaat(info)"] ){
        if(self.nowPlaying == nil || [txt rangeOfString:self.nowPlaying].location == NSNotFound){
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

@end
