//
//  UIViewController+MediatorAnimator.h
//  AFNetworking
//
//  Created by laizw on 2017/9/20.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MediatorAnimator)

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> yf_animator;

- (void)presentViewController:(UIViewController *)viewController
                     animator:(id<UIViewControllerAnimatedTransitioning>)animator;

- (void)dismissViewController:(id<UIViewControllerAnimatedTransitioning>)animator;

@end
