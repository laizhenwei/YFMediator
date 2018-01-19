//
//  UIViewController+MediatorAnimator.m
//  AFNetworking
//
//  Created by laizw on 2017/9/20.
//

#import "UIViewController+MediatorAnimator.h"
#import "YFAspect.h"
#import "YFChainProxy.h"

@interface UIViewController (Private)
@property (nonatomic, strong) YFChainProxy *yf_transitionDelegate;
@end

@interface _UIViewControllerTransitioningDelegateHandler : NSObject <UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) UIViewController *vc;
@end
@implementation _UIViewControllerTransitioningDelegateHandler
- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.vc.yf_animator;
}
- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.vc.yf_animator;
}
@end

@implementation UIViewController (MediatorAnimator)

+ (void)load {
    [YFAspect hook:self sel:@selector(setTransitioningDelegate:) with:@selector(yf_animate_setTransitioningDelegate:)];
}

- (void)yf_animate_setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    self.yf_transitionDelegate.middleman = transitioningDelegate;
    [self yf_animate_setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)self.yf_transitionDelegate];
}

- (void)presentViewController:(UIViewController *)viewController animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (animator) {
        viewController.yf_animator = animator;
        if (!viewController.transitioningDelegate) {
            viewController.transitioningDelegate = nil;
        }
    }
    [self presentViewController:viewController animated:YES completion:^{
        self.yf_animator = nil;
    }];
}

- (void)dismissViewController:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (animator) {
        self.yf_animator = animator;
        if (!self.transitioningDelegate) {
            self.transitioningDelegate = nil;
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        self.yf_animator = nil;
    }];
}

#pragma mark - Getter
- (YFChainProxy *)yf_transitionDelegate {
    YFChainProxy *_proxy = objc_getAssociatedObject(self, _cmd);
    if (!_proxy) {
        _proxy = [YFChainProxy proxyWithReceiver:self.yf_handler];
        objc_setAssociatedObject(self, _cmd, _proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _proxy;
}

- (_UIViewControllerTransitioningDelegateHandler *)yf_handler {
    _UIViewControllerTransitioningDelegateHandler *handler = objc_getAssociatedObject(self, _cmd);
    if (!handler) {
        handler = [_UIViewControllerTransitioningDelegateHandler new];
        handler.vc = self;
        objc_setAssociatedObject(self, _cmd, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handler;
}

- (void)setYf_animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    objc_setAssociatedObject(self, @selector(yf_animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<UIViewControllerAnimatedTransitioning>)yf_animator {
    return objc_getAssociatedObject(self, _cmd);
}

@end
