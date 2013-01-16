//
//  main.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
        // Force language
        [[NSUserDefaults standardUserDefaults] setValue:@[@"nl"] forKey:@"AppleLanguages"];
        return UIApplicationMain(argc, argv, @"ApplicationWithRemoteSupport", @"AppDelegate");
    }
}
