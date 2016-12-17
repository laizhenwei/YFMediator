# YFMediator

[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://img.shields.io/github/license/laichanwai/YFMediator.svg) &nbsp; [![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/) &nbsp; [![CI Status](https://travis-ci.org/laichanwai/YFMediator.svg?branch=master)](https://travis-ci.org/laizw/YFMediator) &nbsp; [![Pod](https://img.shields.io/cocoapods/v/YFMediator.svg?style=flat)](https://img.shields.io/cocoapods/v/YFMediator.svg?style=flat)

**iOS 组件化的时代到临**

YFMediator iOS 组件化中间件，新时代的解耦神器 ！

强烈建议配合 [YFRouter](https://github.com/laichanwai/YFRouter) 使用 ！！

## Usage

YFMediator 封装页面常用的跳转方法，所有逻辑都是基于 UINavigationController

### 设置 NavigationController

```objc
/**
 注册一个 NavigationController 基类
 Mediator 创建的所有 NavigationController 都是这个类的实例

 @param navigationClass navigationController
 */
- (void)registerNavigationController:(Class)navigationClass;
```

### 页面跳转

![2016121772911PushOrPop.gif](http://7xlykq.com1.z0.glb.clouddn.com/2016121772911PushOrPop.gif)

#### Push

```objc
/**
 Push 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (UIViewController *)push:(NSString *)viewController;
- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate;
- (UIViewController *)push:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;
```

#### Pop Dismiss

不管你的 `ViewController` 是通过 `push` 或者 `present` 的方式弹出，调用 `pop` 都可以返回，优先处理 `pop`，如果当前 `ViewController` 已经不能 `pop` 了，则判断能否 `dismiss`

```objc
/**
 Pop or Dismiss

 @return viewController
 */
- (UIViewController *)pop;
- (UIViewController *)popAnimate:(BOOL)animate;
- (UIViewController *)popToRoot;
- (UIViewController *)popToRootAnimate:(BOOL)animate;
- (UIViewController *)popTo:(NSString *)viewController;
- (UIViewController *)popTo:(NSString *)viewController animate:(BOOL)animate;
```

#### Present

```objc
/**
 Present 一个 ViewController
 会通过 className 或者 短链 创建 ViewController
 Present 操作默认会创建一个 NavigationController 来管理需要 Present 的 ViewController
 
 @param viewController viewController(className | URL)
 @return viewController
 */
- (UIViewController *)present:(NSString *)viewController;
- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate;
- (UIViewController *)present:(NSString *)viewController animate:(BOOL)animate params:(NSDictionary *)params;
```

![201612179754params.gif](http://7xlykq.com1.z0.glb.clouddn.com/201612179754params.gif)

### 参数传递

使用 `YFRouter` 每个 `ViewController` 都会默认添加一个属性 `params`，在创建 `ViewController` 之后会把参数存在这个属性中

```
@property (nonatomic, strong) NSDictionary *params;
```

如果你传递的参数是 `ViewController` 中的一个属性，那么 `YFMediator` 会自动帮你赋值，赋值的方式是调用属性的 `set` 方法。

```objc
@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *type;

@end

// push 出来的 ViewController 的 type 值为 1
[YFMediator push:@"ViewController" params:@{@"type" : @"1"}];
``` 

![201612171222params.gif](http://7xlykq.com1.z0.glb.clouddn.com/201612171222params.gif)

### 短链映射（URL 绑定）

```objc
/**
 绑定 ViewController 和 短链
 短链是一种 Key 的形式
 eg. [YFMediator mapURL:@"login" toViewController:LoginViewController];
 如果需要使用 URL 传参数
 eg. /login?name=123&pwd=123 这种形式请结合使用 [YFRouter](https://github.com/laichanwai/YFRouter)

 @param url 短链
 @param viewController ViewController
 */
- (void)mapURL:(NSString *)url toViewController:(NSString *)viewController;

/**
  eg. @{
        @"user/info" : @"UserInfoViewController",
        @"login"     : @"LoginViewController"
        ...
      }

 @param mapping mapping
 */
- (void)addMapping:(NSDictionary *)mapping;

/**
 删除短链

 @param url 短链
 */
- (void)removeURL:(NSString *)url;
```

![2016121738971Map.gif](http://7xlykq.com1.z0.glb.clouddn.com/2016121738971Map.gif)

##### 强烈建议配合 [YFRouter](https://github.com/laichanwai/YFRouter) 使用 ！！

### 创建 ViewController

在 `YFMediator` 中所有的 `ViewController` 默认都是通过这个方法创建，它会调用 `init` 方法来创建一个 `ViewController`。

```objc
/**
 通过 ViewController 的 className 或者 短链 创建 ViewController
 可传入参数，默认为 nil

 @param viewController viewController(className | URL)
 @return Created ViewController
 */
- (UIViewController *)viewController:(NSString *)viewController;
- (UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params;
```

#### 自定义创建 ViewController

如果你的 `ViewController` 是通过 `Storyboard` 或者 `Xib` 创建的，或者你需要自定义创建一个 `ViewController`，在 `YFMediator` 有一个协议 `YFMediatorProtocol`，只需要实现协议分方法就可以。

```objc
@protocol YFMediatorProtocol <NSObject>

/**
 实现这个方法可以自定义创建 ViewController
 实现这个方法不会触发 YFMediatorInterceptBeforeSetValue 拦截

 @param params 传入的参数
 @return 返回的 ViewController
 */
- (instancetype)initWithParams:(NSDictionary *)params;

@end
```

#### ViewController 拦截器

`YFMediator` 对 `ViewController` 的创建可以进行拦截处理

1. 可以在 `Intercept Handler` 中修改 `ViewController`(创建之前传递的是 ViewController 的类名)
2. 可以在修改需要传递的参数 `params` 的类型是 `NSMutableDictionary`
3. 如果你不想创建这个 `ViewController` 只需要 `return NO`，那么就会终止创建这个 `ViewController` 并且返回 `nil`，默认通过的话请返回 `YES`。

```objc
typedef BOOL(^YFMediatorInterceptHandlerBlock)(id viewController, NSMutableDictionary *params);

typedef enum : NSUInteger {
    YFMediatorInterceptBeforeInit,      // handler(className, params)
    YFMediatorInterceptBeforeSetValue,  // handler(viewController, params)，不会拦截实现 YFMediatorProtocol 的 ViewController
    YFMediatorInterceptAfterInit,       // handler(viewController, params)
} YFMediatorIntercept;

/**
 拦截操作，在 Mediator 创建 ViewController 的时候触发
 创建之前 YFMediatorInterceptBeforeInit
 赋值之前 YFMediatorInterceptBeforeSetValue
 创建完成 YFMediatorInterceptAfterInit
 
 如果 ViewController 实现了 YFMediatorProtocol，那么将不会拦截 setValue

 @param option YFMediatorIntercept
 @param handler YFMediatorInterceptHandler
 */
- (void)intercept:(YFMediatorIntercept)option handler:(YFMediatorInterceptHandlerBlock)handler;
```

## Installation

```ruby
pod "YFMediator" :git => 'https://github.com/laichanwai/YFMediator.git'
```

## Author

laizw, i@laizw.cn

## License

YFMediator is available under the MIT license. See the LICENSE file for more info.


