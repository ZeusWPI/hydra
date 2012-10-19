//
//  UrgentPlayer.h
//  Hydra
//
//  Created by Yasser Deceukelier on 18/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"

@interface UrgentPlayer : AudioStreamer

+ (UrgentPlayer *)sharedPlayer;

@end
