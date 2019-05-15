//
//  Group.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject
@property (strong,nonatomic) NSString *groupId;
@property (strong,nonatomic) NSString *desc;
@property (strong,nonatomic) NSString *activity;
@property (strong,nonatomic) NSString *name;
@property (assign,nonatomic) BOOL isClosed;
@property (assign,nonatomic) BOOL isMember;
@property (strong,nonatomic) NSURL *photoURL50;
@property (strong,nonatomic) NSURL *photoURL200;
@property (strong,nonatomic) NSString *membersCount;
@property (strong,nonatomic) NSString *status;

- (instancetype)initWithServerResponse:(NSDictionary *) responseObject;

@end
