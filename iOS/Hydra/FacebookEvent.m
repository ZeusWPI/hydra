//
//  HFBEvent.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "FacebookEvent.h"
#import "FacebookEventModel.h"
#import <FacebookSDK.h>

#define kUpdateInterval 60*60 //Every hour

NSString *const FacebookEventDidUpdateNotification = @"FacebookEventDidUpdateNotification";

@implementation FacebookEvent

-(FacebookEvent*)initWithEventID:(NSString *)eventID
{
    if (self = [super init]){
        self.eventID = eventID;
        self.imageURL = nil;
        self.attendees = nil;
        self.friendsAttending = nil;
        self.lastUpdated = nil;
        self.userAttending = NO;
        [self requestInfo];
    }
    return self;
}

-(void)requestInfo
{
    self.lastUpdated = [NSDate date];
    
    FBRequestConnection *conn = [[FBRequestConnection alloc] init];

    [conn addRequest:[self createBasicInfoQuery] completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Result basic info: %@", result);
            NSArray *arr = (NSArray*)[result objectForKey:@"data"];
            self.attendees = (NSString*)[arr[0] objectForKey:@"attending_count"];
            self.imageURL = (NSString*)[arr[0] objectForKey:@"pic_big"];
        }}];

    if([self usersInfoPermission])
       {
  
    [conn addRequest:[self createUserAttendingRequest] completionHandler:^(FBRequestConnection *connection,
                                                      id result,
                                                      NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            //NSLog(@"Result userInfo: %@", result);
            NSArray *obj = (NSArray*)[result objectForKey:@"data"];
            VLog(obj);
            
            BOOL attending = [obj count] == 1 ? YES : NO;
            if (attending){
                VLog([obj[0] objectForKey:@"rsvp_status"]);
                
                NSString *str = (NSString*)[obj[0] objectForKey:@"rsvp_status"];
                if ([str rangeOfString:@"attend"].location == NSNotFound){
                    attending = NO;
                }
            }
            self.userAttending = attending;
        }
    }];
           [conn addRequest:[self createFriendsAttendingRequest] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
               if (error){
                   NSLog(@"Error: %@", [error localizedDescription]);
               }else{
                   [self addAttendingFriends:result];
               }}];

       }
    [conn start];
}


#pragma mark Queries
-(FBRequest*)createRequestFromQuery:(NSString*)query
{
    // Set up the query parameter
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys: query, @"q", nil];
    FBRequest *request = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    return request;
}

-(FBRequest*)createBasicInfoQuery
{
    // returns the number of people attending, and link to picture
    NSString *query = [NSString stringWithFormat:@"SELECT attending_count, pic_big FROM event WHERE eid='%@'",self.eventID];
    VLog(query);
    return [self createRequestFromQuery:query];
}

-(FBRequest*)createFriendsAttendingRequest
{
    // query to get friends info from event, which friends are attending
    NSString *query = [NSString stringWithFormat:@"SELECT uid, name FROM user where uid IN (SELECT uid2 from friend WHERE uid2 IN (SELECT uid FROM event_member WHERE eid = '%@' and rsvp_status = 'attending') AND uid1 = me())", self.eventID];
    VLog(query);
    return [self createRequestFromQuery:query];
}

-(FBRequest*)createUserAttendingRequest
{
    NSString *query = [NSString stringWithFormat:@"SELECT uid, rsvp_status FROM event_member WHERE eid = '%@' AND uid = me() ", self.eventID];
    VLog(query);
    return [self createRequestFromQuery:query];
}

#pragma mark Result
- (void)addAttendingFriends:(id)result
{
   // VLog(result);
    NSArray *res = (NSArray*)[result objectForKey:@"data"];
    if ([res count]){
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[res count]];
        for (id<FBGraphObject> obj in res){
            NSString *name = (NSString*)[obj objectForKey:@"name"];
            NSString *uid = (NSString*)[obj objectForKey:@"uid"];
            FacebookEventFriends *friend = [[FacebookEventFriends alloc] initWithName:name andUserID:uid];
            [arr addObject:friend];
        }
        self.friendsAttending = (NSArray*)arr;
    }else{
        self.friendsAttending = [[NSArray alloc] initWithObjects:nil];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:FacebookEventDidUpdateNotification object:self];
}

#pragma mark Updating
-(void)update
{
    if ([self.lastUpdated timeIntervalSinceNow] > kUpdateInterval) {
        [self requestInfo];
    }
}

#pragma mark Permissions
// checks if a user is logged on
-(BOOL)usersInfoPermission
{
    if ([[FBSession activeSession] isOpen]) {
        return YES;
    }
    return NO;
}

#pragma mark User attends event
-(void)postUserAttendsEvent:(id)sender{
    VLog(@"Attending button pressed");
    if([sender isEnabled]){
        NSString *query = [NSString stringWithFormat:@"%@/attending/me", self.eventID];

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
                     [sender setHidden:YES];
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
            }
        }];
        [conn start];
        [sender setEnabled:NO];
    }
}

@end

@implementation FacebookEventFriends

-(FacebookEventFriends*)initWithName:(NSString*)name andUserID:(NSString*)uid
{
    if(self = [super init]){
        self.name = name;
        self.uid = uid;
    }
    return self;
}
@end