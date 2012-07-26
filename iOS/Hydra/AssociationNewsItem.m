//
//  AssociationNewsItem.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationNewsItem.h"
#import <RestKit/RestKit.h>
#import "NSString+Utilities.h"

@implementation AssociationNewsItem

@synthesize associationId, title, date, body;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping mapAttributes:@"title", @"date", nil];
    [objectMapping mapKeyPath:@"description" toAttribute:@"body"];
    [objectMapping mapKeyPath:@"association_id" toAttribute:@"associationId"];
    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@"newsItem"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssocationNewsItem '%@'>", title];
}

- (void)setTitle:(NSString *)newTitle
{
    title = [newTitle stringByStrippingCDATA];
}

- (void)setBody:(NSString *)newBody
{
    body = [newBody stringByStrippingCDATA];
}

@end
