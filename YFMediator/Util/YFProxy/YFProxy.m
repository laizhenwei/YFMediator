//
//  YFProxy.m
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

#import "YFProxy.h"

@implementation YFProxy

+ (instancetype)proxyWithReceiver:(id)receiver {
    return [[YFProxy alloc] initWithReceiver:receiver];
}

- (instancetype)initWithReceiver:(id)receiver {
    if (self = [super init]) {
        self.receiver = receiver;
    }
    return self;
}

+ (instancetype)proxyWithMiddleman:(id)middleman {
    return [[YFProxy alloc] initWithMiddleman:middleman];
}

- (instancetype)initWithMiddleman:(id)middleman {
    if (self = [super init]) {
        self.middleman = middleman;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.middleman respondsToSelector:aSelector]) return self.middleman;
    if ([self.receiver respondsToSelector:aSelector]) return self.receiver;
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.middleman respondsToSelector:aSelector]) return YES;
    if ([self.receiver respondsToSelector:aSelector]) return YES;
    return [super respondsToSelector:aSelector];
}

@end
