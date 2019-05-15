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

#import "User.h"
#import "Post.h"
#import "Group.h"
#import "Comment.h"


@interface ServerManager()
@property (strong, nonatomic) AFHTTPSessionManager * reguestManager;
@property (strong, nonatomic) AccessToken *accessToken;
@end


@implementation ServerManager
+ (ServerManager*) sharedManager {
    static ServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    return manager;
}

- (void) authorizeUserWithToken:(AccessToken*) token andCompletion:(void(^)(User *user)) completion {
    self.accessToken = token;
    if (token) {
        [self getUser:self.accessToken.userId
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

- (void) logoutWithCompletion:(void(^)(void)) completion {
    //    очищаем куки
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"vk.com"];
        
        if(domainRange.length > 0) {
            [storage deleteCookie:cookie];
        }
    }
    //    делаем logout
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.vk.com/oauth/logout"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:urlString
      parameters:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
             completion();
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             completion();
         }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.reguestManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

#pragma mark - GET METHODS
- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(User* user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    AFHTTPSessionManager *manager = self.reguestManager;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,                                     @"user_ids",
                            @"id,photo_50,photo_200,bdate,city,online", @"fields",
                            @"nom",                                     @"name_case",
                            self.accessToken.token,                     @"access_token",
                            @"5.95",                                    @"v",  nil];
    
    [manager GET:@"users.get"
      parameters:params
         success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
             
             NSArray *dictsArray = [responseObject objectForKey:@"response"];
             
             if ([dictsArray count] > 0) {
                 User *user = [[User alloc] initWithServerResponse:[dictsArray firstObject]];
                 if (success) {
                     success(user);
                 }
             } else {
                 if (failure) {
                     NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
                     failure(nil, response.statusCode);
                 }
             }
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;             
             if (failure) {
                 failure(error, response.statusCode);
             }
         }];
}

- (void) getWall:(NSString*) ownerID
            type:(NSString*) wallType
       wthOffset:(NSInteger) offset
           count:(NSInteger) count
       onSuccess:(void(^)(NSArray* posts)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    [self editOwnerId:wallType];
    AFHTTPSessionManager *manager = self.reguestManager;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ownerID,      @"owner_id",
                                                                        @(count),   @"count",
                                                                        @(offset),  @"offset",
                                                                        @"1",       @"extended",
                                                                        self.accessToken.token, @"access_token",
                                                                        @"5.95",    @"v",  nil];
    
    [manager GET:@"wall.get"
      parameters:params
         success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
             
             NSDictionary *dictResponse = [responseObject objectForKey:@"response"];
             NSArray *itemsArray = [dictResponse objectForKey:@"items"];
             NSArray *profilesArray = [dictResponse objectForKey:@"profiles"];
             NSArray *groupsArray = [dictResponse objectForKey:@"groups"];
             
             NSMutableArray *objectsArray = [NSMutableArray array];
             
             NSInteger i = 0;
             for (NSDictionary* dict in itemsArray) {
                 
                 Post *post = [[Post alloc] initWithServerResponse:dict];
                 User *user = nil;

                 //    если пост от пользователя, то в массиве profilesArray будет информация о данном пользователе
                 for (NSDictionary* dictProfiles in profilesArray) {
                     if ([post.fromId isEqualToString:[[dictProfiles objectForKey:@"id"] stringValue]]) {
                         user = [[User alloc] initWithServerResponse:dictProfiles];
                     }
                 }
                 //    если пост от группы, то информация о группе будет в массиве groupsArray
                 Group *group = [[Group alloc] initWithServerResponse:groupsArray.firstObject];
                          
                 post.user = user;
                 post.group = group;
                 
                 //    получаем информацию о лайках и комментариях
                 post.likesCount = [[[dict objectForKey:@"likes"] objectForKey:@"count"] integerValue];
                 post.isLikedByUser = [[[dict objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue];
                 post.canLike = [[[dict objectForKey:@"likes"] objectForKey:@"can_like"] stringValue];
                 post.commentsCount = [[[dict objectForKey:@"comments"] objectForKey:@"count"] integerValue];
                 
                 [objectsArray addObject:post];
                 i = i + 1;
             }
             
             if (success) {
                 success(objectsArray);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
             
             if (failure) {
                 failure(error, response.statusCode);
             }
         }];
}

- (void) getCommentsFromPost:(NSString*) postID
                      onWall:(NSString*) ownerID
                        type:(NSString*) wallType
                   wthOffset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* comments)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
 
    [self editOwnerId:wallType];
    AFHTTPSessionManager *manager = self.reguestManager;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ownerID,      @"owner_id",
                                                                        postID,     @"post_id",
                                                                        @(count),   @"count",
                                                                        @(offset),  @"offset",
                                                                        @"1",       @"need_likes",
                                                                        @"1",       @"extended",
                                                                        self.accessToken.token, @"access_token",
                                                                        @"5.95",    @"v",  nil];
    
    [manager GET:@"wall.getComments"
      parameters:params
         success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
             
             NSDictionary *dictResponse = [responseObject objectForKey:@"response"];
             NSArray *itemsArray = [dictResponse objectForKey:@"items"];
             NSArray *profilesArray = [dictResponse objectForKey:@"profiles"];
             NSArray *groupsArray = [dictResponse objectForKey:@"groups"];
             
             NSMutableArray *objectsArray = [NSMutableArray array];
             
             NSInteger i = 0;
             for (NSDictionary* dict in itemsArray) {
                 
                 Comment *comment = [[Comment alloc] initWithServerResponse:dict];
                 User *user = nil;
                 
                 //    если комментарий от пользователя, то в массиве profilesArray будет информация о данном пользователе
                 for (NSDictionary* dictProfiles in profilesArray) {
                     if ([comment.fromId isEqualToString:[[dictProfiles objectForKey:@"id"] stringValue]]) {
                         user = [[User alloc] initWithServerResponse:dictProfiles];
                     }
                 }
                 //    если пост от группы, то информация о группе будет в массиве groupsArray
                 Group *group = [[Group alloc] initWithServerResponse:groupsArray.firstObject];
                 
                 comment.user = user;
                 comment.group = group;
                 
                 //    получаем информацию о лайках
                 comment.likesCount = [[[dict objectForKey:@"likes"] objectForKey:@"count"] integerValue];
                 comment.isLikedByUser = [[[dict objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue];
                 comment.canLike = [[[dict objectForKey:@"likes"] objectForKey:@"can_like"] stringValue];
                 
                 [objectsArray addObject:comment];
                 i = i + 1;
             }
             
             if (success) {
                 success(objectsArray);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
             if (failure) {
                 failure(error, response.statusCode);
             }
         }];
}


#pragma mark - POST METHODS
- (void) postLikeOn:(NSString*) contentType
             withID:(NSString*) itemID
             onWall:(NSString*) ownerID
               type:(NSString*) wallType
          onSuccess:(void(^)(id result)) success
          onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    [self editOwnerId:wallType];
    AFHTTPSessionManager *manager = self.reguestManager;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:contentType,        @"type",
                                                                        ownerID,          @"owner_id",
                                                                        itemID,           @"item_id",
                                                                        self.accessToken.token,     @"access_token",
                                                                        @"5.95",          @"v",  nil];
    
    [manager POST:@"likes.add"
       parameters:params
          success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
              if (success) {
                  success(responseObject);
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
              if (failure) {
                  failure(error, response.statusCode);
              }
          }];
}

#pragma mark DELETE METHODS
- (void) deleteLikeFrom:(NSString*) contentType
                 withID:(NSString*) itemID
                 onWall:(NSString*) ownerID
                   type:(NSString*) wallType
                  onSuccess:(void(^)(id result)) success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    [self editOwnerId:wallType];
    AFHTTPSessionManager *manager = self.reguestManager;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:contentType,        @"type",
                                                                        ownerID,          @"owner_id",
                                                                        itemID,           @"item_id",
                                                                        self.accessToken.token,     @"access_token",
                                                                        @"5.95",          @"v",  nil];
    
    [manager POST:@"likes.delete"
       parameters:params
          success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
              if (success) {
                  success(responseObject);
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
              if (failure) {
                  failure(error, response.statusCode);
              }
          }];
}

#pragma mark - PRIVATE METHODS
- (NSString*) editOwnerId: (NSString*) wallType {
    NSString *ownerID = @"";
    
    //    для группы добавляем минус, если нет
    //    для пользователя удаляем минус, если есть
    if ([wallType isEqualToString:@"group"]) {
        if (![ownerID hasPrefix:@"-"]) {
            ownerID = [@"-" stringByAppendingString:ownerID];
        }
    }
    if ([wallType isEqualToString:@"user"]) {
        if ([ownerID hasPrefix:@"-"]) {
            ownerID = [ownerID substringFromIndex:1];
        }
    }
    return ownerID;
}
@end


