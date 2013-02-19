//
//  FacebookEvent.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FacebookEventDidUpdateNotification;

typedef NS_ENUM(NSUInteger, FacebookEventRsvp) {
    FacebookEventRsvpNone = 0,
    FacebookEventRsvpAttending,
    FacebookEventRsvpUnsure,
    FacebookEventRsvpDeclined,
};

NSString *FacebookEventRsvpAsLocalizedString(FacebookEventRsvp rsvp);
FacebookEventRsvp FacebookEventRsvpFromString(NSString *rsvp);

@interface FacebookEvent : NSObject <NSCoding>

@property (nonatomic, assign) BOOL valid;

@property (nonatomic, strong) NSURL *smallImageUrl;
@property (nonatomic, strong) NSURL *largeImageUrl;

@property (nonatomic, assign) NSUInteger attendees;
@property (nonatomic, strong) NSArray *friendsAttending;
@property (nonatomic, assign) FacebookEventRsvp userRsvp;
@property (nonatomic, assign) BOOL userRsvpUpdating;

- (id)initWithEventId:(NSString *)eventId;
- (void)update;
- (void)showExternally;

@end

@interface FacebookEventFriend : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *photoUrl;

- (id)initWithName:(NSString *)name photoUrl:(NSString *)url;

@end
