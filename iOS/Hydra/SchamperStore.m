//
//  SchamperStore.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperStore.h"
#import "SchamperArticle.h"
#import "AppDelegate.h"
#import <RestKit/RestKit.h>

#define kSchamperUrl @"http://zeus.ugent.be/hydra/api/1.0/schamper/daily.xml"

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
        @try {
            sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:self.articleCachePath];
        }
        @catch (NSException *exception) {
            NSLog(@"Got exception while reading Schamper archive: %@", exception);
        }
        @finally {
            if (!sharedInstance) sharedInstance = [[SchamperStore alloc] init];
        }
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
        AssertClassOrNil(self.articles, NSArray);
        self.lastUpdated = [decoder decodeObjectForKey:@"lastUpdated"];
        AssertClassOrNil(self.lastUpdated, NSDate);
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

- (void)reloadArticles
{
    [self.objectManager.client.requestCache invalidateAll];
    [self updateArticles];
}

- (void)updateStoreCache
{
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        [NSKeyedArchiver archiveRootObject:self toFile:self.class.articleCachePath];
    });
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
        [SchamperArticle registerObjectMappingWith:self.objectManager.mappingProvider];
        self.objectManager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    }
    [self.objectManager loadObjectsAtResourcePath:@"" delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    self.active = false;

    // Show error
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app handleError:error];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    self.articles = objects;
    self.lastUpdated = [NSDate date];
    self.active = false;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:SchamperStoreDidUpdateArticlesNotification object:self];
    [self updateStoreCache];
}

@end
