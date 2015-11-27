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
#import "FacebookEvent.h"
#import <RestKit/RestKit.h>

#define kBaseUrl @"http://student.ugent.be/hydra/api/1.0/"
#define kActivitiesResource @"all_activities.json"
#define kNewsResource @"all_news.json"
#define kAssociationResource @"associations.json"
#define kUpdateInterval (15 * 60)

NSString *const AssociationStoreDidUpdateNewsNotification =
@"AssociationStoreDidUpdateNewsNotification";
NSString *const AssociationStoreDidUpdateActivitiesNotification =
@"AssociationStoreDidUpdateActivitiesNotification";

@interface AssociationStore () <NSCoding>

@property (nonatomic, strong) NSDictionary *associationLookup;
@property (nonatomic, strong) NSArray *associations;
@property (nonatomic, strong) NSArray *newsItems;
@property (nonatomic, strong) NSArray *activities;

@property (nonatomic, strong) NSDate *newsLastUpdated;
@property (nonatomic, strong) NSDate *activitiesLastUpdated;
@property (nonatomic, strong) NSDate *associationsLastUpdated;

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray *activeRequests;

@property (nonatomic, assign) BOOL storageOutdated;

@end

@implementation AssociationStore

+ (AssociationStore *)sharedStore
{
    static AssociationStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        @try {
            sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storeCachePath];
        }
        @catch (NSException *exception) {
            NSLog(@"Got exception while reading Associations archive: %@", exception);
        }
        @finally {
            if (!sharedInstance) sharedInstance = [[AssociationStore alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.activeRequests = [[NSMutableArray alloc] init];
    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    // Listen for facebook-updates to activities
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(facebookEventUpdated:)
                   name:FacebookEventDidUpdateNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _associations = [decoder decodeObjectForKey:@"associations"];
        AssertClassOrNil(_associations, NSArray);
        _associationsLastUpdated = [decoder decodeObjectForKey:@"associationsLastUpdated"];
        AssertClassOrNil(_associationsLastUpdated, NSDate);
        
        _newsItems = [decoder decodeObjectForKey:@"newsItems"];
        AssertClassOrNil(_newsItems, NSArray);
        _newsLastUpdated = [decoder decodeObjectForKey:@"newsLastUpdated"];
        AssertClassOrNil(_newsLastUpdated, NSDate);
        
        _activities = [decoder decodeObjectForKey:@"activities"];
        AssertClassOrNil(_activities, NSArray);
        _activitiesLastUpdated = [decoder decodeObjectForKey:@"activitiesLastUpdated"];
        AssertClassOrNil(_activitiesLastUpdated, NSDate);
        
        [self sharedInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_associationsLastUpdated forKey:@"associationsLastUpdated"];
    [coder encodeObject:_associations forKey:@"associations"];
    [coder encodeObject:_newsLastUpdated forKey:@"newsLastUpdated"];
    [coder encodeObject:_newsItems forKey:@"newsItems"];
    [coder encodeObject:_activitiesLastUpdated forKey:@"activitiesLastUpdated"];
    [coder encodeObject:_activities forKey:@"activities"];
}

+ (NSString *)storeCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
    NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cacheDirectories[0];
    
    return [cacheDirectory stringByAppendingPathComponent:@"association.archive"];
}

- (void)syncStorage
{
    if (!self.storageOutdated) {
        return;
    }
    
    // Immediately mark the cache as being updated, as this is an async operation
    self.storageOutdated = NO;
    
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(async, ^{
        [NSKeyedArchiver archiveRootObject:self toFile:self.class.storeCachePath];
    });
}

- (void)markStorageOutdated
{
    self.storageOutdated = YES;
}

#pragma mark - Accessors

- (Association *)associationWithName:(NSString *)internalName
{
    if (self.associationLookup == nil) {
        [self createAssociationsLookup];
    }
    Association *association = self.associationLookup[internalName];
    
    // If the association is unknown, just give a fake record
    if (!association) {
        association = [[Association alloc] init];
        association.internalName = internalName;
        association.displayName = internalName;
    }
    
    return association;
}

- (NSArray *)associations
{
    [self _updateResource:kAssociationResource lastUpdated:self.associationsLastUpdated
            objectMapping:[Association objectMapping]];
    return _associations;
}

- (NSArray *)activities
{
    [self _updateResource:kActivitiesResource lastUpdated:self.activitiesLastUpdated
            objectMapping:[AssociationActivity objectMapping]];
    return _activities;
}

- (NSArray *)newsItems
{
    [self _updateResource:kNewsResource lastUpdated:self.newsLastUpdated
            objectMapping:[AssociationNewsItem objectMapping]];
    return _newsItems;
}

- (void)reloadActivities
{
    // Force reload, remove cache-entry
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self _updateResource:kActivitiesResource lastUpdated:nil
            objectMapping:[AssociationActivity objectMapping]];
    [self reloadAssociations];
}

- (void)reloadNewsItems
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self _updateResource:kNewsResource lastUpdated:nil
            objectMapping:[AssociationNewsItem objectMapping]];
    [self reloadAssociations];
}

- (void)reloadAssociations
{
    [self _updateResource:kAssociationResource lastUpdated:nil
            objectMapping:[Association objectMapping]];
}

#pragma mark - RestKit Object loading

- (void)_updateResource:(NSString *)resource lastUpdated:(NSDate *)lastUpdated objectMapping:(RKObjectMapping *)mapping
{
    DLog(@"updateResource %@ (last: %@ => %f)", resource, lastUpdated, [lastUpdated timeIntervalSinceNow]);
    
    // Check if an update is required
    if (lastUpdated && [lastUpdated timeIntervalSinceNow] > -kUpdateInterval) {
        return;
    }
    
    // Already working on request
    if ([self.activeRequests containsObject:resource]) {
        return;
    }
    
    DLog(@"Updating %@", resource);
    [self.activeRequests addObject:resource];
    [self.objectManager addResponseDescriptor:
     [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                  method:RKRequestMethodGET
                                             pathPattern:resource
                                                 keyPath:nil
                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [self.objectManager getObjectsAtPath:resource
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     [self _processResult:mappingResult forResource:resource];
                                 }
                                 failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     [self _processError:error forResource:resource];
                                 }];
}

- (void)_processResult:(RKMappingResult *)mappingResult forResource:(NSString *)resource
{
    NSString *notification = nil;
    NSArray *objects = [mappingResult array];
    
    // Received some NewsItems
    if ([resource isEqualToString:kNewsResource]) {
        NSMutableSet *readItems = [NSMutableSet set];
        // Using direct access because accessors reload the data
        for (AssociationNewsItem *item in _newsItems) {
            if (item.read) {
                [readItems addObject:@(item.itemId)];
            }
        }
        for (AssociationNewsItem *item in objects) {
            if ([readItems containsObject:@(item.itemId)]) {
                item.read = YES;
            }
        }
        self.newsItems = objects;
        self.newsLastUpdated = [NSDate date];
        notification = AssociationStoreDidUpdateNewsNotification;
    }
    // Received Activities
    else if ([resource isEqualToString:kActivitiesResource]) {
        NSMutableDictionary *availableEvents = [NSMutableDictionary dictionary];
        // Using direct access because accessors reload the data
        for (AssociationActivity *activity in _activities) {
            if ([activity hasFacebookEvent]) {
                availableEvents[activity.facebookId] = activity;
            }
        }
        for (AssociationActivity *activity in objects) {
            if ([availableEvents objectForKey:activity.facebookId]) {
                AssociationActivity *oldActivity = availableEvents[activity.facebookId];
                activity.facebookEvent = oldActivity.facebookEvent;
            }
        }
        self.activities = objects;
        self.activitiesLastUpdated = [NSDate date];
        notification = AssociationStoreDidUpdateActivitiesNotification;
    }
    else if ([resource isEqualToString:kAssociationResource]) {
        self.associations = objects;
        [self createAssociationsLookup];
    }
    
    [self markStorageOutdated];
    [self syncStorage];
    
    // Send notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notification object:self userInfo:nil];
    
    [self.activeRequests removeObject:resource];
}

- (void)_processError:(NSError *)error forResource:(NSString *)resource
{
    NSLog(@"Updating resource %@ failed: %@", resource, error);
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app handleError:error];
    
    NSString *notification = nil;
    if ([resource isEqualToString:kNewsResource]) {
        notification = AssociationStoreDidUpdateNewsNotification;
    }
    else if ([resource isEqualToString:kActivitiesResource]) {
        notification = AssociationStoreDidUpdateActivitiesNotification;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notification object:self userInfo:nil];
    
    // Only clear the request after 10 seconds, to prevent failed requests
    // restarting due to related succesful requests
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.activeRequests removeObject:resource];
    });
}

#pragma mark - Utility functions
- (void)createAssociationsLookup
{
    NSMutableDictionary *associationsLookup = [NSMutableDictionary dictionary];
    for (Association *association in self.associations) {
        associationsLookup[association.internalName] = association;
    }
    
    self.associationLookup = associationsLookup;
}

#pragma mark - Notifications

- (void)facebookEventUpdated:(NSNotification *)notification
{
    [self markStorageOutdated];
    
    // Call method in 10 seconds so multiple changes are written at once
    [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(syncStorage)
                                                   object:nil];
    [self performSelector:@selector(syncStorage) withObject:nil afterDelay:10];
}

@end