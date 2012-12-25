//
//  RestoLegend.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLegend.h"

@implementation RestoLegend

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoLegend with key: %@ and value %@",
            self.key, self.value];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    if (self = [super init]) {
        self.key = [aCoder decodeObjectForKey:@"key"];
        self.value = [aCoder decodeObjectForKey:@"value"];
        self.options = [aCoder decodeObjectForKey:@"options"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.options forKey:@"options"];
}
@end
