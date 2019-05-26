//
//  Group.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Group.h"

@implementation Group
- (instancetype)initWithServerResponse:(NSDictionary *)response {
    self = [super init];
    if (self) {
        [self setupFromResponse:response];
    }
    return self;
}

#pragma mark - Methods
- (void)setupFromResponse:(NSDictionary *)response {
    self.groupId = [self groupIdFromResponse:response];
    self.desc = [self descFromResponse:response];
    self.activity = [self activityFromResponse:response];
    self.name = [self nameFromResponse:response];
    self.isMember = [self isMemberFromResponse:response];
    self.membersCount = [self membersCountFromResponse:response];
    self.status = [self statusFromResponse:response];
    self.photoURL50 = [self photoURL50FromResponse:response];
    self.photoURL200 = [self photoURL200FromResponse:response];    
}

- (NSString *)groupIdFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"id"] stringValue];
}
- (NSString *)descFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"description"];
}
- (NSString *)activityFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"activity"];
}
- (NSString *)nameFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"name"];
}
- (BOOL)isMemberFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"is_member"] boolValue];
}
- (NSString *)membersCountFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"members_count"] stringValue];
}
- (NSString *)statusFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"status"];
}

- (NSURL *)photoURL50FromResponse:(NSDictionary *)response {
    NSString *urlString50 = [response objectForKey:@"photo_50"];
    if (urlString50) {
        return [NSURL URLWithString:urlString50];
    }
    return nil;
}

- (NSURL *)photoURL200FromResponse:(NSDictionary *)response {
    NSString *urlString200 = [response objectForKey:@"photo_200"];
    if (urlString200) {
        return [NSURL URLWithString:urlString200];
    }
    return nil;
}
@end
