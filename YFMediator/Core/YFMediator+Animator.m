//
//  YFMediator+Animator.m
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

#import "YFMediator+Animator.h"
#import "UINavigationController+MediatorAnimator.h"

@implementation YFMediator (Animator)

- (UIViewController *)push:(NSString *)viewController params:(NSDictionary *)params animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    UIViewController *vc = [self viewController:viewController params:params];
    if (!vc) return nil;
    [[self currentNavigationController] pushViewController:vc animator:animator];
    return vc;
}

- (UIViewController *)present:(NSString *)viewController params:(NSDictionary *)params animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    return [self present:viewController animate:animator params:params withNavigation:YES];
}

- (UIViewController *)present:(NSString *)viewController params:(NSDictionary *)params animator:(id<UIViewControllerAnimatedTransitioning>)animator withNavigation:(BOOL)hasNav {
    UIViewController *vc = [self viewController:viewController params:params];
    if (!vc) return nil;
    if (hasNav) {
        vc = [[self.navigationClass alloc] initWithRootViewController:vc];
    }
    [[self currentViewController] presentViewController:vc animator:animator];
    return vc;
}

- (UIViewController *)pop:(id<UIViewControllerAnimatedTransitioning>)animator {
    UIViewController *vc = [self currentViewController];
    if (vc.navigationController) {
        if (vc.navigationController.viewControllers.count > 1) {
            return [vc.navigationController pop:animator];
        }
        vc = vc.navigationController;
    }
    if (vc.presentingViewController) {
        [vc dismissViewController:animator];
    }
    return vc;
}


@end
