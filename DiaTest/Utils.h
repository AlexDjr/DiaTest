//
//  Utils.h
//  DiaTest
//
//  Created by Alex Delin on 24/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject
+ (UIColor *)blueActiveColor;
+ (UIColor *)grayDefaultColor;

+ (void)print:(NSError *)error withCode:(NSInteger)statusCode;
@end
