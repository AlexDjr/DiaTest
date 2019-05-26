//
//  User.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerObject.h"

@interface User : ServerObject
@property (strong,nonatomic) NSString *userId;
@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (assign,nonatomic) BOOL isOnline;
@property (strong,nonatomic) NSURL *photoURL50;
@property (strong,nonatomic) NSURL *photoURL200;

- (instancetype)initWithServerResponse:(NSDictionary *)response;
@end
