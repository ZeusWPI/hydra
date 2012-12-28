//
//  RestoLegend.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLegend.h"
#import <RestKit/RestKit.h>

@implementation RestoLegend

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoLegend with key: %@ and value %@",
            self.key, self.value];
}

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    // Create mapping for locations
    RKObjectMapping *legendMapping = [RKObjectMapping mappingForClass:self];
    //[legendMapping setForceCollectionMapping:YES];
    [legendMapping mapKeyPath:@"key" toAttribute:@"key"];
    [legendMapping mapKeyPath:@"value" toAttribute:@"value"];
    [legendMapping mapKeyPath:@"style" toAttribute:@"style"];
    
    // Register mapping
    [mappingProvider setObjectMapping:legendMapping forKeyPath:@"legend"];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    if (self = [super init]) {
        self.key = [aCoder decodeObjectForKey:@"key"];
        self.value = [aCoder decodeObjectForKey:@"value"];
        self.style = [aCoder decodeObjectForKey:@"style"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.style forKey:@"style"];
}

#pragma mark isEqual and hash implementation
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestoLegend:other];
}

- (BOOL)isEqualToRestoLegend:(RestoLegend *)aLegend {
    if (self == aLegend)
        return YES;
    if (![[self key] isEqualToString:[aLegend key]])
        return NO;
    if (![[self value] isEqualToString:[aLegend value]])
        return NO;
    if (![[self style] isEqualToString:[aLegend style]])
        return NO;
    return YES;
}
@end
