//
//  AppDelegate.m
//  dwo
//
//  Created by Guntis Treulands on 16/11/13.
//  Copyright (c) 2013 Guntis Treulands. All rights reserved.
//

#import "AppDelegate.h"

#import "ObjectListViewController.h"


AppDelegate *_AppDelegate = nil;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _AppDelegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    [self setUpMainViewStructure];
    
    //This array will be used in all application. - In Object list, and later in glViewController to know which object should load.
    [self setUpObjectArray];
    
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
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - set up main elements

- (void)setUpMainViewStructure
{
    UINavigationController *mNavController = [UINavigationController new];
    
    [mNavController setViewControllers:@[[ObjectListViewController new]]];
    
    [self.window setRootViewController:mNavController];
}


- (void)setUpObjectArray
{
    _objectArray = @[
        @[@"Ashtray", @"a"],
        @[@"Banana", @"b"],
        @[@"Books", @"c"],
        @[@"Wolverine", @"d"],
        @[@"Chair", @"e"],
        @[@"Shell", @"f"],
        @[@"Snow owl", @"g"],
        @[@"Table", @"j"]];
}

@end
