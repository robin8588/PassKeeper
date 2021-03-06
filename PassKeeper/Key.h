//
//  Key.h
//  PassKeeper
//
//  Created by Wang Leo on 13-8-26.
//  Copyright (c) 2013年 Wang Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Key : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * rowIndex;
@property (nonatomic, retain) NSString * userName;

@end
