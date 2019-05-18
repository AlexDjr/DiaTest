//
//  ImageViewGallery.m
//  APITest
//
//  Created by Alex Delin on 10/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "ImageViewGallery.h"
#import "UIImageView+AFNetworking.h"
#import "MHFacebookImageViewer.h"

#import "Photo.h"

CGFloat const imageViewGalleryOffset = 9.0;
CGFloat const imageViewGalleryInset = 5.0;

@interface ImageViewGallery () <MHFacebookImageViewerDatasource>
@property (strong,nonatomic) UIScrollView *contentView;
@end

@implementation ImageViewGallery

- (instancetype)initWithImageArray:(NSArray *)images {
    
    self = [super init];
    if (self) {
        self.images = images;
        
        [self addSubview:self.contentView];
        
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.imageViews = [NSMutableArray array];
        self.imageFrames = [NSMutableArray array];
        
        int imageIndex = 0;
        for (id image in self.images) {
            
            if ([image isKindOfClass:[Photo class]]) {
                Photo *photoObject = (Photo *)image;
                UIImageView *imageView = [[UIImageView alloc] init];
                
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photoObject.photo604URL];
                
                __weak UIImageView *weakImageView = imageView;
                
                [imageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              weakImageView.image = image;
                                              [self displayImage:weakImageView withImage:image withImageURL:photoObject.photo2560URL index:imageIndex];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          }];
                imageIndex += 1;
                [self.imageFrames addObject:photoObject];
                [self.imageViews addObject:imageView];
                
            }
        }
        
        CGFloat galleryWidth = UIScreen.mainScreen.bounds.size.width - imageViewGalleryOffset * 2;
        CGFloat galleryHeight = 0.0;
        
        if (images.count == 1) {
            if ([[images firstObject] isKindOfClass:[Photo class]]) {
                Photo *photoObject = [images firstObject];
                galleryHeight = photoObject.photo604size.height * galleryWidth / photoObject.photo604size.width;
            }
        } else {
            NSInteger rowsCount = round((images.count + 1) / 2);
            CGFloat imageHeight = ((galleryWidth - imageViewGalleryInset) / 2);
            galleryHeight = rowsCount * imageHeight + (rowsCount - 1) * imageViewGalleryInset - imageViewGalleryInset;
        }
        
        self.frame = CGRectMake(0.0, 0.0, galleryWidth, galleryHeight);
        [self setFramesForImageViewsToFitSize:CGSizeMake(galleryWidth, galleryHeight)];
    }
    
    return self;
}

- (void)displayImage:(UIImageView *)imageView withImage:(UIImage *)image  withImageURL:(NSURL *)imageURL index:(NSInteger)index {
    
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [imageView setupImageViewerWithDatasource:self initialIndex:index onOpen:^{
        
    } onClose:^{
        
    }];
}


- (NSInteger)numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    return [self.images count];
}


- (NSURL *)imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    if ([[self.images objectAtIndex:index] isKindOfClass:[Photo class]]) {
        Photo *photoObject = [self.images objectAtIndex:index];
        NSURL *photoURL = [[NSURL alloc] init];
        
        if (photoObject.photo2560URL) {
            photoURL = photoObject.photo2560URL;
        } else if (photoObject.photo1280URL) {
            photoURL = photoObject.photo1280URL;
        } else if (photoObject.photo604URL) {
            photoURL = photoObject.photo604URL;
        }
        return photoURL;
    } else {
        return nil;
    }
}

- (UIImage *)imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer{
    return nil;
}

- (void)setFramesForImageViewsToFitSize:(CGSize)frameSize {
    NSInteger imageIndex = 1;
    UIImageView *prevImageView = [[UIImageView alloc] init];
    
    for (UIImageView *imageView in self.imageViews) {
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        if (self.imageViews.count == 1) {

            [self addSubview:imageView];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            [imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
            break;
            
        } else {
            
            NSLayoutAnchor *topAnchor = [[NSLayoutAnchor alloc] init];
            NSInteger topAnchorConstant = 0;
            NSLayoutAnchor *leftAnchor = [[NSLayoutAnchor alloc] init];
            NSInteger leftAnchorConstant = 0;
            
            if (imageIndex % 2 && imageIndex == 1) {
                //    фото 1
                topAnchor = self.topAnchor;
                topAnchorConstant = 0;
                leftAnchor = self.leftAnchor;
                leftAnchorConstant = 0;
            } else if (!(imageIndex % 2) && imageIndex == 2) {
                //    фото 2
                topAnchor = self.topAnchor;
                topAnchorConstant = 0;
                leftAnchor = prevImageView.rightAnchor;
                leftAnchorConstant = imageViewGalleryInset;
            } else if (imageIndex % 2 && imageIndex != 1) {
                //    фото 3,5,7 ...
                topAnchor = prevImageView.bottomAnchor;
                topAnchorConstant = imageViewGalleryInset;
                leftAnchor = self.leftAnchor;
                leftAnchorConstant = 0;
            } else if (!(imageIndex % 2) && imageIndex != 2) {
                //    фото 4,6,8 ...
                topAnchor = prevImageView.topAnchor;
                topAnchorConstant = 0;
                leftAnchor = prevImageView.rightAnchor;
                leftAnchorConstant = imageViewGalleryInset;
            }
            
            [self addSubview:imageView];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [imageView.topAnchor constraintEqualToAnchor:topAnchor constant: topAnchorConstant].active = YES;
            [imageView.leftAnchor constraintEqualToAnchor:leftAnchor constant: leftAnchorConstant].active = YES;
            [imageView.widthAnchor constraintEqualToConstant:(self.frame.size.width - imageViewGalleryInset)/ 2].active = YES;
            [imageView.heightAnchor constraintEqualToConstant:(self.frame.size.width - imageViewGalleryInset)/ 2].active = YES;
            
            imageIndex += 1;
            prevImageView = imageView;
        }
    }
}

@end
