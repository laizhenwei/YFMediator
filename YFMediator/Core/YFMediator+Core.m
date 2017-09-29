//
//  YFMediator+Core.m
//  YFMediatorDemo
//
//  Created by laizw on 2017/9/20.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFMediator+Core.h"
#import <objc/message.h>

#define YFMediatorInterceptBinding(__option__) \
        if (option == __option__) self.intercepts[@#__option__] = handler;

#define YFMediatorInterceptOperation(__option__, __vc__) \
        if (self.intercepts[@#__option__]) { \
            YFMediatorInterceptHandlerBlock handler = self.intercepts[@#__option__]; \
            BOOL flag = handler(&__vc__, newParams); \
            if (!flag) return nil; \
        }

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
    
    YFMediatorInterceptBinding(YFMediatorInterceptNotFound)
    YFMediatorInterceptBinding(YFMediatorInterceptBeforeInit)
    YFMediatorInterceptBinding(YFMediatorInterceptBeforeSetValue)
    YFMediatorInterceptBinding(YFMediatorInterceptAfterInit)
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
    if (viewController.length <= 0) return nil;
    
    NSMutableDictionary *newParams = (params ?: @{}).mutableCopy;
    YFMediatorInterceptOperation(YFMediatorInterceptBeforeInit, viewController)

    Class clazz = [self obtainClassFromString:viewController params:newParams];
    if (!clazz) return nil;
    
    id vc;
    if ([clazz instancesRespondToSelector:@selector(initWithParams:)]) {
        vc = [[clazz alloc] initWithParams:[newParams copy]];
    } else {
        vc = [self buildViewController:clazz params:newParams];
    }
    
    YFMediatorInterceptOperation(YFMediatorInterceptAfterInit, vc)
    return vc;
}

- (Class)obtainClassFromString:(NSString *)viewController params:(NSMutableDictionary *)newParams {
    Class clazz;
    BOOL try = YES;
    do {
        clazz = NSClassFromString(viewController);
        if (clazz) break;
        
#ifdef YFRouterDomain
        YFTuple *tuple = [YFRouter objectForRoute:viewController params:nil];
        NSString *newClass = tuple.first;
        clazz = NSClassFromString(newClass);
        if (clazz) {
            [newParams addEntriesFromDictionary:tuple.second];
            [newParams removeObjectsForKeys:@[YFRouterPathKey, YFRouterSchemeKey, YFRouterURLKey]];
            break;
        }
#endif
        
        if (try && self.intercepts[@"YFMediatorInterceptNotFound"]) {
            YFMediatorInterceptOperation(YFMediatorInterceptNotFound, viewController)
            try = NO;
        } else {
            return nil;
        }
    } while (1);
    return clazz;
}

- (UIViewController *)buildViewController:(Class)clazz params:(NSMutableDictionary *)newParams {
    id vc = [[clazz alloc] init];
    if (newParams && [vc respondsToSelector:@selector(setParams:)]) {
        YFMediatorInterceptOperation(YFMediatorInterceptBeforeSetValue, vc)
        [vc setParams:[newParams copy]];
        for (NSString *key in newParams) {
            NSString *setter = [NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
            if ([vc respondsToSelector:NSSelectorFromString(setter)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [vc performSelector:NSSelectorFromString(setter) withObject:newParams[key]];
#pragma clang diagnostic pop
            } else {
                objc_property_t p = class_getProperty(clazz, [[NSString stringWithFormat:@"%@", key] UTF8String]);
                if (p != NULL) {
                    char *setterAttr = property_copyAttributeValue(p, "S");
                    if (setterAttr != NULL) {
                        setter = [NSString stringWithUTF8String:setterAttr];
                        if ([vc respondsToSelector:NSSelectorFromString(setter)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [vc performSelector:NSSelectorFromString(setter) withObject:newParams[key]];
#pragma clang diagnostic pop
                        }
                    }
                }
            }
        }
    }
    return vc;
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
    return [self present:viewController animate:animate params:params withNavigation:YES];
}

- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params withNavigation:(BOOL)hasNav {
    UIViewController *vc = [self viewController:viewController params:params];
    if (!vc) return nil;
    if (hasNav) {
        vc = [[self.navigationClass alloc] initWithRootViewController:vc];
    }
    [[self currentViewController] presentViewController:vc animated:animate completion:nil];
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
        if ([subVC isMemberOfClass:NSClassFromString(class)]) {
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

@implementation UIViewController (YFMediator)

- (NSDictionary *)params {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setParams:(NSDictionary *)params {
    objc_setAssociatedObject(self, @selector(params), params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
