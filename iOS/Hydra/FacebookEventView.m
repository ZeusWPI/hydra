//
//  FacebookEventView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FacebookEventView.h"

#define kSquareSize 30

@interface FacebookEventView ()

@property (strong, nonatomic) UIButton *attendingButton;
@property (strong, nonatomic) UIImageView *picView;
@property (strong, nonatomic) UILabel *eventVisitors;
@property (strong, nonatomic) UILabel *eventFriends;
@property (strong, nonatomic) UIView *gridView;

@end

@implementation FacebookEventView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureWithEvent:(FacebookEvent*)event
{
    if (event != nil){
        self.event = event;
        VLog(self.event);
        if (self.event.attendees != nil || self.event.imageURL != nil)
            [self createEventView];
        
        [self userAttending];
        if (self.event.friendsAttending != nil)
            [self createFriendsView];
    }

    self.backgroundColor = [UIColor blackColor];
   }

-(void)userAttending
{
    UIButton *attendingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [attendingButton setFrame:CGRectMake(10, 150, 80, 40)];

    [attendingButton setTitle:@"Gaan?" forState:UIControlStateNormal];
    [attendingButton setTitle:@"Aanwezig" forState:UIControlStateDisabled];
    [attendingButton setEnabled:!self.event.userAttending];
    [attendingButton addTarget:_event action:@selector(postUserAttendsEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:attendingButton];
    self.attendingButton = attendingButton;
    
}

-(void)reloadData
{
    if (self.event != nil){
        VLog(self.event);
        [self createEventView];
        [self userAttending];
        [self createFriendsView];
    }
}
- (void)createEventView
{
    self.backgroundColor = [UIColor hydraBackgroundColor];
    UIImage *eventPic = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:
                                                       [NSURL URLWithString:self.event.imageURL]]];
    UIImageView *picView = [[UIImageView alloc] initWithImage:eventPic];
    picView.frame = CGRectMake(0, 0, 100, eventPic.size.height/eventPic.size.width*100);
    [picView sizeThatFits:picView.frame.size];
    [self addSubview:picView];
    self.picView = picView;

    UILabel *eventVisitors = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, self.bounds.size.width-100, 20)];
    eventVisitors.text = [NSString stringWithFormat:@"Er zijn %@ komende",self.event.attendees];
    eventVisitors.textColor = [UIColor whiteColor];
    eventVisitors.backgroundColor = [UIColor clearColor];
    eventVisitors.font = [UIFont systemFontOfSize:13];
    [self addSubview:eventVisitors];
    self.eventVisitors = eventVisitors;
}

- (void)createFriendsView
{
    NSInteger i, j, maxI, maxJ;
    // below eventVistors create label that says how many friends come
    UILabel *eventFriends = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, self.bounds.size.width-110, 20)];
    eventFriends.text = [NSString stringWithFormat:@"Er komen %d vrienden",[self.event.friendsAttending count]];
    eventFriends.textColor = [UIColor whiteColor];
    eventFriends.backgroundColor = [UIColor clearColor];
    eventFriends.font = [UIFont systemFontOfSize:13];
    [self addSubview:eventFriends];
    self.eventFriends = eventFriends;

    // create grid from profile pictures 20*20
    maxI = (self.bounds.size.width-110)/kSquareSize;
    maxJ = [self.event.friendsAttending count]/maxI+1;
    maxJ = ((self.bounds.size.height-50)/kSquareSize)>=maxJ?maxJ:((self.bounds.size.height-50)/kSquareSize);
    UIView *gridView = [[UIView alloc] initWithFrame:CGRectMake(110, 50, self.bounds.size.width-110, maxJ*kSquareSize)];
    gridView.backgroundColor = [UIColor clearColor];
    for (i=0; i < maxI  ; i++) {
        for (j=0; j < maxJ; j++){
            if([self.event.friendsAttending count] > maxJ*i+j){
                FBProfilePictureView *profilePic= [[FBProfilePictureView alloc] initWithFrame:CGRectMake(i*kSquareSize, j*kSquareSize, kSquareSize, kSquareSize)];
                FacebookEventFriends *friend = self.event.friendsAttending[maxJ*i+j];
                //NSLog(@"Index: %d, van %@",maxJ*i+j, friend.uid);
                [profilePic setProfileID:friend.uid];
                [gridView addSubview:profilePic];
            }
        }
    }
    [self addSubview:gridView];
    self.gridView = gridView;
}
@end
