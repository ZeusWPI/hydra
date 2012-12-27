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
#import "AppDelegate.h"
#import <RestKit/RestKit.h>

#define kVersoUrl @"http://golive.myverso.com/ugent"
#define kVersoResourceStatePath @"/versions.xml"
#define kActivitiesResource @"ALL_ACTIVITIES"

NSString *const AssociationStoreDidUpdateNewsNotification =
    @"AssociationStoreDidUpdateNewsNotification";
NSString *const AssociationStoreDidUpdateActivitiesNotification =
    @"AssociationStoreDidUpdateActivitiesNotification";


@interface AssociationStore () <NSCoding, RKObjectLoaderDelegate, RKRequestDelegate>

@property (nonatomic, strong) NSDictionary *associations;
@property (nonatomic, strong) NSMutableDictionary *newsItems;
@property (nonatomic, strong) NSArray *activities;

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
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storeCachePath];
        if (!sharedInstance) sharedInstance = [[AssociationStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.associations = [Association updateAssociations:nil];
        self.newsItems = [[NSMutableDictionary alloc] init];
        self.activities = nil;
        self.activitiesVersion = 0;
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.activeRequests = [[NSMutableDictionary alloc] init];
    [self initializeObjectManager];
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        NSArray *associations = [decoder decodeObjectForKey:@"associations"];
        self.associations = [Association updateAssociations:associations];

        self.newsItems = [decoder decodeObjectForKey:@"newsItems"];
        if (![self.newsItems isKindOfClass:[NSDictionary class]]) {
            self.newsItems = [[NSMutableDictionary alloc] init];
        }

        self.activities = [decoder decodeObjectForKey:@"activities"];
        self.activitiesVersion = [decoder decodeIntegerForKey:@"activitiesVersion"];
        if (![self.activities isKindOfClass:[NSArray class]]) {
            self.activities = nil;
            self.activitiesVersion = 0;
        }

        [self sharedInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.associations forKey:@"associations"];
    [coder encodeObject:self.newsItems forKey:@"newsItems"];
    [coder encodeObject:self.activities forKey:@"activities"];
    [coder encodeInteger:self.activitiesVersion forKey:@"activitiesVersion"];
}

+ (NSString *)storeCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
    NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cacheDirectories[0];

    return [cacheDirectory stringByAppendingPathComponent:@"association.archive"];
}

- (void)updateStoreCache
{
    // TODO: prune old items
    [NSKeyedArchiver archiveRootObject:self toFile:self.class.storeCachePath];
}

#pragma mark - Remote data management and requests

- (void)fetchResourceStateWithCompletion:(void(^)(NSDictionary *))block
{
    NSURL *url = [NSURL URLWithString:kVersoResourceStatePath];
    if (self.activeRequests[url]) {
        NSMutableArray *dependingRequests = self.activeRequests[url];
        [dependingRequests addObject:block];
        return;
    }

    DLog(@"Checking if resources were updated");

    RKClient *client = [self.objectManager client];
    RKRequest *stateRequest = [client requestWithResourcePath:kVersoResourceStatePath];

    [stateRequest setOnDidLoadResponse:^(RKResponse *response) {
        NSError *error;
        NSDictionary *result = [response parsedBody:&error];

        if (!error) {
            // the sweet stuff is 2 levels down: paths > path > *
            NSDictionary *root = [result allValues][0];
            NSMutableDictionary *state = [[NSMutableDictionary alloc] init];
            for (NSDictionary *entry in [root allValues][0]) {
                state[entry[@"name"]] = entry;
            }
            self.resourceState = state;

            for (void (^b)(NSDictionary *state) in self.activeRequests[url]) {
                b(state);
            }
        }
        else {
            [self objectLoader:nil didFailWithError:error];
        }
        [self.activeRequests removeObjectForKey:url];
    }];
    [stateRequest setOnDidFailLoadWithError:^(NSError *error) {
        [self objectLoader:nil didFailWithError:error];
        [self.activeRequests removeObjectForKey:url];
    }];

    NSMutableArray *dependingRequests = [NSMutableArray arrayWithObject:block];
    self.activeRequests[url] = dependingRequests;
    [[self.objectManager requestQueue] addRequest:stateRequest];
}

- (void)fetchResourceUpdate:(NSString *)resourceId forTarget:(id)target withVersion:(NSUInteger)version
{
    // Load the versions.xml, to check if we need updates
    // TODO: expire the resource state after a while?
    if (!self.resourceState) {
        [self fetchResourceStateWithCompletion:^(NSDictionary *state) {
            [self fetchResourceUpdate:resourceId forTarget:target withVersion:version];
        }];
    }
    else {
        // Check the information in versions.xml
        NSDictionary *state = self.resourceState[resourceId];
        if (!state) {
            NSLog(@"Resource \"%@\" not found in resource state.", resourceId);
            return;
        }

        NSUInteger latestVersion = [state[@"version"] intValue];
        if (latestVersion > version) {
            // Only allow one request at a time
            NSString *path = [@"/" stringByAppendingString:state[@"path"]];
            if (!(self.activeRequests)[path]) {
                NSLog(@"Resource \"%@\" (version %u) is out-of-date. Updating...", resourceId, version);
                self.activeRequests[path] = target;
                [self.objectManager loadObjectsAtResourcePath:path delegate:self];
            }
        }
        else {
            NSLog(@"Resource \"%@\" (version %u) is up-to-date.", resourceId, version);
        }
    }
}

#pragma mark - Accessors

- (NSArray *)allAssociations
{
    return [self.associations allValues];
}

- (Association *)associationWithName:(NSString *)internalName
{
    Association *association = self.associations[internalName];

    // If the association is unknown, just give a fake record
    if (!association) {
        association = [[Association alloc] init];
        association.internalName = internalName;
        association.displayName = internalName;
    }

    return association;
}

- (NSArray *)allActivities
{
    [self fetchResourceUpdate:kActivitiesResource forTarget:[NSNull null]
                  withVersion:self.activitiesVersion];
    return self.activities;
}

- (NSArray *)newsItemsForAssocation:(Association *)association
{
    NSDictionary *associationState = self.newsItems[association];
    [self fetchResourceUpdate:association.internalName forTarget:association
                  withVersion:[associationState[@"version"] intValue]];
    return self.newsItems[association][@"contents"];
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
    NSString *rootKey = [original allKeys][0];
    *mappableData = original[rootKey];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app handleError:error];

    // Only clear the request after 10 seconds, to prevent failed requests
    // restarting due to related succesful requests
    if (objectLoader) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self.activeRequests removeObjectForKey:objectLoader.resourcePath];
        });
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSString *notification = nil;
    NSDictionary *userInfo = nil;
    NSLog(@"Retrieved resource \"%@\"", objectLoader.resourcePath);

    // Received some NewsItems
    id targetObject = self.activeRequests[objectLoader.resourcePath];
    if ([targetObject isKindOfClass:[Association class]]) {
        Association *assoc = targetObject;
        self.newsItems[assoc] = @{
            @"version": self.resourceState[assoc.internalName][@"version"],
            @"contents": objects
        };
        notification = AssociationStoreDidUpdateNewsNotification;
        userInfo = @{ @"association" : assoc, @"newsItems": objects };
    }
    // Received Activities
    else {
        self.activities = objects;

        NSDictionary *state = self.resourceState[kActivitiesResource];
        self.activitiesVersion = [state[@"version"] intValue];
        notification = AssociationStoreDidUpdateActivitiesNotification;
    }

    // Send notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notification object:self userInfo:userInfo];

    [self.activeRequests removeObjectForKey:objectLoader.resourcePath];
    [self updateStoreCache];
}

@end
