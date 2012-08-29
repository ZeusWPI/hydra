//
//  AssociationStore.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationStore.h"
#import "Association.h"
#import "AssociationActivity.h"
#import "AssociationNewsItem.h"

#define kVersoUrl @"http://golive.myverso.com/ugent"
#define kVersoResourceStatePath @"/versions.xml"

NSString *const AssociationStoreDidUpdateNewsNotification =
    @"AssociationStoreDidUpdateNewsNotification";
NSString *const AssociationStoreDidUpdateActivitiesNotification =
    @"AssociationStoreDidUpdateActivitiesNotification";
NSString *const AssociationsLastUpdated = @"AssociationsLastUpdated";

@interface AssociationStore ()

@property (nonatomic, strong) NSArray *associations;
@property (nonatomic, strong) NSMutableDictionary *newsItems;
@property (nonatomic, strong) NSDictionary *activities;

@property (nonatomic, strong) NSDictionary *resourceState;
@property (nonatomic, assign) NSUInteger activitiesVersion;

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableDictionary *activeRequests;

@end

@implementation AssociationStore

+ (AssociationStore *)sharedStore
{
    static AssociationStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        //sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self assocationCachePath]];
        if (!sharedInstance) sharedInstance = [[AssociationStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.associations = [Association updateAssociations:nil lastModified:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // TODO: use last modified date as provided by associations
        // perhaps move this whole updating construct to Association?
        [userDefaults setObject:[NSDate date] forKey:AssociationsLastUpdated];

        self.newsItems = [[NSMutableDictionary alloc] init];
        self.activeRequests = [[NSMutableDictionary alloc] init];
        [self initializeObjectManager];
    }
    return self;
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    // TODO
    [self initializeObjectManager];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // TODO
}

+ (NSString *)storeCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
    NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheDirectories objectAtIndex:0];

    return [cacheDirectory stringByAppendingPathComponent:@"associations.archive"];
}

- (void)updateStoreCache
{
    NSString *cachePath = [[self class] storeCachePath];
    [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
}

#pragma mark - Remote data management and requests

- (void)fetchResourceStateWithCompletion:(void(^)(NSDictionary *))block
{
    NSURL *url = [NSURL URLWithString:kVersoResourceStatePath];
    if ([self.activeRequests objectForKey:url]) return;

    RKClient *client = [self.objectManager client];
    RKRequest *stateRequest = [client requestWithResourcePath:kVersoResourceStatePath];

    __block AssociationStore *blockSelf = self;
    [stateRequest setOnDidLoadResponse:^(RKResponse *response) {
        NSError *error;
        NSDictionary *result = [response parsedBody:&error];

        if (!error) {
            // the sweet stuff is 2 levels down: paths > path > *
            NSDictionary *root = [[result allValues] objectAtIndex:0];
            NSMutableDictionary *state = [[NSMutableDictionary alloc] init];
            for (NSDictionary *entry in [[root allValues] objectAtIndex:0]) {
                [state setValue:entry forKey:[entry valueForKey:@"name"]];
            }
            blockSelf.resourceState = state;
            block(state);
        }
        else {
            [blockSelf objectLoader:nil didFailWithError:error];
        }
        [self.activeRequests removeObjectForKey:url];
    }];
    [stateRequest setOnDidFailLoadWithError:^(NSError *error) {
        [blockSelf objectLoader:nil didFailWithError:error];
        [self.activeRequests removeObjectForKey:url];
    }];

    [[self.objectManager requestQueue] addRequest:stateRequest];
    [self.activeRequests setObject:[NSNull null] forKey:url];
}

- (void)fetchResourceUpdate:(NSString *)resourceId forTarget:(id)target withVersion:(NSUInteger)version
{
    // Load the versions.xml, to check if we need updates
    if (!self.resourceState) {
        [self fetchResourceStateWithCompletion:^(NSDictionary *state) {
            [self fetchResourceUpdate:resourceId forTarget:target withVersion:version];
        }];
    }
    else {
        // Check the information in versions.xml
        NSDictionary *state = [self.resourceState valueForKey:resourceId];
        NSUInteger latestVersion = [[state valueForKey:@"version"] intValue];

        if (latestVersion > version) {
            // Only allow one request at a time
            NSString *path = [@"/" stringByAppendingString:[state valueForKey:@"path"]];
            if (![self.activeRequests objectForKey:path]) {
                NSLog(@"Resource \"%@\" is out-of-date. Updating...", resourceId);
                [self.objectManager loadObjectsAtResourcePath:path delegate:self];
                [self.activeRequests setObject:target forKey:path];
            }
        }
    }
}

static NSString *const ActivitiesResource = @"all_activities";

- (NSArray *)activitiesForAssocation:(Association *)association
{
    [self fetchResourceUpdate:ActivitiesResource forTarget:[NSNull null]
                  withVersion:self.activitiesVersion];

    return [self.activities allValues];
}

- (NSArray *)newsItemsForAssocation:(Association *)association
{
    NSDictionary *associationState = [self.newsItems objectForKey:association];
    [self fetchResourceUpdate:[association internalName] forTarget:association
                  withVersion:[[associationState objectForKey:@"version"] intValue]];

    return [[self.newsItems objectForKey:association] objectForKey:@"items"];
}

#pragma mark - RestKit Object loading

- (void)initializeObjectManager
{
    self.objectManager = [RKObjectManager managerWithBaseURLString:kVersoUrl];
    [AssociationActivity registerObjectMappingWith:[self.objectManager mappingProvider]];
    [AssociationNewsItem registerObjectMappingWith:[self.objectManager mappingProvider]];
    [[self.objectManager client] setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [[self.objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
}

- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData
{
    // The data retrieved for associations has the association-name as root tag
    // which is a crazy bad idea. So we just skip it and work on the data underneath.
    NSDictionary *original = *mappableData;
    NSString *rootKey = [[original allKeys] objectAtIndex:0];
    if (![rootKey isEqual:@"activities"]) *mappableData = [original allValues];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    // Show an alert if something goes wrong
    // TODO: make errors thrown by RestKit more userfriendly
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    if (objectLoader) [self.activeRequests removeObjectForKey:[objectLoader resourcePath]];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSString *notification = nil;
    NSDictionary *userInfo = nil;
    id targetObject = [self.activeRequests objectForKey:[objectLoader resourcePath]];

    // Received some NewsItems
    if ([targetObject isKindOfClass:[Association class]]) {
        Association *assoc = targetObject;
        NSDictionary *state = [self.resourceState valueForKey:[assoc internalName]];

        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [state valueForKey:@"version"], @"version",
                                objects, @"contents", nil];
        [self.newsItems setObject:result forKey:assoc];
        notification = AssociationStoreDidUpdateNewsNotification;
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    assoc, @"association", objects, @"newsItems", nil];
    }
    // Received Activities
    else {
        // Index received activities by association
        NSMutableDictionary *newActivities = [[NSMutableDictionary alloc] init];
        for (AssociationActivity *activity in objects) {
            NSString *associationId = [activity associationId];
            if (![newActivities objectForKey:associationId]) {
                [newActivities setObject:[[NSMutableArray alloc] init]
                                  forKey:associationId];
            }
            [[newActivities objectForKey:associationId] addObject:activity];
        }
        self.activities = newActivities;

        NSDictionary *state = [self.resourceState valueForKey:ActivitiesResource];
        self.activitiesVersion = [[state valueForKey:@"version"] intValue];
        notification = AssociationStoreDidUpdateActivitiesNotification;
    }

    // Send notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notification object:self userInfo:userInfo];

    [self.activeRequests removeObjectForKey:[objectLoader resourcePath]];
}

@end
