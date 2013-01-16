//
//  ApplicationWithRemoteSupport.m
//  Hydra
//
//  Created by Pieter De Baets on 06/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ApplicationWithRemoteSupport.h"
#import "UrgentPlayer.h"

@implementation ApplicationWithRemoteSupport

- (id)init
{
    if (self = [super init]) {
        [self becomeFirstResponder];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// Forward all remote events to the Urgent player
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        UrgentPlayer *player = [UrgentPlayer sharedPlayer];
        [player handleRemoteEvent:event];
    }
}

@end
