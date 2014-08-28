//
//  PreferencesService.m
//  Hydra
//
//  Created by Pieter De Baets on 18/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesService.h"

#define kFilterAssociationsKey @"useAssociationFilter"
#define kPreferredAssociationsKey @"preferredAssociations"
#define kShownFacebookPrompt @"shownFacebookPrompt"


@interface PreferencesService ()

@property (nonatomic, strong) NSUserDefaults *settings;

@end

@implementation PreferencesService

+ (PreferencesService *)sharedService
{
    static PreferencesService *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[PreferencesService alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.settings = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)filterAssociations
{
    return [self.settings boolForKey:kFilterAssociationsKey];
}

- (void)setFilterAssociations:(BOOL)filterAssociations
{
    [self willChangeValueForKey:@"filterAssociations"];
    [self.settings setBool:filterAssociations forKey:kFilterAssociationsKey];
    [self didChangeValueForKey:@"filterAssociations"];
}

- (BOOL)shownFacebookPrompt
{
    return [self.settings boolForKey:kShownFacebookPrompt];
}

- (void)setShownFacebookPrompt:(BOOL)shownFacebookPrompt
{
    [self willChangeValueForKey:@"shownFacebookPrompt"];
    [self.settings setBool:shownFacebookPrompt forKey:kShownFacebookPrompt];
    [self didChangeValueForKey:@"shownFacebookPrompt"];
}

- (NSArray *)preferredAssociations
{
    NSArray *list = [self.settings objectForKey:kPreferredAssociationsKey];
    AssertClassOrNil(list, NSArray);
    if (list == nil) {
        list = [[NSArray alloc] init];
    }
    return list;
}

- (void)setPreferredAssociations:(NSArray *)preferredAssociations
{
    [self willChangeValueForKey:@"preferredAssociations"];
    [self.settings setObject:preferredAssociations forKey:kPreferredAssociationsKey];
    [self didChangeValueForKey:@"preferredAssociations"];
}

@end
