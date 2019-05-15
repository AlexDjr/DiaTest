//
//  UserViewController.h
//  DiaTest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : UITableViewController
@property (strong, nonatomic) User *user;
@end

NS_ASSUME_NONNULL_END

