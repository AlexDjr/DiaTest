//
//  Photo.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (instancetype)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        NSArray *sizesArray = [responseObject objectForKey:@"sizes"];
        
        for (NSDictionary* dict in sizesArray) {
            if ([[dict objectForKey:@"type"] isEqualToString:@"s"]) {
                self.photo75URL = [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo75size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"m"]) {
                self.photo130URL= [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo130size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"x"]) {
                self.photo604URL = [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo604size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"y"]) {
                self.photo807URL = [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo807size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"z"]) {
                self.photo1280URL = [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo1280size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"w"]) {
                self.photo2560URL = [NSURL URLWithString:[dict objectForKey:@"url"]];
                self.photo2560size = CGSizeMake([[dict objectForKey:@"width"] integerValue], [[dict objectForKey:@"height"] integerValue]);
            }
        }
    }
    return self;
}

@end
