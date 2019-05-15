//
//  Group.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Group.h"

@implementation Group

- (instancetype)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        self.groupId = [[responseObject objectForKey:@"id"] stringValue];
        self.desc = [responseObject objectForKey:@"description"];
        self.activity = [responseObject objectForKey:@"activity"];
        self.name = [responseObject objectForKey:@"name"];
        self.isClosed = [[responseObject objectForKey:@"is_closed"] boolValue];
        self.isMember = [[responseObject objectForKey:@"is_member"] boolValue];
        self.membersCount = [[responseObject objectForKey:@"members_count"] stringValue];
        self.status = [responseObject objectForKey:@"status"];
        
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
