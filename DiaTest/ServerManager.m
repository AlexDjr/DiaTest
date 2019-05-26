//
//  ServerManager.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking.h>
#import "LoginViewController.h"
#import "AccessToken.h"
#import "ServerManagerHelper.h"

#import "User.h"
#import "Post.h"
#import "Group.h"
#import "Comment.h"


@interface ServerManager()
@property (strong, nonatomic) AFHTTPSessionManager *reguestManager;
@property (strong, nonatomic) AccessToken *accessToken;
@property (strong, nonatomic) ServerManagerHelper *helper;
@end

@implementation ServerManager
+ (ServerManager*)sharedManager {
    static ServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ServerManager new];
    });
    return manager;
}

- (void)authorizeUserWithToken:(AccessToken *)token andCompletion:(void(^)(User *user))completion {
    self.accessToken = token;
    if (token) {
        [self obtainUser:self.accessToken.userId
            onSuccess:^(User *user) {
                if (completion) {
                    completion(user);
                }
            } onFailure:^(NSError *error, NSInteger statusCode) {
                if (completion) {
                    completion(nil);
                }
            }];
    } else if (completion) {
        completion(nil);
    }
}

- (void)logoutWithCompletion:(void(^)(void))completion {
    [self clearCookies];
    [self sendLogoutRequestWithCompletion:completion];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRequestManager];
        [self setupHelper];
    }
    return self;
}

#pragma mark - API methods
- (void)obtainUser:(NSString *)userID
         onSuccess:(void(^)(User *user))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,                                     @"user_ids",
                            @"id,photo_50,photo_200,bdate,city,online", @"fields",
                            @"nom",                                     @"name_case",
                            self.accessToken.token,                     @"access_token",
                            @"5.95",                                    @"v",  nil];
    
    [self.reguestManager GET:@"users.get"
                  parameters:params
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * response) {
                         User *user = [self.helper userFromResponse:response];
                         if (user) {
                             if (success) {
                                 success(user);
                             }
                         } else {
                             [self sendError:nil withTask:task onFailure:failure];
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self sendError:error withTask:task onFailure:failure];
                     }];
}

- (void)obtainWall:(NSString *)ownerID
              type:(NSString *)wallType
         wthOffset:(NSInteger)offset
             count:(NSInteger)count
         onSuccess:(void(^)(NSArray *posts))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ownerID,                @"owner_id",
                            @(count),               @"count",
                            @(offset),              @"offset",
                            @"1",                   @"extended",
                            self.accessToken.token, @"access_token",
                            @"5.95",                @"v",  nil];
    
    [self.reguestManager GET:@"wall.get"
                  parameters:params
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * response) {
                         NSArray *posts = [self.helper postsFromResponse:response];
                         if (success) {
                             success(posts);
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self sendError:error withTask:task onFailure:failure];
                     }];
}

- (void)obtainCommentsFromPost:(NSString *)postID
                        onWall:(NSString *)ownerID
                          type:(NSString *)wallType
                     wthOffset:(NSInteger)offset
                         count:(NSInteger)count
                     onSuccess:(void(^)(NSArray *comments))success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ownerID,                @"owner_id",
                            postID,                 @"post_id",
                            @(count),               @"count",
                            @(offset),              @"offset",
                            @"1",                   @"need_likes",
                            @"1",                   @"extended",
                            self.accessToken.token, @"access_token",
                            @"5.95",                @"v",  nil];
    
    [self.reguestManager GET:@"wall.getComments"
                  parameters:params
                     success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * response) {
                         NSArray *comments = [self.helper commentsFromResponse:response];
                         if (success) {
                             success(comments);
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [self sendError:error withTask:task onFailure:failure];
                     }];
}

- (void)postLikeOn:(NSString *)contentType
            withID:(NSString *)itemID
            onWall:(NSString *)ownerID
              type:(NSString *)wallType
         onSuccess:(void(^)(id result))success
         onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            contentType,            @"type",
                            ownerID,                @"owner_id",
                            itemID,                 @"item_id",
                            self.accessToken.token, @"access_token",
                            @"5.95",                @"v",  nil];
    
    [self.reguestManager POST:@"likes.add"
                   parameters:params
                      success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * response) {
                          if (success) {
                              success(response);
                          }
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          [self sendError:error withTask:task onFailure:failure];
                      }];
}

- (void)deleteLikeFrom:(NSString *)contentType
                withID:(NSString *)itemID
                onWall:(NSString *)ownerID
                  type:(NSString *)wallType
             onSuccess:(void(^)(id result))success
             onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            contentType,            @"type",
                            ownerID,                @"owner_id",
                            itemID,                 @"item_id",
                            self.accessToken.token, @"access_token",
                            @"5.95",                @"v",  nil];
    
    [self.reguestManager POST:@"likes.delete"
                   parameters:params
                      success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * response) {
                          if (success) {
                              success(response);
                          }
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          [self sendError:error withTask:task onFailure:failure];
                      }];
}

#pragma mark -  Methods
- (void)clearCookies {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"vk.com"];
        
        if(domainRange.length > 0) {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)sendLogoutRequestWithCompletion:(void (^)(void))completion {
    NSString *urlString = [NSString stringWithFormat: @"https://api.vk.com/oauth/logout"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    [manager GET:urlString
      parameters:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull response) {
             completion();
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             completion();
         }];
}

- (void)setupRequestManager {
    NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
    self.reguestManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
}

- (ServerManagerHelper *)setupHelper {
    return self.helper = [ServerManagerHelper sharedHelper];
}

- (void)sendError:(NSError *)error withTask:(NSURLSessionDataTask * _Nullable)task onFailure:(void (^)(NSError *, NSInteger))failure {
    if (failure) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        failure(error, response.statusCode);
    }
}
@end


