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

static CGFloat const galleryInset = 5.0;

@interface ImageViewGallery () <MHFacebookImageViewerDatasource>
@property (strong,nonatomic) UIScrollView *contentView;
@end

@implementation ImageViewGallery

- (instancetype)initWithImages:(NSArray *)images {
    self = [super init];
    if (self) {
        [self setupWithImages:images];
    }
    return self;
}

#pragma mark - MHFacebookImageViewerDatasource
- (NSInteger)numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    return [self.images count];
}

- (NSURL *)imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    if ([[self.images objectAtIndex:index] isKindOfClass:[Photo class]]) {
        Photo *photoObject = [self.images objectAtIndex:index];
        NSURL *photoURL = [NSURL new];
        
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

#pragma mark - Methods
- (void)setupWithImages:(NSArray *)images {
    self.images = images;
    
    [self setupSubViews];
    [self setupGalleryOffset];
    
    self.imageViews = [self galleryImageViewsForImages:images];
    [self setupGalleryFrameForImages:images];
}

- (void)setupSubViews {
    [self addSubview:self.contentView];
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)setupGalleryOffset {
    self.galleryOffset = 9.0;
}

- (CGSize)gallerySizeForImages:(NSArray *)images {
    CGFloat galleryWidth = UIScreen.mainScreen.bounds.size.width - self.galleryOffset * 2;
    CGFloat galleryHeight = 0.0;
    
    if (self.images.count == 1) {
        if ([[images firstObject] isKindOfClass:[Photo class]]) {
            Photo *photoObject = [images firstObject];
            galleryHeight = photoObject.photo604size.height * galleryWidth / photoObject.photo604size.width;
        }
    } else {
        NSInteger rowsCount = round((images.count + 1) / 2);
        CGFloat imageHeight = ((galleryWidth - galleryInset) / 2);
        galleryHeight = rowsCount * imageHeight + (rowsCount - 1) * galleryInset - galleryInset;
    }
    return CGSizeMake(galleryWidth, galleryHeight);
}

- (NSArray *)galleryImageViewsForImages:(NSArray *)images {
    NSMutableArray *imageViews = [NSMutableArray array];
    
    for (id image in images) {
        if ([image isKindOfClass:[Photo class]]) {
            Photo *photo = (Photo *)image;
            UIImageView * imageView = [self imageViewFor:photo];
            [imageViews addObject:imageView];
        }
    }
    
    return imageViews;
}

- (UIImageView *)imageViewFor:(Photo *)photo {
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:photo.photo604URL];
    
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [self displayImage:weakImageView withImage:image withImageURL:photo.photo2560URL];
                              }
                              failure:nil];
    return imageView;
}

- (void)displayImage:(UIImageView *)imageView withImage:(UIImage *)image withImageURL:(NSURL *)imageURL {
    NSInteger imageIndex = [self.images indexOfObject:image];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [imageView setupImageViewerWithDatasource:self initialIndex:imageIndex onOpen:nil onClose:nil];
}

- (void)setupGalleryFrameForImages:(NSArray *)images {
    CGSize gallerySize = [self gallerySizeForImages:images];
    self.frame = CGRectMake(0.0, 0.0, gallerySize.width, gallerySize.height);
    [self setupFramesForImageViewsToFitSize:gallerySize];
}

- (void)setupFramesForImageViewsToFitSize:(CGSize)frameSize {
    NSInteger imageIndex = 0;
    UIImageView *prevImageView = [UIImageView new];
    
    for (UIImageView *imageView in self.imageViews) {
        [self addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (self.imageViews.count == 1) {
            [self addImageViewWhenCountEqualsOne:imageView];
        } else {
            [self addImageViewWhenCountMoreThanOne:imageView withImageIndex:imageIndex andPrevImageView:prevImageView];
            imageIndex += 1;
            prevImageView = imageView;
        }
    }
}

- (void)addImageViewWhenCountEqualsOne:(UIImageView *)imageView {
    [imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
}

- (void)addImageViewWhenCountMoreThanOne:(UIImageView *)imageView withImageIndex:(NSInteger)imageIndex andPrevImageView:(UIImageView *)prevImageView {
    const BOOL isFirstImage = imageIndex == 0;
    const BOOL isSecondImage = imageIndex == 1;
    const BOOL isOddNumberImage = imageIndex % 2 && imageIndex != 0;
    const BOOL isEvenNumberImage = !(imageIndex % 2) && imageIndex != 1;
    
    NSLayoutAnchor *topAnchor = [NSLayoutAnchor new];
    NSInteger topAnchorConstant = 0;
    NSLayoutAnchor *leftAnchor = [NSLayoutAnchor new];
    NSInteger leftAnchorConstant = 0;
    
    if (isFirstImage) {
        topAnchor = self.topAnchor;
        topAnchorConstant = 0;
        leftAnchor = self.leftAnchor;
        leftAnchorConstant = 0;
    } else if (isSecondImage) {
        topAnchor = self.topAnchor;
        topAnchorConstant = 0;
        leftAnchor = prevImageView.rightAnchor;
        leftAnchorConstant = galleryInset;
    } else if (isEvenNumberImage) {
        topAnchor = prevImageView.bottomAnchor;
        topAnchorConstant = galleryInset;
        leftAnchor = self.leftAnchor;
        leftAnchorConstant = 0;
    } else if (isOddNumberImage) {
        topAnchor = prevImageView.topAnchor;
        topAnchorConstant = 0;
        leftAnchor = prevImageView.rightAnchor;
        leftAnchorConstant = galleryInset;
    }
    
    CGFloat imageViewWidth = (self.frame.size.width - galleryInset)/ 2;
    CGFloat imageViewHeight = imageViewWidth;
    
    [imageView.topAnchor constraintEqualToAnchor:topAnchor constant: topAnchorConstant].active = YES;
    [imageView.leftAnchor constraintEqualToAnchor:leftAnchor constant: leftAnchorConstant].active = YES;
    [imageView.widthAnchor constraintEqualToConstant:imageViewWidth].active = YES;
    [imageView.heightAnchor constraintEqualToConstant:imageViewHeight].active = YES;
}

@end
