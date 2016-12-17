//
//  YFMediator.h
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/14.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^YFMediatorInterceptHandlerBlock)(id viewController, NSMutableDictionary *params);

@protocol YFMediatorProtocol <NSObject>

/**
 实现这个方法可以自定义创建 ViewController
 实现这个方法不会触发 YFMediatorInterceptBeforeSetValue 拦截

 @param params 传入的参数
 @return 返回的 ViewController
 */
- (instancetype)initWithParams:(NSDictionary *)params;

@end

typedef enum : NSUInteger {
    YFMediatorInterceptBeforeInit,      // handler(className, params)
    YFMediatorInterceptBeforeSetValue,  // handler(viewController, params)，不会拦截实现 YFMediatorProtocol 的 ViewController
    YFMediatorInterceptAfterInit,       // handler(viewController, params)
} YFMediatorIntercept;

@interface YFMediator : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *controllers;
@property (nonatomic, assign, readonly) Class navigationClass;

/**
 获取一个 YFMediator 单例

 @return Mediator 单例
 */
+ (instancetype)shared;

/**
 注册一个 NavigationController 基类
 Mediator 创建的所有 NavigationController 都是这个类的实例

 @param navigationClass navigationController
 */
- (void)registerNavigationController:(Class)navigationClass;

/**
 拦截操作，在 Mediator 创建 ViewController 的时候触发
 创建之前 YFMediatorInterceptBeforeInit
 赋值之前 YFMediatorInterceptBeforeSetValue
 创建完成 YFMediatorInterceptAfterInit
 
 如果 ViewController 实现了 YFMediatorProtocol，那么将不会拦截 setValue

 @param option YFMediatorIntercept
 @param handler YFMediatorInterceptHandler
 */
- (void)intercept:(YFMediatorIntercept)option handler:(YFMediatorInterceptHandlerBlock)handler;

/**
 绑定 ViewController 和 短链
 短链是一种 Key 的形式
 eg. [YFMediator mapURL:@"login" toViewController:LoginViewController];
 如果需要使用 URL 传参数
 eg. /login?name=123&pwd=123 这种形式请结合使用 [YFRouter](https://github.com/laichanwai/YFRouter)

 @param url 短链
 @param viewController ViewController
 */
- (void)mapURL:(NSString *)url toViewController:(NSString *)viewController;

/**
  eg. @{
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

/**
 获取当前的控制器
 如果含有 TabBarController 或者 NavigationController 会获取他们的 ChildViewController

 @return viewController
 */
- (UIViewController *)currentViewController;

/**
 获取当前的 NavigationController
 如果当前的 ViewController 不含有 NavigationController 则返回 nil
 
 @return navigationController
 */
- (UINavigationController *)currentNavigationController;

/**
 通过 ViewController 的 className 或者 短链 创建 ViewController
 可传入参数，默认为 nil

 @param viewController viewController(className | URL)
 @return Created ViewController
 */
- (UIViewController *)viewController:(NSString *)viewController;
- (UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params;

/**
 Push 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (UIViewController *)push:(NSString *)viewController;
- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate;
- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;

/**
 Present 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 Present 操作默认会创建一个 NavigationController 来管理需要 Present 的 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (UIViewController *)present:(NSString *)viewController;
- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate;
- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;

/**
 Pop or Dismiss

 @return viewController
 */
- (UIViewController *)pop;
- (UIViewController *)popAnimate:(BOOL)animate;
- (UIViewController *)popToRoot;
- (UIViewController *)popToRootAnimate:(BOOL)animate;
- (UIViewController *)popTo:(NSString *)viewController;
- (UIViewController *)popTo:(NSString *)viewController animate:(BOOL)animate;

@end

@interface UIViewController (YFMediator)

@property (nonatomic, strong) NSDictionary *params;

@end
