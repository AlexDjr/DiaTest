//
//  Post.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerObject.h"
@class User;
@class Group;

@interface Post : ServerObject
@property (strong, nonatomic) NSString *postId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *fromId;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) NSInteger likesCount;
@property (assign, nonatomic) BOOL isLikedByUser;
@property (strong, nonatomic) NSString *canLike;
@property (strong, nonatomic) NSArray *attachment;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Group *group;
@end
