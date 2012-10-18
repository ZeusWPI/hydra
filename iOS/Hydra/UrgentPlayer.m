//
//  UrgentPlayer.m
//  Hydra
//
//  Created by Yasser Deceukelier on 18/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentPlayer.h"

@implementation AudioStreamer (UrgentPlayer)

static AudioStreamer* _urgentPlayer = nil;

+ (AudioStreamer* )urgentPlayer
{
    if(!_urgentPlayer) {
        NSURL *url = [NSURL URLWithString:@"http://195.10.10.207/urgent/high.mp3?GKID=527afc3a195e11e2a7f800163e914f68&fspref=aHR0cDovL3d3dy51cmdlbnQuZm0vbHVpc3Rlcm9ubGluZQ%3D%3D"];
        _urgentPlayer = [[AudioStreamer alloc] initWithURL:url];
    }
    return _urgentPlayer;
}

@end
