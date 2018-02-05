//
//  YFMediator+Core.h
//  YFMediatorDemo
//
//  Created by laizw on 2017/9/20.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFMediator+Define.h"

@interface YFMediator : NSObject

/**
 基础 UINavigationController 
 */
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
 找不到对应的控制器 YFMediatorInterceptNotFound
 创建之前 YFMediatorInterceptBeforeInit
 赋值之前 YFMediatorInterceptBeforeSetValue
 创建完成 YFMediatorInterceptAfterInit
 
 如果 ViewController 实现了 YFMediatorProtocol，那么将不会拦截 setValue
 
 @param option YFMediatorIntercept
 @param handler YFMediatorInterceptHandler
 */
- (void)intercept:(YFMediatorIntercept)option handler:(YFMediatorInterceptHandlerBlock)handler;

/**
 获取当前的控制器
 如果含有 TabBarController 或者 NavigationController 会获取他们的 ChildViewController
 
 @return viewController
 */
- (__kindof UIViewController *)currentViewController;

/**
 获取当前的 NavigationController
 如果当前的 ViewController 不含有 NavigationController 则返回 nil
 
 @return navigationController
 */
- (__kindof UINavigationController *)currentNavigationController;

/**
 通过 ViewController 的 className 或者 短链 创建 ViewController
 可传入参数，默认为 nil
 
 @param viewController viewController(className | URL)
 @return Created ViewController
 */
- (__kindof UIViewController *)viewController:(NSString *)viewController;
- (__kindof UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params;
- (__kindof UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params withNavigation:(BOOL)hasNav;

/**
 Push 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (__kindof UIViewController *)push:(NSString *)viewController;
- (__kindof UIViewController *)push:(NSString *)viewController animate:(BOOL)animate;
- (__kindof UIViewController *)push:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;

/**
 Present 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 Present 操作默认会创建一个 NavigationController 来管理需要 Present 的 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (__kindof UIViewController *)present:(NSString *)viewController;
- (__kindof UIViewController *)present:(NSString *)viewController animate:(BOOL)animate;
- (__kindof UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;
- (__kindof UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params withNavigation:(BOOL)hasNav;

/**
 Pop or Dismiss
 
 @return viewController
 */
- (__kindof UIViewController *)pop;
- (__kindof UIViewController *)popAnimate:(BOOL)animate;
- (__kindof UIViewController *)popToRoot;
- (__kindof UIViewController *)popToRootAnimate:(BOOL)animate;
- (__kindof UIViewController *)popTo:(NSString *)viewController;
- (__kindof UIViewController *)popTo:(NSString *)viewController animate:(BOOL)animate;

@end

@interface UIViewController (YFMediator)

@property (nonatomic, strong) NSDictionary *params;

@end
