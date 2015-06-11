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

#define kRestoUrl @"https://zeus.ugent.be/hydra/api/1.0/resto/"
#define kRestoInfoPath @"meta.json"
#define kRestoMenuPath @"menu/%lu/%lu.json"

//#define kInfoUpdateIterval (24 * 60 * 60) /* one day */
#define kInfoUpdateIterval 20
#define kMenuUpdateIterval (12 * 60 * 60)

NSString *const RestoStoreDidReceiveMenuNotification =
    @"RestoStoreDidReceiveMenuNotification";
NSString *const RestoStoreDidUpdateInfoNotification =
    @"RestoStoreDidUpdateInfoNotification";

@interface RestoStore () <NSCoding>

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray *activeRequests;

@property (atomic, strong) NSMutableDictionary *menus;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *legend;
@property (nonatomic, strong) NSDate *infoLastUpdated;

@end

@interface RestoInfo : NSObject

+ (RKObjectMapping *)objectMapping;

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *legend;

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

- (instancetype)init
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
    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kRestoUrl]];
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
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        NSDate *today = [[NSDate date] dateAtStartOfDay];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];

        // Remove all old entries
        for (NSDate *date in [self.menus keyEnumerator]) {
            if ([today compare:date] == NSOrderedDescending) {
                [toRemove addObject:date];
            }
        }
        [self.menus removeObjectsForKeys:toRemove];
        DLog(@"Purged %lu old menus from RestoStore", (unsigned long)[toRemove count]);

        NSString *cachePath = [[self class] menuCachePath];
        [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
    });
}

#pragma mark - Data management and requests

- (RestoMenu *)menuForDay:(NSDate *)day
{
    // TODO: perhaps the menu is outdated
    // if the data is more than a day old, start a refresh in the background

    day = [day dateAtStartOfDay];
    RestoMenu *menu = self.menus[day];
    if (!menu || [menu.lastUpdated timeIntervalSinceNow] < -kMenuUpdateIterval) {
        [self _fetchMenuForWeek:day.week year:day.yearOfCalendarWeek];
    }
    return menu;
}

- (void)_fetchMenuForWeek:(NSUInteger)week year:(NSUInteger)year
{
    NSString *path = [NSString stringWithFormat:kRestoMenuPath, (unsigned long)year, (unsigned long)week];

    // Only one request for each resource allowed
    if ([self.activeRequests containsObject:path]) {
      return;
    }

    DLog(@"Fetching resto information for %lu/%lu", (unsigned long)year, (unsigned long)week);
    [self.activeRequests addObject:path];
    [self.objectManager addResponseDescriptor:
        [RKResponseDescriptor responseDescriptorWithMapping:[RestoMenu objectMapping]
                                                     method:RKRequestMethodGET
                                                pathPattern:path
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [self.objectManager getObjectsAtPath:path
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     [self _processMenuResult:mappingResult forPath:path];
                                 }
                                 failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"Updating resource %@ failed: %@", path, error);
                                     AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                     [app handleError:error];

                                     [self _processMenuResult:nil forPath:path];
                                 }];
}

- (void)_processMenuResult:(RKMappingResult *)mappingResult forPath:(NSString *)path
{
    NSArray *objects = [mappingResult array];

    [self _delayActiveRequestRemoval:path];
    for (RestoMenu *menu in objects) {
       NSDate *day = [[menu day] dateAtStartOfDay];
       menu.lastUpdated = [NSDate date];
       self.menus[day] = menu;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidReceiveMenuNotification object:self];

    [self updateStoreCache];
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

    if ([self.activeRequests containsObject:kRestoInfoPath]) {
      return;
    }

    DLog(@"Updating resto meta-information");
    [self.activeRequests addObject:kRestoInfoPath];
    [self.objectManager addResponseDescriptor:
        [RKResponseDescriptor responseDescriptorWithMapping:[RestoInfo objectMapping]
                                                     method:RKRequestMethodGET
                                                pathPattern:kRestoInfoPath
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    [self.objectManager getObjectsAtPath:kRestoInfoPath
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                   [self _processInfoResult:mappingResult];
                                 }
                                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                    [app handleError:error];
                                    [self _processInfoResult:nil];
                                }];
}

- (void)_processInfoResult:(RKMappingResult *)mappingResult
{
    RestoInfo *restoInfo = [mappingResult firstObject];
    DLog(@"Received %lu legends and %lu locations", (unsigned long)[restoInfo.legend count], (unsigned long)[restoInfo.locations count]);
    [self _delayActiveRequestRemoval:kRestoInfoPath];

    if ([restoInfo.legend count] > 0) {
     self.legend = restoInfo.legend;
    }
    if ([restoInfo.locations count] > 0) {
     self.locations = restoInfo.locations;
    }
    self.infoLastUpdated = [NSDate date];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidUpdateInfoNotification object:self];

    [self updateStoreCache];
}

#pragma mark - RestKit Object loading
- (void)_delayActiveRequestRemoval:(NSString *)resourcePath
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

@implementation RestoInfo

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RestoInfo class]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"legend" mapping:[RestoLegendItem objectMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"locations" mapping:[RestoLocation objectMapping]];
    return mapping;
}

@end
