//
//  YFMediator+Define.h
//  Pods
//
//  Created by laizw on 2017/9/21.
//

#import <UIKit/UIKit.h>

typedef BOOL(^YFMediatorInterceptHandlerBlock)(id *viewController, NSMutableDictionary *params);

@protocol YFMediatorProtocol <NSObject>

/**
 实现这个方法可以自定义创建 ViewController
 实现这个方法不会触发 YFMediatorInterceptBeforeSetValue 拦截
 
 @param params 传入的参数
 @return 返回的 ViewController
 */
- (instancetype)initWithParams:(NSDictionary *)params;

@end

typedef enum : NSUInteger {
    YFMediatorInterceptNotFound,        // handler(className | URL, params)
    YFMediatorInterceptBeforeInit,      // handler(className | URL, params)
    YFMediatorInterceptBeforeSetValue,  // handler(viewController, params)，不会拦截实现 YFMediatorProtocol 的 ViewController
    YFMediatorInterceptAfterInit,       // handler(viewController, params)
} YFMediatorIntercept;

#ifndef kYFMediator
#   define kYFMediator [YFMediator shared]
#endif

