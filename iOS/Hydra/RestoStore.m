//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoStore.h"
#import "RestoMenu.h"
#import "RestoLegendItem.h"
#import "RestoLocation.h"
#import "NSDate+Utilities.h"
#import "AppDelegate.h"
#import <RestKit/RestKit.h>

#define kRestoUrl @"http://zeus.ugent.be/hydra/api/1.0/resto"
#define kRestoInfoPath @"/meta.json"
#define kRestoMenuPath @"/menu/%d/%d.json"

#define kInfoUpdateIterval (24 * 60 * 60) /* one day */
#define kMenuUpdateIterval (24 * 60 * 60)

NSString *const RestoStoreDidReceiveMenuNotification =
    @"RestoStoreDidReceiveMenuNotification";
NSString *const RestoStoreDidUpdateInfoNotification =
    @"RestoStoreDidUpdateInfoNotification";

@interface RestoStore () <NSCoding, RKObjectLoaderDelegate>

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray *activeRequests;

@property (nonatomic, strong) NSMutableDictionary *menus;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *legend;
@property (nonatomic, strong) NSDate *infoLastUpdated;

@end

@implementation RestoStore

+ (RestoStore *)sharedStore
{
    static RestoStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        @try {
            sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self menuCachePath]];
        }
        @catch (NSException *exception) {
            NSLog(@"Got exception while reading Resto archive: %@", exception);
        }
        @finally {
            if (!sharedInstance) sharedInstance = [[RestoStore alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.menus = [[NSMutableDictionary alloc] init];
        self.locations = [[NSArray alloc] init];
        self.legend = [[NSArray alloc] init];

        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.activeRequests = [[NSMutableArray alloc] init];

    if (!self.infoLastUpdated) {
        self.infoLastUpdated = [NSDate dateWithTimeIntervalSince1970:0];
    }

    // Initialize objectManager
    self.objectManager = [RKObjectManager managerWithBaseURLString:kRestoUrl];
    self.objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.menus = [decoder decodeObjectForKey:@"menus"];
        AssertClassOrNil(self.menus, NSMutableDictionary);
        self.locations = [decoder decodeObjectForKey:@"locations"];
        AssertClassOrNil(self.locations, NSArray);
        self.legend = [decoder decodeObjectForKey:@"legend"];
        AssertClassOrNil(self.legend, NSArray);
        self.infoLastUpdated = [decoder decodeObjectForKey:@"infoLastUpdated"];
        AssertClassOrNil(self.infoLastUpdated, NSDate);

        [self sharedInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.menus forKey:@"menus"];
    [coder encodeObject:self.locations forKey:@"locations"];
    [coder encodeObject:self.legend forKey:@"legend"];
    [coder encodeObject:self.infoLastUpdated forKey:@"infoLastUpdated"];
}

+ (NSString *)menuCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cacheDirectories[0];

    return [cacheDirectory stringByAppendingPathComponent:@"resto.archive"];
}

- (void)updateStoreCache
{
    NSDate *today = [[NSDate date] dateAtStartOfDay];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];

    // Remove all old entries
    for (NSDate *date in [self.menus keyEnumerator]) {
        if ([today compare:date] == NSOrderedDescending) {
            [toRemove addObject:date];
        }
    }
    [self.menus removeObjectsForKeys:toRemove];
    DLog(@"Purged %d old menus from RestoStore", [toRemove count]);

    NSString *cachePath = [[self class] menuCachePath];
    [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
}

#pragma mark - Data management and requests

- (RestoMenu *)menuForDay:(NSDate *)day
{
    // TODO: perhaps the menu is outdated
    // if the data is more than a day old, start a refresh in the background

    day = [day dateAtStartOfDay];
    RestoMenu *menu = self.menus[day];
    if (!menu || [menu.lastUpdated timeIntervalSinceNow] < -kMenuUpdateIterval) {
        [self fetchMenuForWeek:day.week year:day.yearOfCalendarWeek];
    }
    return menu;
}

- (void)fetchMenuForWeek:(NSUInteger)week year:(NSUInteger)year
{
    NSString *path = [NSString stringWithFormat:kRestoMenuPath, year, week];

    // Only one request for each resource allowed
    if (![self.activeRequests containsObject:path]) {
        DLog(@"Fetching resto information for %d/%d", year, week);
        [self.activeRequests addObject:path];
        [self.objectManager loadObjectsAtResourcePath:path usingBlock:^(RKObjectLoader *loader) {
            RKObjectMappingProvider *mapping = [RKObjectMappingProvider objectMappingProvider];
            [RestoMenu registerObjectMappingWith:mapping];
            loader.mappingProvider = mapping;
            loader.delegate = self;
        }];
    }
}

-(NSArray *)locations
{
    [self refreshInfo];
    return _locations;
}

-(NSArray *)legend
{
    [self refreshInfo];
    return _legend;
}

- (void)refreshInfo
{
    // Check if an update is required
    if ([self.infoLastUpdated timeIntervalSinceNow] > -kInfoUpdateIterval) {
        return;
    }

    if (![self.activeRequests containsObject:kRestoInfoPath]) {
        DLog(@"Updating resto meta-information");
        [self.activeRequests addObject:kRestoInfoPath];
        [self.objectManager loadObjectsAtResourcePath:kRestoInfoPath usingBlock:^(RKObjectLoader *loader) {
            RKObjectMappingProvider *mapping = [RKObjectMappingProvider objectMappingProvider];
            [RestoLegendItem registerObjectMappingWith:mapping];
            [RestoLocation registerObjectMappingWith:mapping];
            loader.mappingProvider = mapping;
            loader.delegate = self;
        }];
    }
}

#pragma mark - RestKit Object loading

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app handleError:error];

    [self delayActiveRequestRemoval:objectLoader.resourcePath];
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    // Only handle menu results in this method
    if ([objectLoader.resourcePath isEqual:kRestoInfoPath]) return;

    [self delayActiveRequestRemoval:objectLoader.resourcePath];
    for (RestoMenu *menu in objects) {
        NSDate *day = [[menu day] dateAtStartOfDay];
        menu.lastUpdated = [NSDate date];
        self.menus[day] = menu;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidReceiveMenuNotification object:self];

    [self updateStoreCache];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjectDictionary:(NSDictionary *)dictionary
{
    // Only handle info results in this method
    if (![objectLoader.resourcePath isEqual:kRestoInfoPath]) return;

    [self delayActiveRequestRemoval:objectLoader.resourcePath];

    if ([dictionary[@"legend"] count] > 0) {
        self.legend = dictionary[@"legend"];
    }
    if ([dictionary[@"locations"] count] > 0) {
        self.locations = dictionary[@"locations"];
    }
    self.infoLastUpdated = [NSDate date];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidUpdateInfoNotification object:self];

    [self updateStoreCache];
}

- (void)delayActiveRequestRemoval:(NSString *)resourcePath
{
    // Only clear the request after 10 seconds, when all related requests have
    // finished with reasonable certainty, to prevent a request loop when not
    // all data requested was found.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.activeRequests removeObject:resourcePath];
    });
}

@end
