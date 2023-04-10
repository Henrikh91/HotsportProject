//
//  main.m
//  HotspotProject
//
//  Created by Genrih Korenujenko on 26.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NSObject+PropertyName.h"
#import "TestVC.h"

int main(int argc, char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"%@", keypathStringForClass(TestVC, test));
        NSLog(@"%@", keypathStringForClass(TestVC, test.length));
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
