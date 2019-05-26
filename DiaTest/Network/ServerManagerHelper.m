//
//  ServerManagerHelper.m
//  DiaTest
//
//  Created by Alex Delin on 26/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "ServerManagerHelper.h"
#import "User.h"
#import "Group.h"
#import "Post.h"
#import "Comment.h"

@implementation ServerManagerHelper
+ (ServerManagerHelper*)sharedHelper {
    static ServerManagerHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [ServerManagerHelper new];
    });
    return helper;
}

- (NSArray *)postsFromResponse:(NSDictionary *)response {
    NSDictionary *responseDictionary = [response objectForKey:@"response"];
    
    NSArray *items = [responseDictionary objectForKey:@"items"];
    NSArray *profiles = [responseDictionary objectForKey:@"profiles"];
    NSArray *groups = [responseDictionary objectForKey:@"groups"];
    
    NSMutableArray *posts = [NSMutableArray array];
    
    for (NSDictionary *itemDictionary in items) {
        Post *post = [[Post alloc] initWithServerResponse:itemDictionary];
        post.user = [self userFromResponseProfiles:profiles forPost:post];
        post.group = [self groupFromResponseGroups:groups];
        
        [posts addObject:post];
    }
    return posts;
}

- (NSArray *)commentsFromResponse:(NSDictionary *)response {
    NSDictionary *responseDictionary = [response objectForKey:@"response"];
    
    NSArray *items = [responseDictionary objectForKey:@"items"];
    NSArray *profiles = [responseDictionary objectForKey:@"profiles"];
    NSArray *groups = [responseDictionary objectForKey:@"groups"];
    
    NSMutableArray *comments = [NSMutableArray array];
    
    for (NSDictionary *itemDictionary in items) {
        Comment *comment = [[Comment alloc] initWithServerResponse:itemDictionary];
        comment.user = [self userFromResponseProfiles:profiles forComment:comment];
        comment.group = [self groupFromResponseGroups:groups];
        
        [comments addObject:comment];
    }
    return comments;
}

#pragma mark - Methods
- (User *)userFromResponse:(NSDictionary *)response {
    NSArray *responseArray = [response objectForKey:@"response"];
    if ([responseArray count] > 0) {
        User *user = [[User alloc] initWithServerResponse:[responseArray firstObject]];
        return user;
    } else {
        return nil;
    }
}

- (Group *)groupFromResponseGroups:(NSArray *)groups {
    Group *group = [[Group alloc] initWithServerResponse:groups.firstObject];
    return group;
}

- (User *)userFromResponseProfiles:(NSArray *)profiles forPost:(Post *)post {
    for (NSDictionary* profileDictionary in profiles) {
        if ([post.fromId isEqualToString:[[profileDictionary objectForKey:@"id"] stringValue]]) {
            User *user = [[User alloc] initWithServerResponse:profileDictionary];
            return user;
        }
    }
    return nil;
}

- (User *)userFromResponseProfiles:(NSArray *)profiles forComment:(Comment *)comment {
    for (NSDictionary* profileDictionary in profiles) {
        if ([comment.fromId isEqualToString:[[profileDictionary objectForKey:@"id"] stringValue]]) {
            User *user = [[User alloc] initWithServerResponse:profileDictionary];
            return user;
        }
    }
    return nil;
}
@end


