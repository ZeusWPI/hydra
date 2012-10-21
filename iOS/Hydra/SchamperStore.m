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

NSString *const SchamperStoreDidUpdateArticlesNotification =
    @"SchamperStoreDidUpdateArticlesNotification";

@interface SchamperStore () <NSCoding, RKObjectLoaderDelegate>

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, strong) NSDate *lastUpdated;

@end

@implementation SchamperStore

+ (SchamperStore *)sharedStore
{
    static SchamperStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:self.articleCachePath];
        if (!sharedInstance) sharedInstance = [[SchamperStore alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.articles = [[NSArray alloc] init];
        self.lastUpdated = [NSDate date];
        self.active = false;
    }
    return self;
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.articles = [decoder decodeObjectForKey:@"articles"];
        self.lastUpdated = [decoder decodeObjectForKey:@"lastUpdated"];
        self.active = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.articles forKey:@"articles"];
    [coder encodeObject:self.lastUpdated forKey:@"lastUpdated"];
}

+ (NSString *)articleCachePath
{
    // Get cache directory
    NSArray *cacheDirectories =
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cacheDirectories[0];

    return [cacheDirectory stringByAppendingPathComponent:@"schamper.archive"];
}

- (void)saveStoreCache
{
    [NSKeyedArchiver archiveRootObject:self toFile:self.class.articleCachePath];
}

#pragma mark - Article fetching

- (void)updateArticles
{
    // Only allow one request at a time
    if (self.active) return;
    DLog(@"Starting Schamper update");

    // TODO: implement check to see if update is necessary
    // but allow for 'forced' updates (e.g. pull on tableview)
    // if not forced: check for internet connection?

    // The RKObjectManager must be retained, otherwise reachability notifications
    // will not be received properly and all kinds of weird stuff happen
    if (!self.objectManager) {
        self.objectManager = [RKObjectManager managerWithBaseURLString:kSchamperUrl];
        [SchamperArticle registerObjectMappingWith:[self.objectManager mappingProvider]];
        [[self.objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
    }
    [self.objectManager loadObjectsAtResourcePath:@"" delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    self.active = false;

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
    self.articles = objects;
    self.lastUpdated = [NSDate date];
    self.active = false;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:SchamperStoreDidUpdateArticlesNotification object:self];
    [self saveStoreCache];
}

@end
