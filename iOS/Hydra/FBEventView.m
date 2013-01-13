//
//  FBEventView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FBEventView.h"

#define kSquareSize 30

@implementation FBEventView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureWithEventID:(NSString*)eventID
{

    self.eventID = eventID;
    FBRequestConnection *conn = [[FBRequestConnection alloc] init];
    
    // get information

    // query to get public info from event, number of people attending and picture
    NSString *subq1 = [NSString stringWithFormat:@"SELECT attending_count, pic_big FROM event WHERE eid='%@'",eventID];

    // query to get friends info from event, which friends are attending
    NSString *subq2 = [NSString stringWithFormat:@"SELECT uid, name FROM user where uid IN (SELECT uid2 from friend WHERE uid2 IN (SELECT uid FROM event_member WHERE eid = '%@' and rsvp_status = 'attending') AND uid1 = me())", eventID];

    NSString *subq3 = [NSString stringWithFormat:@"SELECT uid, rsvp_status FROM event_member WHERE eid = '%@' AND uid = me() ", eventID];

    //NSString *query = [NSString stringWithFormat:@"{'info_event':'%@', 'friends_event':'%@'}",subq1, subq2];

    VLog(subq1);
    // Set up the query parameter
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys: subq1, @"q", nil];
    FBRequest *reqEventInfo = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    [conn addRequest:reqEventInfo completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  NSArray *arr = (NSArray*)[result objectForKey:@"data"];
                                  _attendees = (NSString*)[arr[0] objectForKey:@"attending_count"];
                                  self.imageURL = (NSString*)[arr[0] objectForKey:@"pic_big"];
                                  [self createEventView];
                              }
                          }];
    VLog(subq2);
    // Set up the query parameter
    queryParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                subq2, @"q", nil];
    FBRequest *reqEventFriends = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];

    [conn addRequest:reqEventFriends completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              [self facebookRequestHandlerConnection:connection result:result error:error];
                          }];
    

    VLog(subq3);
    // Set up the query parameter
    queryParam = [NSDictionary dictionaryWithObjectsAndKeys:subq3, @"q", nil];
    FBRequest *reqEventUser = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];

    [conn addRequest:reqEventUser completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  NSArray *arr = (NSArray*)[result objectForKey:@"data"];
                                  BOOL attending = [arr count] == 1 ? YES : NO;
                                  if (attending){
                                      NSString *str = [arr[0] objectForKey:@"rsvp_status"];
                                      if ([str rangeOfString:@"attending"].location == NSNotFound){
                                          attending = NO;
                                      }
                                  }
                                  [self userAttending:attending];
                              }
                          }];
    [conn start];
}

-(void)userAttending:(BOOL)attending
{
    UIButton *attendingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [attendingButton setFrame:CGRectMake(10, 150, 80, 40)];

    [attendingButton setTitle:@"Gaan?" forState:UIControlStateNormal];
    [attendingButton setTitle:@"Aanwezig" forState:UIControlStateDisabled];
    [attendingButton setEnabled:!attending];
    [attendingButton addTarget:self action:@selector(postUserAttendsEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:attendingButton];
    
}

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
                     // If permissions granted, publish the story
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

-(void)facebookRequestHandlerConnection:(FBRequestConnection*)conn result:(id) result error:(NSError*)error
{
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    } else {
        //NSLog(@"Result: %@", result);
        NSArray *arr = (NSArray*)[result objectForKey:@"data"];
        if ([arr count]){
            self.data = arr;
            [self createFriendsView];
        }
    }

}
- (void)createEventView
{
    self.backgroundColor = [UIColor hydraBackgroundColor];
    UIImage *eventPic = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:
                                                       [NSURL URLWithString:_imageURL]]];
    UIImageView *picView = [[UIImageView alloc] initWithImage:eventPic];
    picView.frame = CGRectMake(0, 0, 100, eventPic.size.height/eventPic.size.width*100);
    [picView sizeThatFits:picView.frame.size];
    [self addSubview:picView];

    UILabel *eventVisitors = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, self.bounds.size.width-100, 20)];
    eventVisitors.text = [NSString stringWithFormat:@"Er zijn %@ komende",_attendees];
    eventVisitors.textColor = [UIColor whiteColor];
    eventVisitors.backgroundColor = [UIColor clearColor];
    eventVisitors.font = [UIFont systemFontOfSize:13];
    [self addSubview:eventVisitors];
}

- (void)createFriendsView
{
    NSInteger i, j, maxI, maxJ;
    // below eventVistors create label that says how many friends come
    UILabel *eventFriends = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, self.bounds.size.width-110, 20)];
    eventFriends.text = [NSString stringWithFormat:@"Er komen %d vrienden",[self.data count]];
    eventFriends.textColor = [UIColor whiteColor];
    eventFriends.backgroundColor = [UIColor clearColor];
    eventFriends.font = [UIFont systemFontOfSize:13];
    [self addSubview:eventFriends];

    // create grid from profile pictures 20*20
    maxI = (self.bounds.size.width-110)/kSquareSize;
    maxJ = [_data count]/maxI+1;
    maxJ = ((self.bounds.size.height-50)/kSquareSize)>=maxJ?maxJ:((self.bounds.size.height-50)/kSquareSize);
    UIView *gridView = [[UIView alloc] initWithFrame:CGRectMake(110, 50, self.bounds.size.width-110, maxJ*kSquareSize)];
    gridView.backgroundColor = [UIColor clearColor];
    for (i=0; i < maxI  ; i++) {
        for (j=0; j < maxJ; j++){
            if([_data count] > maxJ*i+j){
                FBProfilePictureView *profilePic= [[FBProfilePictureView alloc] initWithFrame:CGRectMake(i*kSquareSize, j*kSquareSize, kSquareSize, kSquareSize)];
                FBGraphObject *obj = self.data[maxJ*i+j];
                NSLog(@"Index: %d, van %@",maxJ*i+j, (NSString*)[obj objectForKey:@"uid"]);
                [profilePic setProfileID:(NSString*)[obj objectForKey:@"uid"]];
                [gridView addSubview:profilePic];
            }
        }
    }
    [self addSubview:gridView];
}
@end
