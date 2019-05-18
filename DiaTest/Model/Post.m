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

- (instancetype)initWithServerResponse:(NSDictionary *)responseObject {
    self = [super initWithServerResponse:responseObject];
    if (self) {
        self.postId = [responseObject objectForKey:@"id"];
        self.text = [responseObject objectForKey:@"text"];
        self.fromId = [[responseObject objectForKey:@"from_id"] stringValue];        
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd MMM yyyy HH:mm"];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        
//        обработка attachments
        NSArray *attachments = [responseObject objectForKey:@"attachments"];
        
        NSMutableArray *tempImageArray = [NSMutableArray array];
        
        for (NSDictionary *dict in attachments) {
            if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
                
                Photo *photoObject = [[Photo alloc] initWithServerResponse:[dict objectForKey:@"photo"]];
                [tempImageArray addObject:photoObject];
            }
        }
        
        self.attachment = tempImageArray;
        
    }
    return self;
}

@end
