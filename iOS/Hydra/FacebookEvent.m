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
#import "NSMutableArray+Shuffling.h"
#import "AppDelegate.h"

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
        self.eventId = eventId;

        [self sharedInit];
        [self update];
    }
    return self;
}

- (void)sharedInit
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(facebookSessionStateChanged:)
                   name:FacebookSessionStateChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showExternally
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://event/%@", self.eventId]];
    if (![app canOpenURL:url]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://m.facebook.com/events/%@", self.eventId]];
    }
    [app openURL:url];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.valid = [coder decodeBoolForKey:@"valid"];
        self.eventId = [coder decodeObjectForKey:@"eventId"];
        self.lastUpdated = [coder decodeObjectForKey:@"lastUpdated"];
        self.smallImageUrl = [coder decodeObjectForKey:@"smallImageUrl"];
        self.largeImageUrl = [coder decodeObjectForKey:@"largeImageUrl"];
        self.attendees = [coder decodeIntegerForKey:@"attendees"];

        NSString *accessToken = [coder decodeObjectForKey:@"fbAccessToken"];
        if ([accessToken isEqualToString:[FBSession activeSession].accessToken]) {
            _friendsAttending = [coder decodeObjectForKey:@"friendsAttending"];
            _userRsvp = [coder decodeObjectForKey:@"userRsvp"];
        }

        [self sharedInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.valid forKey:@"valid"];
    [coder encodeObject:self.eventId forKey:@"eventId"];
    [coder encodeObject:self.lastUpdated forKey:@"lastUpdated"];
    [coder encodeObject:self.smallImageUrl forKey:@"smallImageUrl"];
    [coder encodeObject:self.largeImageUrl forKey:@"largeImageUrl"];
    [coder encodeInteger:self.attendees forKey:@"attendees"];

    // Store user-specific details with the access-token used
    [coder encodeObject:[FBSession activeSession].accessToken forKey:@"fbAccessToken"];
    [coder encodeObject:_friendsAttending forKey:@"friendsAttending"];
    [coder encodeObject:_userRsvp forKey:@"userRsvp"];
}

#pragma mark - Fetching info

- (void)update
{
    if (self.lastUpdated && [self.lastUpdated timeIntervalSinceNow] > -kUpdateInterval) {
        return;
    }

    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [self fetchEventInfo:connection];
    [self fetchUserInfo:connection];
    [self fetchFriendsInfo:connection];
    [connection start];

    self.lastUpdated = [NSDate date];
}

- (void)fetchEventInfo:(FBRequestConnection *)conn
{
    NSLog(@"Fetching information on event '%@'", self.eventId);
    NSString *q = [NSString stringWithFormat:
                   @"SELECT attending_count, pic, pic_big "
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

            NSString *smallImageUrl = data[@"pic"];
            if (smallImageUrl) {
                self.smallImageUrl = [NSURL URLWithString:smallImageUrl];
            }
            else {
                self.smallImageUrl = nil;
            }

            NSString *largeImageUrl = data[@"pic_big"];
            if (largeImageUrl) {
                self.largeImageUrl = [NSURL URLWithString:largeImageUrl];
            }
            else {
                self.largeImageUrl = nil;
            }

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
    if (![FacebookSession sharedSession].open) {
        return;
    }

    NSLog(@"Fetching user information on event '%@'", self.eventId);
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
    if (![FacebookSession sharedSession].open) {
        return;
    }

    NSLog(@"Fetching friends information on event '%@'", self.eventId);
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
        [friendsAttending H_shuffle];
        self.friendsAttending = friendsAttending;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:FacebookEventDidUpdateNotification object:self];
    }];
}

#pragma mark - Submitting info

- (void)setUserRsvp:(NSString *)userRsvp
{
    if ([userRsvp isEqualToString:_userRsvp]) {
        return;
    }

    // Open facebook-session
    FBSession *fb = [FBSession activeSession];
    if (![fb isOpen]) {
        [[FacebookSession sharedSession] openWithAllowLoginUI:YES completion:^{
            self.userRsvp = userRsvp;
        }];
    }
    // Check for permissions
    else if (![fb.permissions containsObject:@"rsvp_event"]) {
        NSLog(@"Requesting publishPermission 'rsvp_event'");
        [fb reauthorizeWithPublishPermissions:@[ @"rsvp_event" ]
                              defaultAudience:FBSessionDefaultAudienceFriends
                            completionHandler:^(FBSession *session, NSError *error) {
            if (error) {
                AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
                [delegate handleError:error];
            }
            else {
                self.userRsvp = userRsvp;
            }
        }];
    }
    else {
        // Real consistency in these API's
        if ([userRsvp isEqualToString:@"unsure"]) {
            userRsvp = @"maybe";
        }
        NSString *path = [NSString stringWithFormat:@"%@/%@", self.eventId, userRsvp];
        FBRequest *req = [FBRequest requestForPostWithGraphPath:path graphObject:nil];
        NSLog(@"POSTing presence to %@", path);
        [req startWithCompletionHandler:^(FBRequestConnection *c, id result, NSError *error) {
            if (error) {
                AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
                [delegate handleError:error];
            }
            else {
                _userRsvp = userRsvp;

                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:FacebookEventDidUpdateNotification object:self];
            }
        }];
    }
}

#pragma mark - Facebook session state

- (void)facebookSessionStateChanged:(NSNotification *)notification
{
    FBSession *session = [notification object];
    if (![session isOpen]) {
        _userRsvp = nil;
        _friendsAttending = nil;
    }
    // Force update on next access
    self.lastUpdated = nil;
}

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

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
}

@end