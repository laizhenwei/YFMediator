//
//  BaseViewController.h
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/16.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) NSString *params1;
@property (nonatomic, strong) NSString *params2;
@property (nonatomic, strong) NSString *params3;

@property (nonatomic, strong) UITextField *vcText;
@property (nonatomic, strong) UITextField *mapText;
@property (nonatomic, strong) UITextField *popToText;
@property (nonatomic, strong) UITextField *paramText1;
@property (nonatomic, strong) UITextField *paramText2;
@property (nonatomic, strong) UITextField *paramText3;
@property (nonatomic, strong) UITextView *textView;

@end
