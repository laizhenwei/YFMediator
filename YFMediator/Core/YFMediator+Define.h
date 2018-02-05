//
//  YFMediator+Define.h
//  Pods
//
//  Created by laizw on 2017/9/21.
//

#import <UIKit/UIKit.h>

typedef BOOL(^YFMediatorInterceptHandlerBlock)(id *viewController, NSMutableDictionary *params);

/**
 自定义创建 ViewController
 
 - 支持多种方式创建（优先级排序）:
    + viewControllerWithParams:
    - initWithParams:
    + nibName
    + storyboard
 
 - viewControllerWithParams: 和 initWithParams: 不会触发 YFMediatorInterceptBeforeSetValue 拦截
 */
@protocol YFMediatorProtocol <NSObject>

@optional

/**
 自定义创建 ViewController，优先级最高
 
 @param params 传入的参数
 @return 返回的 ViewController
 */
+ (instancetype)viewControllerWithParams:(NSDictionary *)params;

/**
 实现这个方法可以自定义创建 ViewController
 
 @param params 传入的参数
 @return 返回的 ViewController
 */
- (instancetype)initWithParams:(NSDictionary *)params;

/**
  指定 xib 创建 ViewController

 @return xib 名称
 */
+ (NSString *)nibName;

/**
 指定 storyboard 创建 ViewController

 @return storyboard 名称
 */
+ (NSString *)storyboardName;

/**
 指定 bundle 加载 xib / storyboard

 @return bundle
 */
+ (NSBundle *)customBundle;

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

