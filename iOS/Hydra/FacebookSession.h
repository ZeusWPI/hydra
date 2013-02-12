//
//  FacebookSession.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const FacebookSessionStateChangedNotification;
extern NSString *const FacebookUserInfoUpdatedNotifcation;

@interface FacebookSession : NSObject

+ (FacebookSession *)sharedSession;

@property (nonatomic, readonly) BOOL open;
@property (nonatomic, readonly) id<FBGraphUser> userInfo;

- (BOOL)openWithAllowLoginUI:(BOOL)allowLoginUI;
- (BOOL)openWithAllowLoginUI:(BOOL)allowLoginUI completion:(void (^)())completion;
- (void)close;

- (FBRequest *)requestWithQuery:(NSString *)query;
- (FBRequest *)requestWithGraphPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (FBRequest *)requestWithGraphPath:(NSString *)path parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)method;

@end
