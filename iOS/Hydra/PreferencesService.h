//
//  PreferencesService.h
//  Hydra
//
//  Created by Pieter De Baets on 18/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesService : NSObject

+ (PreferencesService *)sharedService;

@property (nonatomic, assign) BOOL filterAssociations;
@property (nonatomic, assign) BOOL showActivitiesInFeed;
@property (nonatomic, strong) NSArray *preferredAssociations;
@property (nonatomic, strong) NSArray *hydraTabBarOrder;
@property (nonatomic, assign) BOOL shownFacebookPrompt;

@end
