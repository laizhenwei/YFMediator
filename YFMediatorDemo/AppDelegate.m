//
//  AppDelegate.m
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/14.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import "AppDelegate.h"
#import "YFMediator.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [self intercept];
    
    UIViewController *root = [[YFMediator shared] viewController:@"ViewController1"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)intercept {
    
    [[YFMediator shared] intercept:YFMediatorInterceptBeforeInit handler:^BOOL(__autoreleasing id *viewController, NSMutableDictionary *params) {
        if ([*viewController isEqualToString:@"vc"]) {
            *viewController = @"ViewController1";
        }
        return YES;
    }];
    
    [[YFMediator shared] intercept:YFMediatorInterceptNotFound handler:^BOOL(id *viewController, NSMutableDictionary *params) {
        *viewController = @"ViewController5";
        return YES;
    }];
    
    [[YFMediator shared] intercept:YFMediatorInterceptBeforeSetValue handler:^BOOL(__autoreleasing id *viewController, NSMutableDictionary *params) {
        if (params[@"params1"]) {
            params[@"params1"] = [NSString stringWithFormat:@"hook_%@", params[@"params1"]];
        }
        return YES;
    }];
    
    [[YFMediator shared] intercept:YFMediatorInterceptAfterInit handler:^BOOL(id *viewController, NSMutableDictionary *params) {
        UIViewController *vc = *viewController;
        vc.view.backgroundColor = [UIColor colorWithRed:random() % 255 / 255.0 green:random() % 255 / 255.0 blue:random() % 255 / 255.0 alpha:1];
        
        vc.title = NSStringFromClass(vc.class);
        return YES;
    }];
    
}

@end
