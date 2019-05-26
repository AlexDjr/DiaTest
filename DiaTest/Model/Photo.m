//
//  Photo.m
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Photo.h"

@implementation Photo
- (instancetype)initWithServerResponse:(NSDictionary *)response {
    
    self = [super init];
    if (self) {
        [self setupFromResponse:response];
    }
    return self;
}

#pragma mark - Methods
- (void)setupFromResponse:(NSDictionary *)response {
    self.photo75URL = [self photoURLForHeight:75 fromResponse:response];
    self.photo75size = [self photoSizeForHeight:75 fromResponse:response];
    self.photo130URL = [self photoURLForHeight:130 fromResponse:response];
    self.photo130size = [self photoSizeForHeight:130 fromResponse:response];
    self.photo604URL = [self photoURLForHeight:604 fromResponse:response];
    self.photo604size = [self photoSizeForHeight:604 fromResponse:response];
    self.photo807URL = [self photoURLForHeight:807 fromResponse:response];
    self.photo807size = [self photoSizeForHeight:807 fromResponse:response];
    self.photo1280URL = [self photoURLForHeight:1280 fromResponse:response];
    self.photo1280size = [self photoSizeForHeight:1280 fromResponse:response];
    self.photo2560URL = [self photoURLForHeight:2560 fromResponse:response];
    self.photo2560size = [self photoSizeForHeight:2560 fromResponse:response];
}

- (NSString *)typeStringForHeight:(NSInteger)height {
    NSString *typeString = @"";
    switch (height) {
        case 75:
            typeString = @"s";
            break;
        case 130:
            typeString = @"m";
            break;
        case 604:
            typeString = @"x";
            break;
        case 807:
            typeString = @"y";
            break;
        case 1280:
            typeString = @"z";
            break;
        case 2560:
            typeString = @"w";
            break;
            
        default:
            break;
    }
    
    return typeString;
}

- (NSURL *)photoURLForHeight:(NSInteger)height fromResponse:(NSDictionary *)response {
    NSString *typeString = [self typeStringForHeight:height];
    if (!typeString) {
        return nil;
    }
    NSURL *photoURL = nil;
    NSArray *sizes = [response objectForKey:@"sizes"];
    for (NSDictionary *sizeDictionary in sizes) {
        if ([[sizeDictionary objectForKey:@"type"] isEqualToString:typeString]) {
            photoURL = [NSURL URLWithString:[sizeDictionary objectForKey:@"url"]];
        }
    }
    return photoURL;
}

- (CGSize)photoSizeForHeight:(NSInteger)height fromResponse:(NSDictionary *)response {
    NSString *typeString = [self typeStringForHeight:height];
    if (!typeString) {
        return CGSizeZero;
    }
    CGSize photoSize = CGSizeZero;
    NSArray *sizes = [response objectForKey:@"sizes"];
    for (NSDictionary *sizeDictionary in sizes) {
        if ([[sizeDictionary objectForKey:@"type"] isEqualToString:typeString]) {
            photoSize = CGSizeMake([[sizeDictionary objectForKey:@"width"] integerValue], [[sizeDictionary objectForKey:@"height"] integerValue]);
        }
    }
    return photoSize;
}
@end
