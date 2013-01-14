//
//  HFBEventFunctions.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "FacebookEventModel.h"

NSString *const FacebookEventModelDidUpdateNotification = @"FacebookEventModelDidUpdateNotification";

@interface FacebookEventModel ()

@property (strong,nonatomic) NSMutableDictionary *events;

@end

@implementation FacebookEventModel
+ (FacebookEventModel*)sharedModel
{
    static FacebookEventModel *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        if (!sharedInstance) sharedInstance = [[FacebookEventModel alloc] init];
    }
    return sharedInstance;
}

- (FacebookEvent*)eventForEventID:(NSString*)eventID
{
    FacebookEvent *event = self.events[eventID];
    if(!event)
    {
        event = [self createNewEvent:eventID];
    }
    
    return event;
}

- (FacebookEvent*)createNewEvent:(NSString*)eventID
{
    FacebookEvent *event = [[FacebookEvent alloc] initWithEventID:eventID];
    self.events[eventID] = event;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:FacebookEventModelDidUpdateNotification object:self];
    return event;
}
@end
