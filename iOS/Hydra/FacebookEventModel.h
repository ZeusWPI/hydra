//
//  HFBEventFunctions.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookEvent.h"

extern NSString *const FacebookEventModelDidUpdateNotification;

@interface FacebookEventModel : NSObject

+ (FacebookEventModel*)sharedModel;

- (FacebookEvent*)eventForEventID:(NSString*)eventID;
@end