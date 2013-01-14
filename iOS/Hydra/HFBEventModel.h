//
//  HFBEventFunctions.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HFBEvent.h"

extern NSString *const HFBEventModelDidUpdateNotification;

@interface HFBEventModel : NSObject

+ (HFBEventModel*)sharedModel;

- (HFBEvent*)eventForEventID:(NSString*)eventID;
@end