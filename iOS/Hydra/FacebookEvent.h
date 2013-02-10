//
//  FacebookEvent.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FacebookEventDidUpdateNotification;

@interface FacebookEvent : NSObject

@property (nonatomic, assign) BOOL valid;

@property (nonatomic, strong) NSString *squareImageUrl;
@property (nonatomic, strong) NSString *largeImageUrl;

@property (nonatomic, assign) NSUInteger attendees;
@property (nonatomic, strong) NSArray *friendsAttending;
@property (nonatomic, strong) NSString *userRsvp; /* attending, unsure, declined, or not_replied */

- (id)initWithEventId:(NSString *)eventId;

@end

@interface FacebookEventFriend : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *photoUrl;

- (id)initWithName:(NSString *)name photoUrl:(NSString *)url;

@end
