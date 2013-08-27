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

#define kBaseUrl @"http://student.ugent.be/hydra/api/1.0"
#define kActivitiesResource @"/all_activities.json"
#define kNewsResource @"/all_news.json"
#define kUpdateInterval (15 * 60)

NSString *const AssociationStoreDidUpdateNewsNotification =
    @"AssociationStoreDidUpdateNewsNotification";
NSString *const AssociationStoreDidUpdateActivitiesNotification =
    @"AssociationStoreDidUpdateActivitiesNotification";

@interface AssociationStore () <NSCoding, RKObjectLoaderDelegate, RKRequestDelegate>

@property (nonatomic, strong) NSDictionary *associationLookup;
@property (nonatomic, strong) NSArray *newsItems;
@property (nonatomic, strong) NSArray *activities;

@property (nonatomic, strong) NSDate *newsLastUpdated;
@property (nonatomic, strong) NSDate *activitiesLastUpdated;

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray *activeRequests;

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
    self.associationLookup = [Association updateAssociations:self.associationLookup];

    self.activeRequests = [[NSMutableArray alloc] init];
    self.objectManager = [RKObjectManager managerWithBaseURLString:kBaseUrl];
    self.objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    self.objectManager.client.cachePolicy = RKRequestCachePolicyEnabled;

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
        _associationLookup = [decoder decodeObjectForKey:@"associationLookup"];
        AssertClassOrNil(_associationLookup, NSDictionary);

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
    [coder encodeObject:_associationLookup forKey:@"associationLookup"];
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

- (void)updateStoreCache
{
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        DLog(@"Updating store cache");
        [NSKeyedArchiver archiveRootObject:self toFile:self.class.storeCachePath];
    });
}

#pragma mark - Accessors

- (NSArray *)assocations
{
    return [self.associationLookup allValues];
}

- (Association *)associationWithName:(NSString *)internalName
{
    Association *association = self.associationLookup[internalName];

    // If the association is unknown, just give a fake record
    if (!association) {
        association = [[Association alloc] init];
        association.internalName = internalName;
        association.displayName = internalName;
    }

    return association;
}

- (NSArray *)activities
{
    [self updateResource:kActivitiesResource lastUpdated:self.activitiesLastUpdated
           objectMapping:[AssociationActivity objectMapping]];
    return _activities;
}

- (NSArray *)newsItems
{
    [self updateResource:kNewsResource lastUpdated:self.newsLastUpdated
           objectMapping:[AssociationNewsItem objectMapping]];
    return _newsItems;
}

- (void)reloadActivities
{
    [self.objectManager.client.requestCache invalidateAll];
    [self updateResource:kActivitiesResource lastUpdated:nil
           objectMapping:[AssociationActivity objectMapping]];
}

- (void)reloadNewsItems
{
    [self.objectManager.client.requestCache invalidateAll];
    [self updateResource:kNewsResource lastUpdated:nil
           objectMapping:[AssociationNewsItem objectMapping]];
}

#pragma mark - RestKit Object loading

- (void)updateResource:(NSString *)resource lastUpdated:(NSDate *)lastUpdated objectMapping:(RKObjectMapping *)mapping
{
    DLog(@"updateResource %@ (last: %@ => %f)", resource, lastUpdated, [lastUpdated timeIntervalSinceNow]);

    // Check if an update is required
    if (lastUpdated && [lastUpdated timeIntervalSinceNow] > -kUpdateInterval) {
        return;
    }

    if (![self.activeRequests containsObject:resource]) {
        DLog(@"Updating %@", resource);
        [self.activeRequests addObject:resource];
        [self.objectManager loadObjectsAtResourcePath:resource usingBlock:^(RKObjectLoader *loader) {
            RKObjectMappingProvider *mappingProvider = [RKObjectMappingProvider objectMappingProvider];
            [mappingProvider registerObjectMapping:mapping withRootKeyPath:@""];
            loader.mappingProvider = mappingProvider;
            loader.delegate = self;
        }];
    }
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
            [self.activeRequests removeObject:objectLoader.resourcePath];
        });
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSString *notification = nil;
    NSLog(@"Retrieved resource \"%@\"", objectLoader.resourcePath);

    VLog(objects);

    // Received some NewsItems
    if ([objectLoader.resourcePath isEqualToString:kNewsResource]) {
        NSInteger count = 0;
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:NO];
        objects = [objects sortedArrayUsingDescriptors:@[desc]];
        _newsItems = [_newsItems sortedArrayUsingDescriptors:@[desc]];
        for (AssociationNewsItem *newNewsItem in objects){
            for (NSInteger i = count; i < _newsItems.count; i++){
                AssociationNewsItem *newsItem = _newsItems[i];
                if (newNewsItem.itemID == newsItem.itemID){
                    newNewsItem.read = newsItem.read;
                    count = i;
                    break;
                }
                if (newNewsItem.itemID > newsItem.itemID){
                    count = i - 1;
                    break;
                }
            }
        }
        self.newsItems = objects;
        self.newsLastUpdated = [NSDate date];
        notification = AssociationStoreDidUpdateNewsNotification;
    }
    // Received Activities
    else if ([objectLoader.resourcePath isEqualToString:kActivitiesResource]) {
        // TODO: check if some information can be reused, e.g. underlying
        // FacebookEvent's.
        self.activities = objects;
        self.activitiesLastUpdated = [NSDate date];
        notification = AssociationStoreDidUpdateActivitiesNotification;
    }

    // Send notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notification object:self userInfo:nil];

    [self.activeRequests removeObject:objectLoader.resourcePath];
    [self updateStoreCache];
}

#pragma mark - Notifications

- (void)facebookEventUpdated:(NSNotification *)notification
{
    // Call method in 10 seconds so multiple changes are written at once
    [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(updateStoreCache)
                                                   object:nil];
    [self performSelector:@selector(updateStoreCache) withObject:nil afterDelay:10];
}

@end
