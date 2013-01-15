//
//  ShareKitConfigurator.m
//  Hydra
//
//  Created by Pieter De Baets on 14/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "ShareKitConfigurator.h"

#define TEST_OLD_SHARERS 0

@implementation ShareKitConfigurator

- (NSString *)appName
{
	return @"Hydra";
}

- (NSString *)appURL
{
    return @"http://student.ugent.be/hydra";
}

- (NSString *)facebookAppId
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
}

- (NSString *)twitterConsumerKey
{
	return @"WHwijVLkJD5PDIqATzEmhQ";
}

- (NSString *)twitterSecret
{
	return @"9oPVJG4VN58mymrHuqCyjctEW30k96bJJo5OgGqPQjw";
}

- (NSString *)twitterCallbackUrl
{
	return @"http://student.ugent.be/hydra/twitter_callback";
}

- (NSString*)bitLyLogin
{
	return @"hydraapp";
}

- (NSString*)bitLyKey
{
	return @"R_33014dfdfc5e6dd6901ad2e45e85bf4e";
}

- (UIColor *)barTintForView:(UIViewController*)vc
{
    return [UIColor hydraTintColor];
}

- (NSArray*)defaultFavoriteURLSharers
{
    return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKFacebook", @"SHKSafari", nil];
}

#if TEST_OLD_SHARERS

- (NSNumber*)forcePreIOS6FacebookPosting
{
	return [NSNumber numberWithBool:true];
}

- (NSNumber*)forcePreIOS5TwitterAccess
{
	return [NSNumber numberWithBool:true];
}

#endif

@end
