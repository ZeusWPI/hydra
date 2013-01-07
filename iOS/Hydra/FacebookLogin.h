//
//  FacebookLogin.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const FBSessionStateChangedNotification;

@interface FacebookLogin : UIResponder

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;
+ (FacebookLogin*) sharedLogin;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
