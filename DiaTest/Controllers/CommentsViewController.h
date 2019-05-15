//
//  CommentsViewController.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Post;
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface CommentsViewController : UITableViewController
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) User *user;
@end

NS_ASSUME_NONNULL_END
