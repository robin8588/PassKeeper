//
//  KeyDetailsViewController.h
//  PassKeeper
//
//  Created by Wang Leo on 13-8-12.
//  Copyright (c) 2013年 Wang Leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KeyDetailsViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textName;
@property (nonatomic, strong) UITextField *textUserName;
@property (nonatomic, strong) UITextField *textPassword;
@property (nonatomic, strong) UITextField *textNote;
@property (nonatomic, strong) UIBarButtonItem *addButton;

@end
