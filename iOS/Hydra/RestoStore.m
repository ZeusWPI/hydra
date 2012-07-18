//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoStore.h"
#import "RestoMenu.h"
#import <RestKit/RestKit.h>

#define kRestoUrl @"http://kelder.zeus.ugent.be/~blackskad/resto/api/0.1"

NSString *const RestoStoreDidReceiveMenuNotification =
    @"RestoStoreDidReceiveMenuNotification";

@interface RestoStore () <RKObjectLoaderDelegate> {
    RKObjectManager *objectManager;
    BOOL active;
}

+ (NSString *)menuCachePath;
- (void)archiveStore;
- (NSUInteger)currentWeekNumber;

@end

@implementation RestoStore

@synthesize menuItems, week;

+ (RestoStore *)sharedStore
{
    static RestoStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        // sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self menuCachePath]];
        if (!sharedInstance) sharedInstance = [[RestoStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        menuItems = [[NSArray alloc] init];
        week = [self currentWeekNumber];
        active = false;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        menuItems = [decoder decodeObjectForKey:@"menuItems"];
        week = [decoder decodeIntegerForKey:@"week"];
        active = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:menuItems forKey:@"menuItems"];
    [coder encodeInteger:week forKey:@"week"];
}

+ (NSString *)menuCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheDirectories objectAtIndex:0];

    return [cacheDirectory stringByAppendingPathComponent:@"restomenu.archive"];
}

- (void)archiveStore
{
    NSString *cachePath = [[self class] menuCachePath];
    [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
}

- (void)updateMenu
{
    // Only allow one request at a time
    if (active) return;
    DLog(@"Starting Resto update");

    // TODO: implement check to see if update is necessary
    // but allow for 'forced' updates (e.g. pull on tableview)

    if (!objectManager) {
        objectManager = [RKObjectManager managerWithBaseURLString:kRestoUrl];
        [RestoMenu registerObjectMappingWith:[objectManager mappingProvider]];
        [[objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
    }
    [objectManager loadObjectsAtResourcePath:@"/week/13.json" delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    active = false;

    // Show an alert if something goes wrong
    // TODO: make more userfriendly (required for errors thrown by restkit)
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    menuItems = objects;
    week = [self currentWeekNumber];
    active = false;

    VLog(menuItems);

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:RestoStoreDidReceiveMenuNotification object:self];
    //[self archiveStore];
}

- (NSUInteger)currentWeekNumber
{
    return 13;

    // TODO: always show for the next week, starting on saturday?
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekOfYearCalendarUnit
                                     fromDate:[NSDate date]];
    return [comps weekOfYear];
}

@end
