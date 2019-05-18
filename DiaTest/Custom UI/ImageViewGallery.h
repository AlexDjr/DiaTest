//
//  ImageViewGallery.h
//  APITest
//
//  Created by Alex Delin on 10/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewGallery : UIView
extern CGFloat const imageViewGalleryOffset;
extern CGFloat const imageViewGalleryInset;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *imageFrames;

- (instancetype)initWithImageArray:(NSArray *)images;

@end
