//
//  User.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "User.h"

@implementation User
- (instancetype)initWithServerResponse:(NSDictionary *)response {
    self = [super initWithServerResponse:response];
    if (self) {
        [self setupFromResponse:response];
    }
    return self;
}

#pragma mark - Methods
- (void)setupFromResponse:(NSDictionary *)response {
    self.userId = [self userIdFromResponse:response];
    self.firstName = [self firstNameFromResponse:response];
    self.lastName = [self lastNameFromResponse:response];
    self.isOnline = [self isOnlineFromResponse:response];
    self.photoURL50 = [self photoURL50FromResponse:response];
    self.photoURL200 = [self photoURL200FromResponse:response];
}

- (NSString *)userIdFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"id"] stringValue];
}

- (NSString *)firstNameFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"first_name"];
}

- (NSString *)lastNameFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"last_name"];
}

- (BOOL)isOnlineFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"online"] boolValue];
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
