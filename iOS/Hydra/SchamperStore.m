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
#import <RKXMLReaderSerialization.h>

#define kSchamperBaseUrl @"http://zeus.ugent.be/hydra/api/1.0/schamper/"
#define kSchamperDailyUrl @"daily.xml"
NSString *const SchamperStoreDidUpdateArticlesNotification =
    @"SchamperStoreDidUpdateArticlesNotification";

@interface SchamperStore () <NSCoding>

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, assign) BOOL storageOutdated;

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
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self updateArticles];
}

- (void)syncStorage
{
    if (!self.storageOutdated) {
        return;
    }

    // Immediately mark the cache as being updated, as this is an async operation
    self.storageOutdated = NO;

    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        [NSKeyedArchiver archiveRootObject:self toFile:self.class.articleCachePath];
    });
}

- (void)markStorageOutdated
{
    self.storageOutdated = YES;
}

#pragma mark - Article fetching

- (void)updateArticles
{
    // Only allow one request at a time
    if (self.active) return;
    DLog(@"Starting Schamper update");

    // The RKObjectManager must be retained, otherwise reachability notifications
    // will not be received properly and all kinds of weird stuff happen
    if (!self.objectManager) {
        self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kSchamperBaseUrl]];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    [self.objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[SchamperArticle objectMapping] method:RKRequestMethodGET pathPattern:kSchamperDailyUrl keyPath:@"rss.channel.item" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [self.objectManager getObjectsAtPath:kSchamperDailyUrl parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         NSArray *objects = [mappingResult array];
         NSMutableSet *set = [NSMutableSet set];
         for (SchamperArticle *article in self.articles) {
             if (article.read) {
                 [set addObject:article.link];
             }
         }
         for (SchamperArticle *article in objects) {
             if ([set containsObject:article.link]) {
                 article.read = YES;
             }
         }
         self.articles = objects;
         self.lastUpdated = [NSDate date];
         self.active = NO;

         [self markStorageOutdated];
         [self syncStorage];

         NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
         [center postNotificationName:SchamperStoreDidUpdateArticlesNotification object:self];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         self.active = false;
         NSLog(@"Error: %@",error);
         // Show error
         AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         [app handleError:error];
     }];
}

@end
