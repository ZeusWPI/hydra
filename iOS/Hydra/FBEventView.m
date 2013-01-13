//
//  FBEventView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FBEventView.h"

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
    // get information

    // query to get public info from event, number of people attending and picture
    NSString *subq1 = [NSString stringWithFormat:@"SELECT attending_count, pic_big FROM event WHERE eid='%@'",eventID];

    // query to get friends info from event, which friends are attending
    NSString *subq2 = [NSString stringWithFormat:@"SELECT uid, name FROM user where uid IN (SELECT uid2 from friend WHERE uid2 IN (SELECT uid FROM event_member WHERE eid = '%@' and rsvp_status = 'attending') AND uid1 = me())", eventID];

    //NSString *query = [NSString stringWithFormat:@"{'info_event':'%@', 'friends_event':'%@'}",subq1, subq2];
    NSString *query = [NSString stringWithFormat:@"%@", subq1];

    VLog(query);
    // Set up the query parameter
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                query, @"q", nil];
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
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
    query = [NSString stringWithFormat:@"%@", subq2];

    VLog(query);
    // Set up the query parameter
    queryParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                query, @"q", nil];
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              [self facebookRequestHandlerConnection:connection result:result error:error];
                          }];
}

-(void)facebookRequestHandlerConnection:(FBRequestConnection*)conn result:(id) result error:(NSError*)error
{
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    } else {
        //NSLog(@"Result: %@", result);
        NSArray *arr = (NSArray*)[result objectForKey:@"data"];
        //NSLog(@"About arr, count: %d", [arr count]);
        /*for (FBGraphObject *obj in arr) {
            NSString *naam = (NSString*)[obj objectForKey:@"name"];
            NSString *uid = (NSString*)[obj objectForKey:@"uid"];
            NSLog(@"%@",naam);
        }//*/
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
    NSLog(@"Size: w %f en h %f , scale: %f", eventPic.size.width, eventPic.size.height, eventPic.scale);
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

#define kSquareSize 30
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
