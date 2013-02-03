//
//  AppDelegate.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+AppColors.h"
#import "DashboardViewController.h"
#import "ShareKitConfigurator.h"

#import <RestKit/RestKit.h>
#import <ShareKit/SHK.h>
#import <ShareKit/SHKConfiguration.h>
#import <FacebookSDK/FacebookSDK.h>
#import <TestFlight.h>

#define kTestFlightToken @"5bc4ec5d-0095-4731-bb0c-ebb0b41ff14a"
#define kGoogleAnalyticsToken @"UA-25444917-3"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if TestFlightEnabled
    [TestFlight takeOff:kTestFlightToken];
#endif

#if GoogleAnalyticsEnabled
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;
    gai.dispatchInterval = 30;
    gai.defaultTracker = [gai trackerWithTrackingId:kGoogleAnalyticsToken];
    gai.debug = DEBUG;
#endif

#if DEBUG
    // Change RKLogLevelInfo to RKLoglevelTrace for debugging
    RKLogConfigureByName("RestKit/Network", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
#endif

    // Configure some parts of the application asynchronously
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(async, ^{
        // Check for internet connectivity
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusDetermined:)
                                                     name:RKReachabilityWasDeterminedNotification object:nil];
        [RKReachabilityObserver reachabilityObserverForInternet];

        // Configure ShareKit
        ShareKitConfigurator *config = [[ShareKitConfigurator alloc] init];
        [SHKConfiguration sharedInstanceWithConfigurator:config];
        [SHK flushOfflineQueue];
    });

    // Create and setup controllers
    DashboardViewController *dashboard = [[DashboardViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:dashboard];
    self.navController.navigationBar.tintColor = [UIColor hydraTintColor];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSession activeSession] handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)reachabilityStatusDetermined:(NSNotification *)notification
{
    // Prevent this dialog from showing up more than once
    static BOOL reachabilityDetermined = false;
    if(reachabilityDetermined) return;
    reachabilityDetermined = YES;

    RKReachabilityObserver *reachability = notification.object;
    if (!reachability.isNetworkReachable)
    {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{
            kErrorTitleKey: @"Geen internetverbinding",
            kErrorDescriptionKey: @"Sommige onderdelen van Hydra vereisen een "
                                  @"internetverbinding en zullen mogelijks niet "
                                  @"correct werken."}];
        [self handleError:error];
    }
}

BOOL errorDialogShown = false;

- (void)handleError:(NSError *)error
{
    NSLog(@"An error occured: %@", error);
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker trackException:NO withNSError:error];

    if (errorDialogShown) return;

    NSString *title = error.userInfo[kErrorTitleKey];
    if (!title) title = @"Fout";

    NSString *message = error.userInfo[kErrorDescriptionKey];
    if (!message) message = @"Er trad een onbekende fout op.";

    // Try to improve the error message
    if ([error.domain isEqual:RKErrorDomain]) {
        title = @"Netwerkfout";
        message = @"Er trad een fout op het bij het ophalen van externe informatie. "
                  @"Gelieve later opnieuw te proberen.";
    }

    // Show an alert
    errorDialogShown = true;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    errorDialogShown = false;
}

@end
