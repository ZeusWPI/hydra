//
//  HFBEventFunctions.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "HFBEventModel.h"

NSString *const HFBEventModelDidUpdateNotification = @"HFBEventModelDidUpdateNotification";

@interface HFBEventModel ()

@property (strong,nonatomic) NSMutableDictionary *events;

@end

@implementation HFBEventModel
+ (HFBEventModel*)sharedModel
{
    static HFBEventModel *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        if (!sharedInstance) sharedInstance = [[HFBEventModel alloc] init];
    }
    return sharedInstance;
}

- (HFBEvent*)eventForEventID:(NSString*)eventID
{
    HFBEvent *event = self.events[eventID];
    if(!event)
    {
        event = [self createNewEvent:eventID];
    }
    
    return event;
}

- (HFBEvent*)createNewEvent:(NSString*)eventID
{
    HFBEvent *event = [[HFBEvent alloc] init];
    [event configureWithEventID:eventID];
    self.events[eventID] = event;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:HFBEventModelDidUpdateNotification object:self];
    return event;
}
@end
