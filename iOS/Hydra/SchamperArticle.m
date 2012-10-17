//
//  SchamperArticle.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperArticle.h"
#import <RestKit/RestKit.h>
#import <RestKit/RKXMLParserXMLReader.h>

@implementation SchamperArticle

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SchamperArticle: %@ (%@)>", self.title, self.date];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.link = [decoder decodeObjectForKey:@"link"];
        self.author = [decoder decodeObjectForKey:@"author"];
        self.body = [decoder decodeObjectForKey:@"body"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.link forKey:@"link"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.body forKey:@"body"];
}

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    // Register rss+xml MIME-type
    [[RKParserRegistry sharedRegistry] setParserClass:[RKXMLParserXMLReader class]
                                          forMIMEType:@"application/rss+xml"];

    // Create mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping mapKeyPath:@"title" toAttribute:@"title"];
    [mapping mapKeyPath:@"link" toAttribute:@"link"];
    [mapping mapKeyPath:@"pubDate" toAttribute:@"date"];
    [mapping mapKeyPath:@"dc:creator" toAttribute:@"author"];
    [mapping mapKeyPath:@"description" toAttribute:@"body"];

    // Date format: Sun, 10 Jun 2012 01:03:24 +0200 (RFC2822)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, d MMM y HH:mm:ss Z";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [mapping setDateFormatters:@[dateFormatter]];

    [mappingProvider setObjectMapping:mapping forKeyPath:@"rss.channel.item"];
}

@end
