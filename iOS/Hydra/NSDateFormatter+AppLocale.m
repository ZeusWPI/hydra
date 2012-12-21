//
//  NSDateFormatter+DefaultLocale.m
//  Hydra
//
//  Created by Pieter De Baets on 21/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "NSDateFormatter+AppLocale.h"

@implementation NSDateFormatter (AppLocale)

+ (NSDateFormatter *)H_dateFormatterWithAppLocale;
{
    static NSLocale *locale;
    if (!locale) {
        NSString *key = (NSString *)kCFBundleDevelopmentRegionKey;
        NSString *identifier = [[NSBundle mainBundle] infoDictionary][key];
        locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = locale;

    return dateFormatter;
}

@end
