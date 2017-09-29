//
//  UINavigationController+MediatorAnimator.h
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MediatorAnimator.h"

@interface UINavigationController (MediatorAnimator) <UINavigationControllerDelegate>

- (void)pushViewController:(UIViewController *)viewController animator:(id<UIViewControllerAnimatedTransitioning>)animator;

- (UIViewController *)pop:(id<UIViewControllerAnimatedTransitioning>)animator;

@end
