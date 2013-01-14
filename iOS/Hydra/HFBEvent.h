//
//  HFBEvent.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HFBEvent : NSObject
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *attendees;
@property (strong, nonatomic) NSArray *friendsAttending;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (nonatomic) BOOL userAttending;

-(void)configureWithEventID:(NSString*)eventID;
-(void)postUserAttendsEvent:(id)sender;

@end

@interface HFBEventFriends : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uid;

-(HFBEventFriends*)initWithName:(NSString*)name andUserID:(NSString*)uid;
@end
