//
//  URGentInfo.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 1/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "URGentInfo.h"

NSString *const URGentNowPlayingUpdateNotification = @"URGentNowPlayingUpdateNotification";

@interface URGentInfo()

@property (atomic) BOOL update;
@property (nonatomic) NSTimer* timer;

@end

@implementation URGentInfo

+ (URGentInfo *)sharedInfo
{
    static URGentInfo *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[URGentInfo alloc] init];
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
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(updateNowPlaying)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) stopUpdating
{
    self.update = NO;
    
    if (self.timer != nil)
        [self.timer invalidate];
}

- (void) updateNowPlaying
{
    NSString* url = @"http://urgent.fm/nowplaying/livetrack.txt";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *err = nil;

    NSString *txt = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];

    if(err)
    {
        VLog(err);
        //Handle 
    }
    if ([txt rangeOfString:@"Geen plaat(info)"].location == NSNotFound){
        if(self.nowPlaying == nil || [txt rangeOfString:self.nowPlaying].location == NSNotFound){
            // song playing and is not same song
            self.prevPlaying = self.nowPlaying;
            self.nowPlaying = txt;
            VLog(txt);
        }
    } else {
        if ( self.nowPlaying != nil ){
            // set nowPlaying as prevPlaying
            self.prevPlaying = self.nowPlaying;
            self.nowPlaying = nil;
        }
    }
}

@end
