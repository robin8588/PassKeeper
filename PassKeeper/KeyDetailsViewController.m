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
@property (nonatomic,strong) NSString *NavBarTItle;
@property (nonatomic,strong) NSString *KeyNameText;
@property (nonatomic,strong) NSString *AccountNameText;
@property (nonatomic,strong) NSString *PasswordText;
@property (nonatomic,strong) NSString *NoteText;
@property (nonatomic,strong) NSString *AlertTitle;
@property (nonatomic,strong) NSString *AlertMsgNoKeyName;
@property (nonatomic,strong) NSString *AlertMsgKeyNameExist;
@property (nonatomic,strong) NSString *CancelButtonName;
@property (nonatomic,strong) NSString *NavBarTitleEdit;
@property (nonatomic,strong) Key *key;
@end

@implementation KeyDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.key=nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil editKey:(Key *)key
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.key=key;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLanguageString];
    
    self.title  = self.NavBarTItle;
    
    CGRect textFieldRect=CGRectMake(20.0f, 20.0f, self.view.bounds.size.width-40.0f,31.0f);
    
    self.textName = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textName.tag=1;
    self.textName.placeholder = self.KeyNameText;
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
    self.textUserName.placeholder = self.AccountNameText;
    self.textUserName.returnKeyType =UIReturnKeyNext;
    self.textUserName.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.textUserName.borderStyle = UITextBorderStyleRoundedRect;
    self.textUserName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textUserName.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textUserName.keyboardType=UIKeyboardTypeAlphabet;
    self.textUserName.delegate=self;
    [self.view addSubview:self.textUserName];
    
    textFieldRect.origin.y+=37.0f;
    self.textPassword = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textPassword.tag =3;
    self.textPassword.placeholder = self.PasswordText;
    self.textPassword.returnKeyType =UIReturnKeyNext;
    self.textPassword.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.textPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.textPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textPassword.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    self.textPassword.keyboardType=UIKeyboardTypeASCIICapable;
    self.textPassword.delegate=self;
    [self.view addSubview:self.textPassword];
    
    textFieldRect.origin.y+=37.0f;
    self.textNote = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textNote.placeholder = self.NoteText;
    self.textNote.borderStyle = UITextBorderStyleRoundedRect;
    self.textNote.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textNote.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.textNote];
    
    self.addButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(createNewKey:)];
    [self.navigationItem setRightBarButtonItem:self.addButton animated:NO];
    
	// Do any additional setup after loading the view.
    if(self.key){
        self.title=self.NavBarTitleEdit;
        self.textName.text=self.key.name;
        self.textUserName.text=self.key.userName;
        self.textPassword.text=self.key.password;
        self.textNote.text=self.key.note;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textName becomeFirstResponder];
    if(self.key){
        [self.textName setEnabled:NO];
        [self.textUserName becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
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

#pragma mark - Function
-(void)createNewKey:(id)sender{
    NSManagedObjectContext *managedObjectContext=[self managedObjectContext];
    
    if(self.key){
        self.key.userName=self.textUserName.text;
        self.key.password=self.textPassword.text;
        self.key.note=self.textNote.text;
        
        NSError *error=nil;
        
        if([managedObjectContext save:&error]){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSLog(@"error : %@",error);
        }
    }else{
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
}

-(BOOL)checkKey:(NSString*)keyName withManageContext:(NSManagedObjectContext*)managedObjectContext {
    BOOL vaild=YES;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:self.AlertTitle message:nil delegate:nil cancelButtonTitle:self.CancelButtonName otherButtonTitles:nil, nil];
    if([keyName length]==0){
        alert.message=self.AlertMsgNoKeyName;
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
                alert.message=self.AlertMsgKeyNameExist;
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

-(void)initLanguageString{
    NSString *identifier =[[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"languageID:%@",identifier);
    if ([identifier isEqualToString:@"zh-Hans"]) {
        self.NavBarTItle=@"新钥匙";
        self.KeyNameText=@"钥匙名";
        self.AccountNameText=@"账户名（卡号／用户名）";
        self.PasswordText=@"密码";
        self.NoteText=@"备注";
        self.AlertTitle=@"";
        self.AlertMsgNoKeyName=@"给钥匙起个名吧";
        self.AlertMsgKeyNameExist=@"钥匙名重复了";
        self.CancelButtonName=@"知道了";
        self.NavBarTitleEdit=@"编辑钥匙";
    }else{
        self.NavBarTItle=@"New Key";
        self.KeyNameText=@"Key Name";
        self.AccountNameText=@"AccountName(Card No. ,etc.)";
        self.PasswordText=@"Password";
        self.NoteText=@"Note";
        self.AlertTitle=@"";
        self.AlertMsgNoKeyName=@"Please Name This Key";
        self.AlertMsgKeyNameExist=@"Key Name Already Exist";
        self.CancelButtonName=@"OK";
        self.NavBarTitleEdit=@"EditKey";
    }
}
@end
