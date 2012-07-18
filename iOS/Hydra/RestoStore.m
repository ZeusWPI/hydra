//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoStore.h"
#import "RestoMenu.h"

#define kRestoUrl @"http://kelder.zeus.ugent.be/~blackskad/resto/api/0.1"

NSString *const RestoStoreDidReceiveMenuNotification =
    @"RestoStoreDidReceiveMenuNotification";

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
        menus = [[NSMutableDictionary alloc] init];
        activeRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        menus = [decoder decodeObjectForKey:@"menuItems"];
        activeRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:menus forKey:@"menuItems"];
}

+ (NSString *)menuCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheDirectories objectAtIndex:0];

    return [cacheDirectory stringByAppendingPathComponent:@"restomenu.archive"];
}

- (void)updateStoreCache
{
    NSDate *today = [self dateWithoutTime:[NSDate date]];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];

    // Remove all old entries
    for (NSDate *date in [menus keyEnumerator]) {
        if ([today compare:date] == NSOrderedDescending) {
            [toRemove addObject:date];
        }
    }
    [menus removeObjectsForKeys:toRemove];
    DLog(@"Purged %d old menus from RestoStore", [toRemove count]);

    NSString *cachePath = [[self class] menuCachePath];
    [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
}

#pragma mark -
#pragma mark Menu management and requests

- (RestoMenu *)menuForDay:(NSDate *)day
{
    day = [self dateWithoutTime:day];
    RestoMenu *menu = [menus objectForKey:day];
    if (!menu) {
        [self fetchMenuForWeek:[self weeknumberForDate:day]];
    }
    return menu;
}

- (void)fetchMenuForWeek:(NSUInteger)week
{
    if (!objectManager) {
        objectManager = [RKObjectManager managerWithBaseURLString:kRestoUrl];
        [RestoMenu registerObjectMappingWith:[objectManager mappingProvider]];
        [[objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
    }

    NSString *path = [NSString stringWithFormat:@"/week/%d.json", week];

    // Only one request for each resource allowed
    if (![activeRequests containsObject:path]) {
        DLog(@"Fetching resto information for week %d", week);
        [activeRequests addObject:path];
        [objectManager loadObjectsAtResourcePath:path delegate:self];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [activeRequests removeObject:[objectLoader resourcePath]];

    // Show an alert if something goes wrong
    // TODO: make errors thrown by RestKit more userfriendly
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    
    VLog(activeRequests);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    // Save menus
    for (RestoMenu *menu in objects) {
        NSDate *day = [self dateWithoutTime:[menu day]];
        [menus setObject:menu forKey:day];
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidReceiveMenuNotification object:self];
    [self updateStoreCache];

    // Only now remove the 'active' request, preventing clients
    // from restarting the request in response to missing data
    [activeRequests removeObject:[objectLoader resourcePath]];
}

#pragma mark -
#pragma mark Date utilities

- (NSUInteger)weeknumberForDate:(NSDate *)date;
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekOfYearCalendarUnit
                                     fromDate:date];
    return [comps weekOfYear];
}

- (NSDate *)dateWithoutTime:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                     fromDate:date];
    return [cal dateFromComponents:comps];
}

@end
