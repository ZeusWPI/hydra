//
//  URGentInfo.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 1/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const UrgentNowPlayingUpdateNotification;
extern NSString *const UrgentProgramUpdateNotification;

@interface UrgentInfo : NSObject

@property (nonatomic, strong) NSString *prevPlaying;
@property (nonatomic, strong) NSString *nowPlaying;
@property (nonatomic, strong) NSString *currentProgram;

- (void) startUpdating;
- (void) stopUpdating;

+ (UrgentInfo *)sharedInfo;

@end
