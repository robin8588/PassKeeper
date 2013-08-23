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
    self.textName.tag=1;
    self.textName.placeholder = @"钥匙名称";
    self.textName.returnKeyType=UIReturnKeyNext;
    self.textName.borderStyle = UITextBorderStyleRoundedRect;
    self.textName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textName.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textName.delegate=self;
    [self.view addSubview:self.textName];
    
    textFieldRect.origin.y+=37.0f;
    self.textUserName = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textUserName.tag=2;
    self.textUserName.placeholder = @"用户名／卡号";
    self.textUserName.returnKeyType =UIReturnKeyNext;
    self.textUserName.borderStyle = UITextBorderStyleRoundedRect;
    self.textUserName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textUserName.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textUserName.delegate=self;
    [self.view addSubview:self.textUserName];
    
    textFieldRect.origin.y+=37.0f;
    self.textPassword = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textPassword.tag =3;
    self.textPassword.placeholder = @"密码";
    self.textPassword.returnKeyType =UIReturnKeyNext;
    self.textPassword.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.textPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.textPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textPassword.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textPassword.keyboardType=UIKeyboardTypeASCIICapable;
    [self.view addSubview:self.textPassword];
    self.textPassword.delegate=self;
    
    textFieldRect.origin.y+=37.0f;
    self.textNote = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textNote.placeholder = @"备注";
    self.textNote.borderStyle = UITextBorderStyleRoundedRect;
    self.textNote.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textNote.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.textNote];
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [self.textUserName becomeFirstResponder];
            break;
        case 2:
            [self.textPassword becomeFirstResponder];
            break;
        case 3:
            [self.textNote becomeFirstResponder];
            break;
        default:
            break;
    }
    return YES;
}

-(void)createNewKey:(id)sender{
    
    
    NSManagedObjectContext *managedObjectContext=[self managedObjectContext];
    if([self checkKey:self.textName.text withManageContext:managedObjectContext])
    {
        Key *newKey=[NSEntityDescription insertNewObjectForEntityForName:@"Key" inManagedObjectContext:managedObjectContext];
        
        if(newKey !=nil){
            newKey.name =self.textName.text;
            newKey.userName=self.textUserName.text;
            newKey.password=self.textPassword.text;
            newKey.note=self.textNote.text;
            //newKey.rowIndex=[NSNumber numberWithInteger:0];
            if ([newKey.userName length]==0) {
                newKey.userName=@"";
            }
            if ([newKey.password length]==0) {
                newKey.password=@"";
            }
            if ([newKey.note length]==0) {
                newKey.note=@"";
            }
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
}

-(BOOL)checkKey:(NSString*)keyName withManageContext:(NSManagedObjectContext*)managedObjectContext {
    BOOL vaild=YES;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"输入提示" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    if([keyName length]==0){
        alert.message=@"给钥匙起个名吧";
        vaild=NO;
        [alert show];
    }
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Key" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *keys=[managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([keys count]>0){
        for (Key *tofind in keys) {
            if([tofind.name isEqualToString:keyName]){
                alert.message=@"钥匙名重复了";
                vaild=NO;
                [alert show];
                break;
            }
        }
    }
    
    return vaild;
}

- (NSManagedObjectContext *) managedObjectContext{
    LEOAppDelegate *appDelegate =
    (LEOAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    return managedObjectContext;
}
@end
