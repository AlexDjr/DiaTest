//
//  ImageViewGallery.h
//  APITest
//
//  Created by Alex Delin on 10/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Photo;

@interface ImageViewGallery : UIView
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, assign) CGFloat galleryOffset;

- (instancetype)initWithImages:(NSArray *)images;
@end
