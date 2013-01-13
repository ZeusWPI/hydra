//
//  FBEventView.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBEventView : UIView

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *attendees;
@property (strong, nonatomic) NSString *eventID;

- (void)configureWithEventID:(NSString*)eventID;

@end
