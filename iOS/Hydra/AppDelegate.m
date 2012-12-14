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
#import <RestKit/RestKit.h>
#import "TestFlight.h"

#define kTestFlightToken @"5bc4ec5d-0095-4731-bb0c-ebb0b41ff14a"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

#if TestFlightEnabled
    [TestFlight takeOff:kTestFlightToken];
#endif

    // Create and setup controllers
    DashboardViewController *dashboard = [[DashboardViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:dashboard];
    self.navController.navigationBar.tintColor = [UIColor hydraTintColor];

#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
#else
    RKLogConfigureByName("RestKit/Network", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
#endif

    // TODO: use reachability

    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    return YES;
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

BOOL errorDialogShown = false;

- (void)handleError:(NSError *)error
{
    NSLog(@"An error occured: %@", error);
    if (errorDialogShown) return;

    NSString *title = @"Fout";
    NSString *message = [@"Er trad een onbekende fout op.\n\n" stringByAppendingString:error.localizedDescription];

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
