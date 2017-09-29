//
//  UIViewController+MediatorAnimator.m
//  AFNetworking
//
//  Created by laizw on 2017/9/20.
//

#import "UIViewController+MediatorAnimator.h"
#import "YFAspect.h"
#import "YFProxy.h"

@interface UIViewController (Private)
@property (nonatomic, strong) YFProxy *transitionDelegate;
@end

@interface _UIViewControllerTransitioningDelegateHandler : NSObject <UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) UIViewController *vc;
@end
@implementation _UIViewControllerTransitioningDelegateHandler
- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.vc.animator;
}
- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.vc.animator;
}
@end

@implementation UIViewController (MediatorAnimator)

+ (void)load {
    [YFAspect hook:self sel:@selector(setTransitioningDelegate:) with:@selector(yf_animate_setTransitioningDelegate:)];
    [YFAspect hook:self sel:@selector(viewDidAppear:) with:@selector(yf_animate_viewDidAppear:)];
}

- (void)yf_animate_viewDidAppear:(BOOL)animated {
    NSLog(@"top viewController : %@", [self class]);
    [self yf_animate_viewDidAppear:animated];
}

- (void)yf_animate_setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    self.transitionDelegate.middleman = transitioningDelegate;
    [self yf_animate_setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)self.transitionDelegate];
}

- (void)presentViewController:(UIViewController *)viewController animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (animator) {
        viewController.animator = animator;
        if (!viewController.transitioningDelegate) {
            viewController.transitioningDelegate = nil;
        }
    }
    [self presentViewController:viewController animated:YES completion:^{
        self.animator = nil;
    }];
}

- (void)dismissViewController:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (animator) {
        self.animator = animator;
        if (!self.transitioningDelegate) {
            self.transitioningDelegate = nil;
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        self.animator = nil;
    }];
}

#pragma mark - Getter
- (YFProxy *)transitionDelegate {
    YFProxy *_proxy = objc_getAssociatedObject(self, _cmd);
    if (!_proxy) {
        _proxy = [YFProxy proxyWithReceiver:self.transitionHandler];
        objc_setAssociatedObject(self, _cmd, _proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _proxy;
}

- (_UIViewControllerTransitioningDelegateHandler *)transitionHandler {
    _UIViewControllerTransitioningDelegateHandler *handler = objc_getAssociatedObject(self, _cmd);
    if (!handler) {
        handler = [_UIViewControllerTransitioningDelegateHandler new];
        handler.vc = self;
        objc_setAssociatedObject(self, _cmd, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handler;
}

- (void)setAnimator:(id<UIViewControllerAnimatedTransitioning>)animator {
    objc_setAssociatedObject(self, @selector(animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<UIViewControllerAnimatedTransitioning>)animator {
    return objc_getAssociatedObject(self, _cmd);
}

@end
