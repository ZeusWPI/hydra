//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperStore.h"
#import "SchamperArticle.h"
#import <RestKit/RestKit.h>

#define kSchamperUrl @"http://www.schamper.ugent.be/dagelijks"

NSString *const SchamperStoreDidUpdateArticlesNotification
    = @"SchamperStoreDidUpdateArticlesNotification";

@interface SchamperStore () <RKObjectLoaderDelegate> {
    BOOL active;
}

+ (NSString *)articleCachePath;

- (void)archiveStore;

@end

@implementation SchamperStore

@synthesize articles, lastUpdated;

+ (SchamperStore *)sharedStore
{
    static SchamperStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self articleCachePath]];
        if (!sharedInstance) sharedInstance = [[SchamperStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        articles = [[NSArray alloc] init];
        lastUpdated = [NSDate date];
        active = false;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        articles = [decoder decodeObjectForKey:@"articles"];
        lastUpdated = [decoder decodeObjectForKey:@"lastUpdated"];
        active = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:articles forKey:@"articles"];
    [coder encodeObject:lastUpdated forKey:@"lastUpdated"];
}

+ (NSString *)articleCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheDirectories objectAtIndex:0];

    return [cacheDirectory stringByAppendingPathComponent:@"schamper.archive"];
}

- (void)archiveStore
{
    NSString *cachePath = [[self class] articleCachePath];
    [NSKeyedArchiver archiveRootObject:self toFile:cachePath];
}

- (void)updateArticles
{
    // Only allow one request at a time
    if (active) return;

    // TODO: implement check to see if update is necessary
    // but allow for 'forced' updates (e.g. pull on tableview)

    RKObjectManager *manager = [RKObjectManager managerWithBaseURLString:kSchamperUrl];
    [SchamperArticle registerObjectMappingWith:[manager mappingProvider]];
    [[manager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
    [manager loadObjectsAtResourcePath:@"" delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    active = false;

    // Show an alert if something goes wrong
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    articles = objects;
    lastUpdated = [NSDate date];
    active = false;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:SchamperStoreDidUpdateArticlesNotification object:self];
    [self archiveStore];
}

@end
