//
//  KeyDetailsViewController.m
//  PassKeeper
//
//  Created by Wang Leo on 13-8-12.
//  Copyright (c) 2013年 Wang Leo. All rights reserved.
//

#import "KeyDetailsViewController.h"
#import "LEOAppDelegate.h"
#import "Key.h"

@interface KeyDetailsViewController ()

@end

@implementation KeyDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title  =@"新钥匙";
    CGRect textFieldRect=CGRectMake(20.0f, 20.0f, self.view.bounds.size.width-40.0f,31.0f);
    
    self.textName = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textName.placeholder = @"钥匙名称";
    self.textName.borderStyle = UITextBorderStyleRoundedRect;
    self.textName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textName.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.textName];
    
    textFieldRect.origin.y+=37.0f;
    self.textUserName = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textUserName.placeholder = @"用户名／卡号";
    self.textUserName.borderStyle = UITextBorderStyleRoundedRect;
    self.textUserName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textUserName.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.textUserName];
    
    textFieldRect.origin.y+=37.0f;
    self.textPassword = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textPassword.placeholder = @"密码";
    self.textPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.textPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textPassword.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textPassword.keyboardType=UIKeyboardTypeASCIICapable;
    [self.view addSubview:self.textPassword];
    
    textFieldRect.origin.y+=37.0f;
    self.textPassword = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textPassword.placeholder = @"备注";
    self.textPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.textPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textPassword.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.textPassword];
    
    self.addButton=[[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(createNewKey:)];
    [self.navigationItem setRightBarButtonItem:self.addButton animated:NO];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createNewKey:(id)sender{
    LEOAppDelegate *appDelegate=(LEOAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSManagedObjectContext *managedObjectContext=appDelegate.managedObjectContext;
    
    Key *newKey=[NSEntityDescription insertNewObjectForEntityForName:@"Key" inManagedObjectContext:managedObjectContext];
    
    if(newKey !=nil){
        newKey.name =self.textName.text;
        newKey.userName=self.textUserName.text;
        newKey.password=self.textPassword.text;
        newKey.note=self.textNote.text;
        
        NSError *error=nil;
        
        if([managedObjectContext save:&error]){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSLog(@"error : %@",error);
        }
    }else{
        NSLog(@"Create New Key Error");
    }
}
@end
