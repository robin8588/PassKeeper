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

@end

@implementation KeyListsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSFetchRequest *fetchRequest=[[NSFetchRequest alloc]init];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"Key" inManagedObjectContext:[self managedObjectContext]];
        NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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
    
    self.title=@"钥匙串";
    self.keysTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.keysTable.delegate=self;
    self.keysTable.dataSource=self;
    [self.view addSubview:self.keysTable];
    
    self.topButtons=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewKey:)];
    [self.editButtonItem setTitle:@"编辑"];
    [self.navigationItem setLeftBarButtonItem:[self editButtonItem] animated:NO];
    [self.navigationItem setRightBarButtonItem:self.topButtons animated:NO];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addNewKey:(id)sender{
    KeyDetailsViewController *detailController=[[KeyDetailsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:detailController animated:YES];
}

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
        result.accessoryType=UITableViewCellAccessoryNone;
        result.editingAccessoryType=UITableViewCellAccessoryNone;
    }
    
    Key *key=[self.keyFetchResultController objectAtIndexPath:indexPath];
    
    result.textLabel.text=key.name;
    return result;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.keysTable reloadData];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    if(editing){
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.navigationItem.leftBarButtonItem setTitle:@"完成"];
    }else{
        [self.navigationItem setRightBarButtonItem:self.topButtons];
        [self.navigationItem.leftBarButtonItem setTitle:@"编辑"];
    }
    
    [self.keysTable setEditing:editing animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Key *key=[self.keyFetchResultController objectAtIndexPath:indexPath];
    self.keyFetchResultController.delegate=nil;
    [[self managedObjectContext] deleteObject:key];
    if([key isDeleted]){
        NSError *error=nil;
        if([[self managedObjectContext] save:&error]){
            if([self.keyFetchResultController performFetch:&error]){
                NSArray *rowsToDelete=[[NSArray alloc] initWithObjects:indexPath, nil];
                
                [[self keysTable]deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                NSLog(@"fecthError: %@",error);
            }
        }else{
            NSLog(@"saveError: %@",error);
        }
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Key *key=[self.keyFetchResultController objectAtIndexPath:indexPath];
    self.pastedKey=key;
    NSString *detail=[[NSString alloc] initWithFormat:@"%@  \n%@ \n%@",key.userName,key.password,key.note ];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:key.name message:detail delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复制用户名／卡号",@"复制密码", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1)
    {
        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setString:self.pastedKey.userName];
    }else if(buttonIndex ==2){
        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setString:self.pastedKey.password];
    }
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
