//
//  YFMediator+YFRouter.h
//  YFMediatorDemo
//
//  Created by laizw on 2017/9/20.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFMediator+Core.h"

#if __has_include(<YFRouter/YFRouter.h>)
#import <YFRouter/YFRouter.h>
#endif

#ifdef YFRouterDomain
@interface YFMediator (YFRouter)

/**
 URL 和 ViewController 的映射
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *controllers;

/**
 绑定 ViewController 和 URL
 eg. [YFMediator mapURL:@"login" toViewController:LoginViewController];
 [YFMediator push:@"login?user=laizw&password=123123"];
 
 @param url 短链
 @param viewController ViewController
 */
- (void)mapURL:(NSString *)url toViewController:(NSString *)viewController;

/**
 eg.
 @{
     @"user/info" : @"UserInfoViewController",
     @"login"     : @"LoginViewController"
     ...
 }
 
 @param mapping mapping
 */
- (void)addMapping:(NSDictionary *)mapping;

/**
 删除短链
 
 @param url 短链
 */
- (void)removeURL:(NSString *)url;

@end
#endif
