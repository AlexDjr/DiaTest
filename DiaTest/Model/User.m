//
//  User.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        self.userId = [[responseObject objectForKey:@"id"] stringValue];
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.isOnline = [[responseObject objectForKey:@"online"] boolValue];
        
        NSString *urlString50 = [responseObject objectForKey:@"photo_50"];
        if (urlString50) {
            self.photoURL50 = [NSURL URLWithString:urlString50];
        }
        NSString *urlString200 = [responseObject objectForKey:@"photo_200"];
        if (urlString200) {
            self.photoURL200 = [NSURL URLWithString:urlString200];
        }
    }
    return self;
}

@end
