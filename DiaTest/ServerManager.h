//
//  ServerManager.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"

@class User;
@class Group;

@interface ServerManager : NSObject
@property (strong, nonatomic) User *currentUser;

+ (ServerManager *)sharedManager;

- (void)authorizeUserWithToken:(AccessToken *)token andCompletion:(void(^)(User *user))completion;

- (void)logoutWithCompletion:(void(^)(void))completion;

- (void)obtainWall:(NSString *)ownerID
              type:(NSString *)wallType
         wthOffset:(NSInteger)offset
             count:(NSInteger)count
         onSuccess:(void(^)(NSArray* posts))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)obtainCommentsFromPost:(NSString *)postID
                        onWall:(NSString *)ownerID
                          type:(NSString *)wallType
                     wthOffset:(NSInteger)offset
                         count:(NSInteger)count
                     onSuccess:(void(^)(NSArray *comments))success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)obtainUser:(NSString *)userID
         onSuccess:(void(^)(User *user))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure ;

- (void)postLikeOn:(NSString *)contentType
            withID:(NSString *)itemID
            onWall:(NSString *)ownerID
              type:(NSString *)wallType
         onSuccess:(void(^)(id result))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)deleteLikeFrom:(NSString *)contentType
                withID:(NSString *)itemID
                onWall:(NSString *)ownerID
                  type:(NSString *)wallType
             onSuccess:(void(^)(id result))success
             onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

@end
