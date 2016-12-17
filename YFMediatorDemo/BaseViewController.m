//
//  BaseViewController.m
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/16.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import "BaseViewController.h"
#import "YFMediator.h"
#import "YFNavigationController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.vcText = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.view.bounds.size.width - 20, 40)];
    self.vcText.placeholder = @"填写 ViewController 或者注册的 URL";
    self.vcText.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.vcText];
    
    UITextField *text1 = [[UITextField alloc] initWithFrame:CGRectMake(120, 150, 300, 40)];
    text1.text = self.params1;
    text1.placeholder = @"参数: params1";
    text1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:text1];
    self.paramText1 = text1;
    
    UITextField *text2 = [[UITextField alloc] initWithFrame:CGRectMake(120, 200, 300, 40)];
    text2.text = self.params2;
    text2.placeholder = @"参数: params2";
    text2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:text2];
    self.paramText2 = text2;
    
    UITextField *text3 = [[UITextField alloc] initWithFrame:CGRectMake(120, 250, 300, 40)];
    text3.text = self.params3;
    text3.placeholder = @"参数: params3";
    text3.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:text3];
    self.paramText3 = text3;
    
    UITextField *text4 = [[UITextField alloc] initWithFrame:CGRectMake(120, 300, 300, 40)];
    text4.placeholder = @"PopTo: (不填写则 PopToRoot)";
    text4.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:text4];
    self.popToText = text4;
    
    self.mapText = [[UITextField alloc] initWithFrame:CGRectMake(120, 350, 300, 40)];
    self.mapText.placeholder = @"map URL to this ViewController";
    self.mapText.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.mapText];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 500, self.view.bounds.size.width - 40, 300)];
    [self.view addSubview:textView];
    self.textView = textView;
    [self reloadText];
    
    UIButton *push = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, 80, 40)];
    push.backgroundColor = [UIColor lightGrayColor];
    [push setTitle:@"push" forState:UIControlStateNormal];
    [push addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:push];
    
    UIButton *present = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, 80, 40)];
    present.backgroundColor = [UIColor lightGrayColor];
    [present setTitle:@"present" forState:UIControlStateNormal];
    [present addTarget:self action:@selector(present) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:present];
    
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, 80, 40)];
    dismiss.backgroundColor = [UIColor lightGrayColor];
    [dismiss setTitle:@"pop" forState:UIControlStateNormal];
    [dismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismiss];
    
    UIButton *popTo = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 80, 40)];
    popTo.backgroundColor = [UIColor lightGrayColor];
    [popTo setTitle:@"popTo" forState:UIControlStateNormal];
    [popTo addTarget:self action:@selector(popTo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popTo];

    UIButton *map = [[UIButton alloc] initWithFrame:CGRectMake(20, 350, 80, 40)];
    map.backgroundColor = [UIColor lightGrayColor];
    [map setTitle:@"map" forState:UIControlStateNormal];
    [map addTarget:self action:@selector(map) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:map];
    
    UIButton *remove = [[UIButton alloc] initWithFrame:CGRectMake(20, 400, 80, 40)];
    remove.backgroundColor = [UIColor lightGrayColor];
    [remove setTitle:@"remove" forState:UIControlStateNormal];
    [remove addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:remove];
    
    UIButton *nav = [[UIButton alloc] initWithFrame:CGRectMake(20, 450, 300, 40)];
    nav.backgroundColor = [UIColor lightGrayColor];
    [nav setTitle:@"切换 BaseNavgationController" forState:UIControlStateNormal];
    [nav addTarget:self action:@selector(nav) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nav];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popTo {
    if (self.popToText.text.length <= 0) {
        [[YFMediator shared] popToRoot];
        return;
    }
    id vc = [[YFMediator shared] popTo:self.popToText.text];
    if (!vc) [self alert:@"ViewController 不存在"];
}

- (void)push {
    id vc = [[YFMediator shared] push:self.vcText.text animate:YES params:[self reformParams]];
    if (!vc) [self alert:@"ViewController 不存在"];
}

- (void)present {
    id vc = [[YFMediator shared] present:self.vcText.text animate:YES params:[self reformParams]];
    if (!vc) [self alert:@"ViewController 不存在"];
}

- (NSDictionary *)reformParams {
    NSMutableDictionary *params = @{}.mutableCopy;
    
    params[@"params1"] = self.paramText1.text;
    params[@"params2"] = self.paramText2.text;
    params[@"params3"] = self.paramText3.text;
    
    return params;
}

- (void)map {
    [[YFMediator shared] mapURL:self.mapText.text toViewController:NSStringFromClass(self.class)];
    [self alert:@"绑定成功"];
    [self reloadText];
}

- (void)remove {
    [[YFMediator shared] removeURL:self.mapText.text];
    [self alert:@"取消绑定成功"];
    [self reloadText];
}

- (void)dismiss {
    [[YFMediator shared] pop];
}

- (void)nav {
    static BOOL flag = YES;
    [[YFMediator shared] registerNavigationController:flag ? [YFNavigationController class] : [UINavigationController class]];
    NSString *message = [NSString stringWithFormat:@"正在使用 %@", NSStringFromClass([[YFMediator shared] navigationClass])];
    [self alert:message];
    flag = !flag;
}

- (void)reloadText {
    NSString *msg = @"Demo 含有 5 个测试控制器 ViewController 1 ~ 5 \nIntercept 操作可以到 AppDelegate 中查看\n当前 ViewController 中设置 title 就是通过 Intercept 方法来设置的\n";
    self.textView.text = [NSString stringWithFormat:@"%@\n参数列表 : \n%@ \n\n Mapping: \n%@", msg, self.params, [YFMediator shared].controllers];
}

- (void)alert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [[[YFMediator shared] currentViewController] presentViewController:alert animated:YES completion:nil];
}

@end
