//
//  FacebookEvent.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "FacebookEvent.h"
#import <FacebookSDK.h>
#import "FacebookSession.h"

#define kUpdateInterval (15 * 60) /* Update every 15 minutes */

NSString *const FacebookEventDidUpdateNotification = @"FacebookEventDidUpdateNotification";

@interface FacebookEvent ()

@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSDate *lastUpdated;

@end

@implementation FacebookEvent

- (id)initWithEventId:(NSString *)eventId
{
    if (self = [super init]) {
        self.eventId = @"141011552728829";
        [self update];

        // TODO: listen for facebook state changes so we can remove
        // all user specific state
    }
    return self;
}

#pragma mark - Fetching info

- (void)update
{
    DLog(@"%f", [self.lastUpdated timeIntervalSinceNow]);

    // DEBUG: force opening session
    [[FacebookSession sharedSession] openSessionWithAllowLoginUI:YES];

    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [self fetchEventInfo:connection];
    [self fetchUserInfo:connection];
    [self fetchFriendsInfo:connection];
    [connection start];

    self.lastUpdated = [NSDate date];
}

- (void)fetchEventInfo:(FBRequestConnection *)conn
{
    NSString *q = [NSString stringWithFormat:
                   @"SELECT attending_count, pic_square, pic_big "
                    "FROM event WHERE eid = '%@'", self.eventId];
    FBRequest *request = [[FacebookSession sharedSession] requestWithQuery:q];

    [conn addRequest:request completionHandler:^(FBRequestConnection *c, id result, NSError *error) {
        if (error) {
            NSLog(@"Error while fetching information on event '%@': %@",
                  self.eventId, [error localizedDescription]);
            return;
        }

        if ([result[@"data"] count] > 0) {
            self.valid = YES;

            NSDictionary *data = result[@"data"][0];
            self.attendees = [data[@"attending_count"] intValue];
            self.squareImageUrl = data[@"pic_square"];
            self.largeImageUrl = data[@"pic_big"];

            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:FacebookEventDidUpdateNotification object:self];
        }
        else {
            NSLog(@"Could not find information on event '%@'", self.eventId);
        }
    }];
}

- (void)fetchUserInfo:(FBRequestConnection *)conn
{
    if (![[FBSession activeSession] isOpen]) {
        return;
    }

    NSString *q = [NSString stringWithFormat:
                   @"SELECT rsvp_status FROM event_member "
                    "WHERE eid = '%@' AND uid = me()", self.eventId];
    FBRequest *request = [[FacebookSession sharedSession] requestWithQuery:q];

    [conn addRequest:request completionHandler:^(FBRequestConnection *c, id result, NSError *error) {
        if (error) {
            NSLog(@"Error while fetching user information on event '%@': %@",
                  self.eventId, [error localizedDescription]);
            return;
        }

        if ([result[@"data"] count] > 0) {
            NSDictionary *data = result[@"data"][0];
            _userRsvp = data[@"rsvp_status"];
        }
        else {
            _userRsvp = nil;
        }

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:FacebookEventDidUpdateNotification object:self];
    }];
}

- (void)fetchFriendsInfo:(FBRequestConnection *)conn
{
    if (![[FBSession activeSession] isOpen]) {
        return;
    }

    NSString *q = [NSString stringWithFormat:
                   @"SELECT name, pic_square FROM user WHERE uid IN "
                    "(SELECT uid2 FROM friend WHERE uid1 = me() AND uid2 IN "
                    "(SELECT uid FROM event_member WHERE eid = '%@' AND "
                    "rsvp_status = 'attending'))", self.eventId];
    FBRequest *request = [[FacebookSession sharedSession] requestWithQuery:q];

    [conn addRequest:request completionHandler:^(FBRequestConnection *c, id result, NSError *error) {
        if (error) {
            NSLog(@"Error while fetching friends information on event '%@': %@",
                  self.eventId, [error localizedDescription]);
            return;
        }

        NSMutableArray *friendsAttending = [NSMutableArray array];
        for (NSDictionary *item in result[@"data"]) {
            FacebookEventFriend *friend = [[FacebookEventFriend alloc]
                                           initWithName:item[@"name"]
                                               photoUrl:item[@"pic_square"]];
            [friendsAttending addObject:friend];
        }
        self.friendsAttending = friendsAttending;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:FacebookEventDidUpdateNotification object:self];
    }];
}

#pragma mark - Submitting info

- (void)setUserRsvp:(NSString *)userRsvp
{
    // TODO
}

/*
-(void)postUserAttendsEvent{
    
    if (self.userAttending){
        return;
    }
    
    NSString *query = [NSString stringWithFormat:@"%@/attending/me", self.eventId];

    // Ask for rspv_events permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"rsvp_event"] == NSNotFound) {
         // No permissions found in session, ask for it
            [FBSession.activeSession
             reauthorizeWithPublishPermissions:
             [NSArray arrayWithObject:@"rsvp_event"]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if(error){
                     //error
                     VLog(error);
                 }
                 if (!error) {
                 }
             }];
        }
        FBRequestConnection *conn = [[FBRequestConnection alloc] init];
        FBRequest *req1 = [FBRequest requestForPostWithGraphPath:query graphObject:nil];
        [conn addRequest:req1 completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
            } else {
                NSLog(@"Result: %@", result);
                self.userAttending = YES;
            }
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:FacebookEventDidUpdateNotification object:self];
        }];
        [conn start];
} */

@end

@implementation FacebookEventFriend

- (id)initWithName:(NSString *)name photoUrl:(NSString *)url;
{
    if (self = [super init]) {
        self.name = name;
        if (url) {
            self.photoUrl = [NSURL URLWithString:url];
        }
    }
    return self;
}

@end