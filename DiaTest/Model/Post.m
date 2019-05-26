//
//  Post.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Post.h"
#import "Photo.h"

@implementation Post
- (instancetype)initWithServerResponse:(NSDictionary *)response {
    self = [super initWithServerResponse:response];
    if (self) {
        [self setupWith:response];
        
    }
    return self;
}

#pragma mark - Methods
- (void)setupWith:(NSDictionary *)response {
    self.postId = [self postIdFromResponse:response];
    self.text = [self textFromResponse:response];
    self.fromId = [self fromIdFromResponse:response];
    self.date = [self dateFromResponse:response];
    self.attachment = [self attachmentFromResponse:response];
    self.likesCount = [self likesCountFromResponse:response];
    self.isLikedByUser = [self isLikedByUserFromResponse:response];
    self.canLike = [self canLikeFromResponse:response];
    self.commentsCount = [self commentsCountFromResponse:response];
}

- (NSString *)postIdFromResponse:(NSDictionary *)response {
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

- (NSMutableArray *)attachmentFromResponse:(NSDictionary *)response {
    NSArray *attachments = [response objectForKey:@"attachments"];
    
    NSMutableArray *photos = [NSMutableArray array];
    
    for (NSDictionary *dict in attachments) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
            Photo *photoObject = [[Photo alloc] initWithServerResponse:[dict objectForKey:@"photo"]];
            [photos addObject:photoObject];
        }
    }
    return photos;
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

- (NSInteger)commentsCountFromResponse:(NSDictionary *)response {
    return [[[response objectForKey:@"comments"] objectForKey:@"count"] integerValue];
}

@end
