# YFMediator

[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://img.shields.io/github/license/laichanwai/YFMediator.svg) &nbsp; [![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/) &nbsp; [![CI Status](https://travis-ci.org/laichanwai/YFMediator.svg?branch=master)](https://travis-ci.org/laizw/YFMediator) &nbsp; [![Pod](https://img.shields.io/cocoapods/v/YFMediator.svg?style=flat)](https://img.shields.io/cocoapods/v/YFMediator.svg?style=flat)

**iOS 组件化的时代到临**

YFMediator iOS 组件化中间件，新时代的解耦神器 ！

强烈建议配合 [YFRouter](https://github.com/laichanwai/YFRouter) 使用 ！！

## Changelog

- 0.1.4 支持自定义转场动画
- 0.1.7 初始化赋值由 `perform setter` 改为 `setValue:forKey:`
- 0.1.8 支持 `Alert` 和 `ActionSheet`
- 0.1.9 支持多种自定义初始化方式

## Usage

YFMediator 封装页面常用的跳转方法，基于 UINavigationController

### NavigationController 基类

 注册一个 NavigationController 基类
 Mediator 创建的所有 NavigationController 都是这个类的实例
 
```objc
[YFMediator shared] registerNavigationController:[BVNavigationController class]];
```

### 页面跳转

#### Push

```objc
NSString * const kYFDetailViewController = @"YFDetailViewController";

[[YFMediator shared] push:kYFDetailViewController animate:YES params:@{@"title": @"detail"}];
```

#### Present

```objc
[[YFMediator shared] present:kYFDetailViewController animate:YES params:nil withNavigation:YES];
```

#### Pop & Dismiss

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

<details>
<summary>页面跳转.gif</summary>
<img src="http://7xlykq.com1.z0.glb.clouddn.com/2016121772911PushOrPop.gif">
</details>

### 参数传递

使用 `YFRouter` 每个 `ViewController` 都会默认添加一个属性 `params`，在创建 `ViewController` 之后会把参数存在这个属性中

```
@property (nonatomic, strong) NSDictionary *params;
```

如果你传递的参数是 `ViewController` 中的一个属性，那么 `YFMediator` 会自动帮你赋值，赋值的方式是调用属性的 `set` 方法。

* 注意：如果你是自定义创建的 `ViewController`，那么 `YFMediator` 将不会给它赋值，具体见[下文](#自定义创建-viewcontroller)。

```objc
@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *type;

@end

// push 出来的 ViewController 的 type 值为 1
[[YFMediator shared] push:@"ViewController" animate:YES params:@{@"type" : @"1"}];
``` 

<details>
<summary>参数传递.gif</summary>
<img src="http://7xlykq.com1.z0.glb.clouddn.com/201612171222params.gif">
</details>


### 短链映射（URL 绑定）

*需要注意：URL 绑定功能需要 YFRouter 支持。

```objc
@interface YFMediator (YFRouter)

/**
 绑定 ViewController 和 URL
 eg. [YFMediator mapURL:@"login" toViewController:LoginViewController];
     [YFMediator push:@"login?user=laizw&password=123123"];
 
 @param url 短链
 @param viewController ViewController
 */
- (void)mapURL:(NSString *)url toViewController:(NSString *)viewController;

/**
 eg. 
 @{
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

@end
```


<details>
<summary>短链映射.gif</summary>
<img src="http://7xlykq.com1.z0.glb.clouddn.com/2016121738971Map.gif">
</details>


### 创建 ViewController

所有的 `ViewController` 默认都是通过调用 `init` 方法来创建。

```objc
- (__kindof UIViewController *)viewController:(NSString *)viewController;
- (__kindof UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params;
- (__kindof UIViewController *)viewController:(NSString *)viewController params:(NSDictionary *)params withNavigation:(BOOL)hasNav;
```

#### 自定义创建 ViewController

如果你的 `ViewController` 是通过 `Storyboard` 或者 `Xib` 创建的，或者你需要自定义创建一个 `ViewController`，在 `YFMediator` 有一个协议 `YFMediatorProtocol`，只需要实现协议对应方法就可以。

```objc
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
+ (instancetype)viewControllerWithParams:(NSDictionary *)params;
- (instancetype)initWithParams:(NSDictionary *)params;
+ (NSString *)nibName;
+ (NSString *)storyboardName;
+ (NSBundle *)customBundle;
@end
```

#### ViewController 拦截器

对 `ViewController` 的初始化进行拦截处理

1. 可以在 `Intercept Handler` 中修改 `ViewController`(创建之前传递的是 ViewController 的类名)
2. 可以在修改需要传递的参数 `params` 的类型是 `NSMutableDictionary`
3. 如果你不想创建这个 `ViewController` 只需要 `return NO`，那么就会终止创建这个 `ViewController` 并且返回 `nil`，默认通过的话请返回 `YES`。

```objc
/**
 拦截操作，在 Mediator 创建 ViewController 的时候触发
 找不到对应的控制器 YFMediatorInterceptNotFound
 创建之前 YFMediatorInterceptBeforeInit
 赋值之前 YFMediatorInterceptBeforeSetValue
 创建完成 YFMediatorInterceptAfterInit
 
 如果 ViewController 实现了 YFMediatorProtocol，那么将不会拦截 setValue

 @param option YFMediatorIntercept
 @param handler YFMediatorInterceptHandler
 */
 - (void)intercept:(YFMediatorIntercept)option handler:(YFMediatorInterceptHandlerBlock)handler;
```

#### 转场动画

0.1.4 之后，`YFMediator` 支持转场动画，这会让在开发中更加方便快捷的使用转场动画。

支持 `push`、`present`、`pop` 和 `dismiss`

```objc
// push & present
[[YFMediator shared] push:kYFDetailViewController
                   params:nil
                 animator:[YFMaterialAnimator expandAnimator]];
                 
// pop & dismiss
[[YFMediator shared] pop:[YFMaterialAnimator shrinkAnimator]];
```

#### Alert

0.1.8 之后可以快速调起一个 Alert 或者 ActionSheet。

```objc
[[YFMediator shared] alertWithTitle:@"您确定要退出当前页面吗？" items:@[@"确定"] cancel:@"取消" selected:^(UIAlertAction *action) {
    if ([action.title isEqualToString:@"确定"]) {
        [[YFMediator shared] pop];
    }
}];
```

ActionSheet

```objc
[[YFMediator shared] actionSheetWithItems:@[@"第一个", @"第二个"] cancel:@"取消" selected:^(UIAlertAction *action) {
    // ...
}];
```

## Installation

```ruby
pod "YFMediator"
```

## Author

laizw, i@laizw.cn

## License

YFMediator is available under the MIT license. See the LICENSE file for more info.


