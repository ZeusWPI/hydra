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

#define kBaseUrl @"http://student.ugent.be/hydra/api/1.0"
#define kActivitiesResource @"/all_activities.json"
#define kNewsResource @"/all_news.json"
#define kUpdateInterval (5*60)

NSString *const AssociationStoreDidUpdateNewsNotification =
    @"AssociationStoreDidUpdateNewsNotification";
NSString *const AssociationStoreDidUpdateActivitiesNotification =
    @"AssociationStoreDidUpdateActivitiesNotification";

@interface AssociationStore () <NSCoding, RKObjectLoaderDelegate, RKRequestDelegate>

@property (nonatomic, strong) NSDictionary *associations;
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
        self.associations = [Association updateAssociations:nil];
        self.newsItems = nil;
        self.activities = nil;
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.activeRequests = [[NSMutableArray alloc] init];
    self.newsLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
    self.activitiesLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];

    self.objectManager = [RKObjectManager managerWithBaseURLString:kBaseUrl];
    self.objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    [self.objectManager.client.requestCache invalidateAll];
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        NSArray *associations = [decoder decodeObjectForKey:@"associations"];
        AssertClassOrNil(associations, NSArray);
        _associations = [Association updateAssociations:associations];

        _newsItems = [decoder decodeObjectForKey:@"newsItems"];
        AssertClassOrNil(_newsItems, NSArray);

        _activities = [decoder decodeObjectForKey:@"activities"];
        AssertClassOrNil(_activities, NSArray);

        [self sharedInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_associations forKey:@"associations"];
    [coder encodeObject:_newsItems forKey:@"newsItems"];
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
    [NSKeyedArchiver archiveRootObject:self toFile:self.class.storeCachePath];
}

#pragma mark - Accessors

- (NSArray *)assocations
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

- (NSArray *)activities
{
    [self updateResource:kActivitiesResource lastUpdated:self.activitiesLastUpdated class:[AssociationActivity class]];
    return _activities;
}

- (NSArray *)newsItems
{
    [self updateResource:kNewsResource lastUpdated:self.newsLastUpdated class:[AssociationNewsItem class]];
    return _newsItems;
}

#pragma mark - RestKit Object loading

- (void)updateResource:(NSString *)resource lastUpdated:(NSDate *)lastUpdated class:(Class)class
{
    // Check if an update is required
    if ([lastUpdated timeIntervalSinceNow] > -kUpdateInterval) {
        return;
    }

    if (![self.activeRequests containsObject:resource]) {
        DLog(@"Updating %@", resource);
        [self.activeRequests addObject:resource];
        [self.objectManager loadObjectsAtResourcePath:resource usingBlock:^(RKObjectLoader *loader) {
            RKObjectMappingProvider *mapping = [RKObjectMappingProvider objectMappingProvider];
            [class registerObjectMappingWith:mapping];
            loader.mappingProvider = mapping;
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
    VLog(objects);
    /*NSString *notification = nil;
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
    [self updateStoreCache];*/
}

@end
