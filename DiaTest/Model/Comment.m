//
//  Comment.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithServerResponse:(NSDictionary *) responseObject {
    self = [super initWithServerResponse:responseObject];
    if (self) {
        self.commentId = [responseObject objectForKey:@"id"];
        self.text = [responseObject objectForKey:@"text"];
        self.fromId = [[responseObject objectForKey:@"from_id"] stringValue];
        
        NSDateFormatter *dateFormater = [NSDateFormatter new];
        [dateFormater setDateFormat:@"dd MMM yyyy HH:mm"];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] integerValue];
        self.isLikedByUser = [[[responseObject objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue];
        self.canLike = [[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] stringValue];
    }
    return self;
}

@end
