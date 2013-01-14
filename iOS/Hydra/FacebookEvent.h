//
//  HFBEvent.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FacebookEventDidUpdateNotification;

@interface FacebookEvent : NSObject
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *attendees;
@property (strong, nonatomic) NSArray *friendsAttending;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (nonatomic) BOOL userAttending;

-(id)initWithEventID:(NSString*)eventID;
-(void)postUserAttendsEvent:(id)sender;

@end

@interface FacebookEventFriends : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uid;

-(id)initWithName:(NSString*)name andUserID:(NSString*)uid;
@end
