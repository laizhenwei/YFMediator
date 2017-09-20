//
//  YFMediator.m
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/14.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import "YFMediator.h"
#import <objc/message.h>

@interface YFMediator ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *controllers;
@property (nonatomic, assign, readwrite) Class navigationClass;
@property (nonatomic, strong) NSMutableDictionary *intercepts;
@end

@implementation YFMediator

#pragma mark - Life Circle
+ (instancetype)shared {
    static YFMediator *_instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[YFMediator alloc] init];
    });
    return _instance;
}

#pragma mark - Operation
- (void)registerNavigationController:(Class)navigationClass {
    self.navigationClass = navigationClass;
}

- (void)intercept:(YFMediatorIntercept)option handler:(YFMediatorInterceptHandlerBlock)handler {
    if (!handler) return;
    #define YFMediatorInterceptBinding(__option__) \
    if (option == __option__) self.intercepts[@#__option__] = handler;
        YFMediatorInterceptBinding(YFMediatorInterceptNotFound)
        YFMediatorInterceptBinding(YFMediatorInterceptBeforeInit)
        YFMediatorInterceptBinding(YFMediatorInterceptBeforeSetValue)
        YFMediatorInterceptBinding(YFMediatorInterceptAfterInit)
    #undef YFMediatorInterceptBinding
}

#pragma mark - 获取 viewController
- (UIViewController *)visiableController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *tmp in [UIApplication sharedApplication].windows) {
            if (tmp.windowLevel == UIWindowLevelNormal) {
                window = tmp;
                break;
            }
        }
    }
    
    UIView *front = window.subviews[0];
    id nextResponder = front.nextResponder;
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    }
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

- (UIViewController *)currentViewController {
    id vc = [self visiableController];
    if ([vc isKindOfClass:[UITabBarController class]]) vc = [(UITabBarController *)vc selectedViewController];
    if ([vc isKindOfClass:[UINavigationController class]]) vc = [(UINavigationController *)vc topViewController];
    return vc;
}

- (UINavigationController *)currentNavigationController {
    id vc = [self visiableController];
    if ([vc isKindOfClass:[UITabBarController class]]) vc = [(UITabBarController *)vc selectedViewController];
    if ([vc isKindOfClass:[UINavigationController class]]) return vc;
    return nil;
}

#pragma mark - 创建 viewController
- (UIViewController *)viewController:(NSString *)viewController {
    return [self viewController:viewController params:nil];
}

- (UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params {
    #define YFMediatorInterceptOperation(__option__, __vc__) \
    if (self.intercepts[@#__option__]) { \
        YFMediatorInterceptHandlerBlock handler = self.intercepts[@#__option__]; \
        BOOL flag = handler(&__vc__, newParams); \
        if (!flag) return nil; \
    }

    if (viewController.length <= 0) return nil;
    
    NSMutableDictionary *newParams = [params mutableCopy];
    Class clazz;
    
    YFMediatorInterceptOperation(YFMediatorInterceptBeforeInit, viewController)
    
    BOOL stop = NO;
    do {
        clazz = NSClassFromString(viewController);
        if (clazz) break;
        #ifdef YFRouterDomain
            YFObject *object = [YFRouter objectForRoute:viewController params:nil];
            NSString *newClass = object.value;
            clazz = NSClassFromString(newClass);
            if (clazz) {
                [newParams addEntriesFromDictionary:object.params];
                [newParams removeObjectsForKeys:@[YFRouterPathKey, YFRouterSchemeKey, YFRouterURLKey]];
                break;
            }
        #endif
        if (!stop && self.intercepts[@"YFMediatorInterceptNotFound"]) {
            YFMediatorInterceptOperation(YFMediatorInterceptNotFound, viewController)
            stop = YES;
        } else {
            return nil;
        }
    } while (1);
    
    id vc;
    if ([clazz instancesRespondToSelector:@selector(initWithParams:)]) {
        vc = [[clazz alloc] initWithParams:[newParams copy]];
    } else {
        vc = [[clazz alloc] init];
        if (newParams && [vc respondsToSelector:@selector(setParams:)]) {
            YFMediatorInterceptOperation(YFMediatorInterceptBeforeSetValue, vc)
            [vc setParams:[newParams copy]];
            for (NSString *key in newParams) {
                NSString *setter = [NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
                if ([vc respondsToSelector:NSSelectorFromString(setter)]) {
                    ((void (*)(id, SEL, id))objc_msgSend)(vc, NSSelectorFromString(setter), newParams[key]);
                }
            }
        }
    }
    YFMediatorInterceptOperation(YFMediatorInterceptAfterInit, vc)
    return vc;
    #undef YFMediatorInterceptOperation
}

#pragma mark - Push 跳转
- (UIViewController *)push:(NSString *)viewController {
    return [self push:viewController animate:YES];
}

- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate {
    return [self push:viewController animate:animate params:nil];
}

- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params {
    UIViewController *vc = [self viewController:viewController params:params];
    if (!vc) return nil;
    [[self currentNavigationController] pushViewController:vc animated:animate];
    return vc;
}

#pragma mark - Present 跳转
- (UIViewController *)present:(NSString *)viewController {
    return [self present:viewController animate:YES];
}

- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate {
    return [self present:viewController animate:animate params:nil];
}

- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params {
    UIViewController *vc = [self viewController:viewController params:params];
    if (!vc) return nil;
    UINavigationController *nav = [[self.navigationClass alloc] initWithRootViewController:vc];
    [[self currentNavigationController] presentViewController:nav animated:animate completion:nil];
    return vc;
}

#pragma mark - Pop or Dismiss 返回
- (UIViewController *)pop {
    return [self popAnimate:YES];
}

- (UIViewController *)popAnimate:(BOOL)animate {
    UIViewController *vc = [self currentViewController];
    if (vc.navigationController) {
        if (vc.navigationController.viewControllers.count > 1) {
            return [vc.navigationController popViewControllerAnimated:animate];
        }
        vc = vc.navigationController;
    }
    if (vc.presentingViewController) {
        [vc dismissViewControllerAnimated:animate completion:nil];
    }
    return vc;
}

- (UIViewController *)popToRoot {
    return [self popToRootAnimate:YES];
}

- (NSArray *)popToRootAnimate:(BOOL)animate {
    UINavigationController *nav = [self currentNavigationController];
    NSArray *vcs = [nav popToRootViewControllerAnimated:animate];
    return vcs;
}

- (UIViewController *)popTo:(NSString *)viewController {
    return [self popTo:viewController animate:YES];
}

- (UIViewController *)popTo:(NSString *)viewController animate:(BOOL)animate {
    if (viewController.length <= 0) return nil;
    NSString *class = self.controllers[viewController];
    if (class.length <= 0) class = viewController;
    UINavigationController *nav = [self currentNavigationController];
    for (UIViewController *subVC in nav.viewControllers) {
        if ([subVC isKindOfClass:NSClassFromString(class)]) {
            [nav popToViewController:subVC animated:animate];
            return subVC;
        }
    }
    return nil;
}

#pragma mark - Getter
- (NSMutableDictionary *)controllers {
    if (!_controllers) {
        _controllers = @{}.mutableCopy;
    }
    return _controllers;
}

- (NSMutableDictionary *)intercepts {
    if (!_intercepts) {
        _intercepts = @{}.mutableCopy;
    }
    return _intercepts;
}

- (Class)navigationClass {
    if (!_navigationClass) {
        _navigationClass = [UINavigationController class];
    }
    return _navigationClass;
}

@end

#ifdef YFRouterDomain
@implementation YFMediator (YFRouter)

- (void)mapURL:(NSString *)url toViewController:(NSString *)viewController {
    if (url.length <= 0 || viewController.length <= 0) return;
    self.controllers[url] = viewController;
    [YFRouter registerURL:url object:viewController];
}

- (void)addMapping:(NSDictionary *)mapping {
    if (!mapping) return;
    [self.controllers addEntriesFromDictionary:mapping];
    for (NSString *key in mapping) {
        [YFRouter registerURL:key object:mapping[key]];
    }
}

- (void)removeURL:(NSString *)url {
    if (self.controllers[url]) {
        [self.controllers removeObjectForKey:url];
    }
    [YFRouter unregisterURL:url];
}

@end
#endif

@implementation UIViewController (YFMediator)

static char YFMediatorParamsKey;

- (NSDictionary *)params {
    return objc_getAssociatedObject(self, &YFMediatorParamsKey);
}

- (void)setParams:(NSDictionary *)params {
    objc_setAssociatedObject(self, &YFMediatorParamsKey, params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
