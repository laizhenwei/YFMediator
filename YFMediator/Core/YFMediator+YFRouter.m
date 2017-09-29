//
//  YFMediator+YFRouter.m
//  YFMediatorDemo
//
//  Created by laizw on 2017/9/20.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFMediator+YFRouter.h"

#ifdef YFRouterDomain
@implementation YFMediator (YFRouter)

@dynamic controllers;

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

