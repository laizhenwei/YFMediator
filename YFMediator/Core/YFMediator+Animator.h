//
//  YFMediator+Animator.h
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

#import "YFMediator+Core.h"

@interface YFMediator (Animator)

- (__kindof UIViewController *)push:(NSString *)viewController
                             params:(NSDictionary *)params
                           animator:(id<UIViewControllerAnimatedTransitioning>)animator;

- (__kindof UIViewController *)present:(NSString *)viewController
                                params:(NSDictionary *)params
                              animator:(id<UIViewControllerAnimatedTransitioning>)animator;

- (__kindof UIViewController *)present:(NSString *)viewController
                                params:(NSDictionary *)params
                              animator:(id<UIViewControllerAnimatedTransitioning>)animator
                        withNavigation:(BOOL)hasNav;

- (__kindof UIViewController *)pop:(id<UIViewControllerAnimatedTransitioning>)animator;

@end
