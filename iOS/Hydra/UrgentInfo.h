//
//  URGentInfo.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 1/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const UrgentNowPlayingUpdateNotification;

@interface UrgentInfo : NSObject

@property (retain, strong) NSString *prevPlaying;
@property (retain, strong) NSString *nowPlaying;

- (void) startUpdating;
- (void) stopUpdating;

+ (UrgentInfo *)sharedInfo;

@end
