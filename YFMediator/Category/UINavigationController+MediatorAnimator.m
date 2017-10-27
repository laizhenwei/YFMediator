//
//  UINavigationController+MediatorAnimator.m
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

#import "UINavigationController+MediatorAnimator.h"
#import <objc/message.h>
#import "YFAspect.h"
#import "YFProxy.h"

@interface UINavigationController (Private)
@property (nonatomic, strong, readonly) YFProxy *yf_navigationDelegate;
- (void)resetDefaultSetting;
@end

@interface _YFNavigationDelegateHanlder : NSObject <UINavigationControllerDelegate>
@property (nonatomic, weak) UINavigationController *nav;
@end
@implementation _YFNavigationDelegateHanlder

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.nav.yf_animator = nil;
    if (self.nav.yf_navigationDelegate.receiver) {
        if ([self.nav.yf_navigationDelegate.receiver respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [self.nav.yf_navigationDelegate.receiver navigationController:navigationController didShowViewController:viewController animated:animated];
        }
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    id<UIViewControllerAnimatedTransitioning> animator;
    if (self.nav.yf_navigationDelegate.receiver) {
        if ([self.nav.yf_navigationDelegate.receiver respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
            animator = [self.nav.yf_navigationDelegate.receiver navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
        }
    }
    return animator ?: self.nav.yf_animator;
}
@end


@implementation UINavigationController (MediatorAnimator)

+ (void)load {
    [YFAspect hook:self sel:@selector(initWithRootViewController:) with:@selector(yf_nav_initWithRootViewController:)];
    [YFAspect hook:self sel:@selector(setDelegate:) with:@selector(yf_nav_setDelegate:)];
}

- (instancetype)yf_nav_initWithRootViewController:(UIViewController *)rootViewController {
    UINavigationController *nav = [self yf_nav_initWithRootViewController:rootViewController];
    [nav yf_navigationDelegate];
    return nav;
}

- (void)yf_nav_setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.yf_navigationDelegate.receiver = delegate;
    [self yf_nav_setDelegate:(id<UINavigationControllerDelegate>)self.yf_navigationDelegate];
}

#pragma mark - Public
- (void)pushViewController:(UIViewController *)viewController animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    self.yf_animator = animator;
    [self pushViewController:viewController animated:YES];
}

- (UIViewController *)pop:(id<UIViewControllerAnimatedTransitioning>)animator {
    self.yf_animator = animator;
    return [self popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (YFProxy *)yf_navigationDelegate {
    YFProxy *_proxy = objc_getAssociatedObject(self, _cmd);
    if (!_proxy) {
        _proxy = [YFProxy proxyWithMiddleman:self.yf_handler];
        objc_setAssociatedObject(self, _cmd, _proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _proxy;
}

- (_YFNavigationDelegateHanlder *)yf_handler {
    _YFNavigationDelegateHanlder *handler = objc_getAssociatedObject(self, _cmd);
    if (!handler) {
        handler = [_YFNavigationDelegateHanlder new];
        handler.nav = self;
        objc_setAssociatedObject(self, _cmd, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handler;
}
@end
