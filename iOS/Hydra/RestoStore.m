//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoStore.h"
#import "RestoMenu.h"
#import "NSDate+Utilities.h"
#import "AppDelegate.h"
#import <RestKit/RestKit.h>

#define kRestoUrl @"http://zeus.ugent.be/hydra/api/1.0/resto"
#define kRestoInfoPath @"/meta.json"
#define kRestoMenuPath @"/menu/%d/%d.json"

NSString *const RestoStoreDidReceiveMenuNotification =
    @"RestoStoreDidReceiveMenuNotification";

@interface RestoStore () <NSCoding, RKObjectLoaderDelegate>

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray *activeRequests;
@property (nonatomic, strong) NSMutableDictionary *menus;

@end

@implementation RestoStore

+ (RestoStore *)sharedStore
{
    static RestoStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self menuCachePath]];
        if (!sharedInstance) sharedInstance = [[RestoStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.menus = [[NSMutableDictionary alloc] init];
        self.activeRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.menus = [decoder decodeObjectForKey:@"menus"];
        self.activeRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.menus forKey:@"menus"];
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

#pragma mark - Menu management and requests

- (RestoMenu *)menuForDay:(NSDate *)day
{
    // TODO: perhaps the menu is outdated
    // if the data is more than a day old, start a refresh in the background

    day = [day dateAtStartOfDay];
    RestoMenu *menu = self.menus[day];
    if (!menu) {
        [self fetchMenuForWeek:day.week year:day.year];
    }
    return menu;
}

- (void)fetchMenuForWeek:(NSUInteger)week year:(NSUInteger)year
{
    if (!self.objectManager) {
        self.objectManager = [RKObjectManager managerWithBaseURLString:kRestoUrl];
        [RestoMenu registerObjectMappingWith:[self.objectManager mappingProvider]];
        [[self.objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
    }

    NSString *path = [NSString stringWithFormat:kRestoMenuPath, year, week];

    // Only one request for each resource allowed
    if (![self.activeRequests containsObject:path]) {
        DLog(@"Fetching resto information for %d/%d", year, week);
        [self.activeRequests addObject:path];
        [self.objectManager loadObjectsAtResourcePath:path delegate:self];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app handleError:error];

    [self delayActiveRequestRemoval:objectLoader.resourcePath];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [self delayActiveRequestRemoval:objectLoader.resourcePath];

    // Save menus
    for (RestoMenu *menu in objects) {
        NSDate *day = [[menu day] dateAtStartOfDay];
        self.menus[day] = menu;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidReceiveMenuNotification object:self];
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
