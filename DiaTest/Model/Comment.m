//
//  Comment.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Comment.h"

@implementation Comment
- (instancetype)initWithServerResponse:(NSDictionary *) response {
    self = [super initWithServerResponse:response];
    if (self) {
        [self setupFromResponse:response];
    }
    return self;
}

#pragma mark - Methods
- (void)setupFromResponse:(NSDictionary *)response {
    self.commentId = [self commentIdFromResponse:response];
    self.text = [self textFromResponse:response];
    self.fromId = [self fromIdFromResponse:response];
    self.date = [self dateFromResponse:response];
    self.likesCount = [self likesCountFromResponse:response];
    self.isLikedByUser = [self isLikedByUserFromResponse:response];
    self.canLike = [self canLikeFromResponse:response];
}

- (NSString *)commentIdFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"id"];
}

- (NSString *)textFromResponse:(NSDictionary *)response {
    return [response objectForKey:@"text"];
}

- (NSString *)fromIdFromResponse:(NSDictionary *)response {
    return [[response objectForKey:@"from_id"] stringValue];
}

- (NSString *)dateFromResponse:(NSDictionary *)response {
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setDateFormat:@"dd MMM yyyy HH:mm"];
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[response objectForKey:@"date"] floatValue]];
    NSString *date = [dateFormater stringFromDate:dateTime];
    return date;
}

- (NSInteger)likesCountFromResponse:(NSDictionary *)response {
    return [[[response objectForKey:@"likes"] objectForKey:@"count"] integerValue];
}

- (BOOL)isLikedByUserFromResponse:(NSDictionary *)response {
    return [[[response objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue];
}

- (NSString *)canLikeFromResponse:(NSDictionary *)response {
    return [[[response objectForKey:@"likes"] objectForKey:@"can_like"] stringValue];
}

@end
