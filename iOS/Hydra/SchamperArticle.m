//
//  SchamperArticle.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperArticle.h"
#import <RestKit/RKXMLParserXMLReader.h>

#define kSchamperUrl @"http://www.schamper.ugent.be/dagelijks"

@implementation SchamperArticle

@synthesize title, link, date, author, body;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SchamperArticle: %@ (%@)>", title, date];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        title = [decoder decodeObjectForKey:@"title"];
        link = [decoder decodeObjectForKey:@"link"];
        author = [decoder decodeObjectForKey:@"author"];
        body = [decoder decodeObjectForKey:@"body"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:link forKey:@"link"];
    [coder encodeObject:author forKey:@"author"];
    [coder encodeObject:body forKey:@"body"];
}

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    static RKObjectMapping* mapping = nil;
    if (!mapping) {
        // Register rss+xml MIME-type
        [[RKParserRegistry sharedRegistry] setParserClass:[RKXMLParserXMLReader class]
                                              forMIMEType:@"application/rss+xml"];

        // Create mapping
        mapping = [RKObjectMapping mappingForClass:self];
        [mapping mapKeyPath:@"title" toAttribute:@"title"];
        [mapping mapKeyPath:@"link" toAttribute:@"link"];
        [mapping mapKeyPath:@"pubDate" toAttribute:@"date"];
        [mapping mapKeyPath:@"dc:creator" toAttribute:@"author"];
        [mapping mapKeyPath:@"description" toAttribute:@"body"];

        // Date format: Sun, 10 Jun 2012 01:03:24 +0200 (RFC2822)
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        [mapping setDateFormatters:[NSArray arrayWithObject:dateFormatter]];
    }
    [mappingProvider setMapping:mapping forKeyPath:@"rss.channel.item"];
}

@end
