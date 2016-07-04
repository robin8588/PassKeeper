//
//  KeyListsViewController.m
//  PassKeeper
//
//  Created by Wang Leo on 13-8-12.
//  Copyright (c) 2013年 Wang Leo. All rights reserved.
//

#import "KeyListsViewController.h"
#import "KeyDetailsViewController.h"
#import "Key.h"
#import "LEOAppDelegate.h"

@interface KeyListsViewController ()
@property (nonatomic,strong) Key *pastedKey;
@property (nonatomic,strong) NSIndexPath *deleteIndexPath;

@property (nonatomic,strong) NSString *NavBarTItle;
@property (nonatomic,strong) NSString *OkButtonName;
@property (nonatomic,strong) NSString *CancelButtonName;
@property (nonatomic,strong) NSString *CopyAccount;
@property (nonatomic,strong) NSString *CopyPassword;
@property (nonatomic,strong) NSString *DeleteConfirm;
@property (nonatomic,strong) NSString *DeleteKey;
@property (nonatomic,strong) NSString *EditKey;
@end

@implementation KeyListsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSFetchRequest *fetchRequest=[[NSFetchRequest alloc]init];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"Key" inManagedObjectContext:[self managedObjectContext]];
        NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"rowIndex" ascending:YES];
        NSArray *sorters=[[NSArray alloc]initWithObjects:sorter, nil];
        fetchRequest.sortDescriptors=sorters;
        [fetchRequest setEntity:entity];
        
        self.keyFetchResultController =[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        self.keyFetchResultController.delegate=self;
        NSError *error=nil;
        if([self.keyFetchResultController performFetch:&error]){
            
        }else{
            NSLog(@"FecthError: %@",error);
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLanguageString];
    
    self.keysTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.keysTable.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.keysTable.delegate=self;
    self.keysTable.dataSource=self;
    [self.view addSubview:self.keysTable];
    
    self.topButtons=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewKey:)];
    [self.navigationItem setLeftBarButtonItem:[self editButtonItem] animated:NO];
    [self.navigationItem setRightBarButtonItem:self.topButtons animated:NO];
    
    self.title=self.NavBarTItle;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    if(editing){
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }else{
        [self.navigationItem setRightBarButtonItem:self.topButtons];
    }
    
    [self.keysTable setEditing:editing animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo=[self.keyFetchResultController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *result=nil;
    static  NSString *KeyTableViewCell=@"KeyTableViewCell";
    result=[tableView dequeueReusableCellWithIdentifier:KeyTableViewCell];
    
    if(result == nil){
        result=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KeyTableViewCell];
        result.selectionStyle=UITableViewCellSelectionStyleBlue;
        result.showsReorderControl=YES;
    }
    
    Key *key=[self.keyFetchResultController objectAtIndexPath:indexPath];
    result.textLabel.text=key.name;
    NSLog(@"rowtext:%@ rowindex:%ld",[key name],(long)[key.rowIndex integerValue]);
    return result;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:self.DeleteConfirm delegate:self cancelButtonTitle:self.CancelButtonName otherButtonTitles:self.DeleteKey, nil];
    self.deleteIndexPath=indexPath;
    [alert show];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"from:%ld to:%ld",(long)[sourceIndexPath row],(long)[destinationIndexPath row]);
    
    Key *movekey= [[self keyFetchResultController] objectAtIndexPath:sourceIndexPath];
    [movekey setRowIndex:[NSNumber numberWithInteger:[destinationIndexPath row]]];
    NSLog(@"move:%@ to:%ld",[movekey name],(long)[movekey.rowIndex integerValue]);
    
    if(destinationIndexPath.row>sourceIndexPath.row){
        for (NSInteger i=sourceIndexPath.row+1; i<=destinationIndexPath.row; i++) {
            Key *key=[self.keyFetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [key setRowIndex:[NSNumber numberWithInteger:i-1]];
            NSLog(@"change:%@ to:%ld",[key name],(long)[key.rowIndex integerValue]);
        }
    }else{
        for (NSInteger i=destinationIndexPath.row; i<sourceIndexPath.row; i++) {
            Key *key=[self.keyFetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [key setRowIndex:[NSNumber numberWithInteger:i+1]];
            NSLog(@"change:%@ to:%ld",[key name],(long)[key.rowIndex integerValue]);
        }
    }
    
    NSError *error=nil;
    if([[self managedObjectContext] save:&error]){
        NSLog(@"SaveReorderChange");
        for (NSInteger i=0; i<[[self keysTable] numberOfRowsInSection:0]; i++) {
            Key *key=[self.keyFetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [key setRowIndex:[NSNumber numberWithInteger:i]];
            NSLog(@"confirm:%@ inrow:%ld",[key name],(long)[key.rowIndex integerValue]);
        }
        if([[self managedObjectContext] save:&error]){
        }else{
            NSLog(@"saveError: %@",error);
        }
        
    }else{
        NSLog(@"saveError: %@",error);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"controllerDidChangeFiee");
    [self.keysTable reloadData];
}


#pragma mark - UITableViewDelegate
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Key *key=[self.keyFetchResultController objectAtIndexPath:indexPath];
    self.pastedKey=key;
    
    NSString *detail=[[NSString alloc] initWithFormat:@"%@ \n%@ \n%@",key.userName,key.password,key.note ];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:key.name message:detail delegate:self cancelButtonTitle:self.OkButtonName otherButtonTitles:nil, nil];
    
    if ([key.userName length]>0) {
        [alert addButtonWithTitle:self.CopyAccount];
    }
    if ([key.password length] >0) {
        [alert addButtonWithTitle:self.CopyPassword];
    }
    
    [alert addButtonWithTitle:self.EditKey];
    
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:self.CopyAccount])
    {
        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setString:self.pastedKey.userName];
        NSLog(@"account paste");
    }else if([buttonTitle isEqualToString:self.CopyPassword]){
        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setString:self.pastedKey.password];
        NSLog(@"password paste");
    }else if([buttonTitle isEqualToString:self.DeleteKey]){
        Key *key=[self.keyFetchResultController objectAtIndexPath:self.deleteIndexPath];
        self.keyFetchResultController.delegate=nil;
        [[self managedObjectContext] deleteObject:key];
        if([key isDeleted]){
            NSError *error=nil;
            if([[self managedObjectContext] save:&error]){
                if([self.keyFetchResultController performFetch:&error]){
                    NSArray *rowsToDelete=[[NSArray alloc] initWithObjects:self.deleteIndexPath, nil];
                    [[self keysTable]deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
                }else{
                    NSLog(@"fecthError: %@",error);
                }
            }else{
                NSLog(@"saveError: %@",error);
            }
        }
        self.keyFetchResultController.delegate=self;
    }else if([buttonTitle isEqualToString:self.EditKey]){
        KeyDetailsViewController *detailController=[[KeyDetailsViewController alloc]initWithNibName:nil bundle:nil editKey:self.pastedKey];
        [self.navigationController pushViewController:detailController animated:NO];
    }
}

#pragma mark - Function
-(void) addNewKey:(id)sender{
    KeyDetailsViewController *detailController=[[KeyDetailsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:detailController animated:NO];
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
    if ([identifier isEqualToString:@"zh-Hans-CN"]) {
        self.NavBarTItle=@"钥匙链";
        self.CancelButtonName=@"取消";
        self.OkButtonName=@"知道了";
        self.CopyAccount=@"复制帐号";
        self.CopyPassword=@"复制密码";
        self.DeleteConfirm=@"确认要删除吗？";
        self.DeleteKey=@"删除钥匙";
        self.EditKey=@"修改";
    }else{
        self.NavBarTItle=@"PassKeeper";
        self.CancelButtonName=@"Cancel";
        self.OkButtonName=@"OK";
        self.CopyAccount=@"Copy AccountName";
        self.CopyPassword=@"Copy Password";
        self.DeleteConfirm=@"Delete This Key?";
        self.DeleteKey=@"DeleteKey";
        self.EditKey=@"Edit";
    }
}
@end
