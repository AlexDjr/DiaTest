//
//  Photo.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Photo : NSObject
@property (strong,nonatomic) NSURL *photo75URL;
@property (assign,nonatomic) CGSize photo75size;
@property (strong,nonatomic) NSURL *photo130URL;
@property (assign,nonatomic) CGSize photo130size;
@property (strong,nonatomic) NSURL *photo604URL;
@property (assign,nonatomic) CGSize photo604size;
@property (strong,nonatomic) NSURL *photo807URL;
@property (assign,nonatomic) CGSize photo807size;
@property (strong,nonatomic) NSURL *photo1280URL;
@property (assign,nonatomic) CGSize photo1280size;
@property (strong,nonatomic) NSURL *photo2560URL;
@property (assign,nonatomic) CGSize photo2560size;

- (instancetype)initWithServerResponse:(NSDictionary *)responseObject;
@end
