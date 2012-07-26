//
//  NSString+Utilities.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (NSString *)stringByStrippingCDATA
{
    if ([self hasPrefix:@"<![CDATA["]) {
        // strlen("<![CDATA[") == 9, strlen("]]>") == 3
        NSRange strip = NSMakeRange(9, [self length] - 9 - 3);
        return [self substringWithRange:strip];
    }
    else {
        return [self copy];
    }
}

@end
