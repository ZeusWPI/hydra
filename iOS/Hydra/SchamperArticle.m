//
//  SchamperArticle.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperArticle.h"
#import "SchamperStore.h"
#import <RestKit/RestKit.h>
#import <RKXMLReaderSerialization.h>

@implementation SchamperArticle

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SchamperArticle: %@ (%@)>", self.title, self.date];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _title = [decoder decodeObjectForKey:@"title"];
        _link = [decoder decodeObjectForKey:@"link"];
        _date = [decoder decodeObjectForKey:@"date"];
        _author = [decoder decodeObjectForKey:@"author"];
        _body = [decoder decodeObjectForKey:@"body"];
        _read = [decoder decodeBoolForKey:@"read"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.link forKey:@"link"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeBool:self.read forKey:@"read"];
}

+ (RKObjectMapping *)objectMapping
{
    // Register rss+xml MIME-type
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/rss+xml"];

    // Create mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping setForceCollectionMapping:YES];

    [mapping addAttributeMappingsFromDictionary:@{
       @"title.text": @"title",
       @"link.text": @"link",
       @"pubDate.text": @"date",
       @"dc:creator.text": @"author",
       @"description.text": @"body"
    }];

    // Date format: Sun, 10 Jun 2012 01:03:24 +0200 (RFC2822)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, d MMM y HH:mm:ss Z";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [mapping setDateFormatters:@[dateFormatter]];
    return mapping;
}

#pragma mark - Properties

- (void)setRead:(BOOL)read
{
    if (read != _read) {
        _read = read;
        [[SchamperStore sharedStore] markStorageOutdated];
    }
}

@end
