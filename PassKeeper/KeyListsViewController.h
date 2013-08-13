//
//  KeyListsViewController.h
//  PassKeeper
//
//  Created by Wang Leo on 13-8-12.
//  Copyright (c) 2013年 Wang Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyListsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *keysTable;
@property  (nonatomic,strong)UIBarButtonItem *topButtons;
@property (nonatomic,strong) NSFetchedResultsController *keyFetchResultController;

@end
