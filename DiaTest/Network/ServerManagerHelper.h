//
//  ServerManagerHelper.h
//  DiaTest
//
//  Created by Alex Delin on 26/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface ServerManagerHelper : NSObject
+ (ServerManagerHelper *)sharedHelper;

- (User *)userFromResponse:(NSDictionary *)response;
- (NSArray *)postsFromResponse:(NSDictionary *)response;
- (NSArray *)commentsFromResponse:(NSDictionary *)response;
@end
