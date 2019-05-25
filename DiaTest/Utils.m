//
//  Utils.m
//  DiaTest
//
//  Created by Alex Delin on 24/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+ (UIColor *)blueActiveColor {
    return [UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0];
}

+ (UIColor *)grayDefaultColor {
    return [UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
}

+ (void)print:(NSError *)error withCode:(NSInteger)statusCode {
    NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
}
@end
