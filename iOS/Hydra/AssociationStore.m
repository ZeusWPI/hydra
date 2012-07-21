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

#define kVersoUrl @"http://golive.myverso.com/ugent"

@implementation AssociationStore

@synthesize assocations;

+ (AssociationStore *)sharedStore
{
    static AssociationStore *sharedInstance = nil;
    if (!sharedInstance) {
        // Try restoring the store from archive
        //sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self articleCachePath]];
        if (!sharedInstance) sharedInstance = [[AssociationStore alloc] init];
    }
    return sharedInstance;
}

#pragma mark - Caching

- (id)initWithCoder:(NSCoder *)decoder
{
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

#pragma mark - Remote data management and requests

- (NSArray *)activitiesForAssocation:(Association *)assocation
{
    if (!objectManager) [self initializeObjectManager];
    return nil;
}

- (NSArray *)newsItemsForAssocation:(Association *)assocation
{
    if (!objectManager) [self initializeObjectManager];

    [objectManager loadObjectsAtResourcePath:@"/News/Variable/ZEUS.xml" delegate:self];

    return nil;
}

- (void)initializeObjectManager
{
    objectManager = [RKObjectManager managerWithBaseURLString:kVersoUrl];
    [AssociationActivity registerObjectMappingWith:[objectManager mappingProvider]];
    [AssociationNewsItem registerObjectMappingWith:[objectManager mappingProvider]];
    [[objectManager client] setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [[objectManager requestQueue] setShowsNetworkActivityIndicatorWhenBusy:YES];
}

- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData
{
    // The data retrieved for associations has the association-name as root tag
    // which is a crazy bad idea. So we just skip it and work on the data underneath.
    NSDictionary *original = *mappableData;
    NSString *rootKey = [[original allKeys] objectAtIndex:0];
    if (![rootKey isEqual:@"activities"]) {
        *mappableData = [original allValues];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    // Show an alert if something goes wrong
    // TODO: make errors thrown by RestKit more userfriendly
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    DLog(@"%@", [[objects objectAtIndex:0] body]);
}

@end
