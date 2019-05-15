//
// MHFacebookImageViewer.m
// Version 2.0
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MHFacebookImageViewer.h"
#import "UIImageView+AFNetworking.h"
static const CGFloat kMinBlackMaskAlpha = 0.3f;
static const CGFloat kMaxImageScale = 2.5f;
static const CGFloat kMinImageScale = 1.0f;

@interface MHFacebookImageViewerCell : UITableViewCell<UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    UIImageView * imageView;
    UIScrollView * scrollView;
    
    NSMutableArray *gestures;
    
    CGPoint panOrigin;
    
    BOOL isAnimating;
    BOOL isDoneAnimating;
    BOOL isLoaded;
}

@property(nonatomic,assign) CGRect originalFrameRelativeToScreen;
@property(nonatomic,weak) UIViewController * rootViewController;
@property(nonatomic,weak) UIViewController * viewController;
@property(nonatomic,weak) UIView * blackMask;
@property(nonatomic,weak) UIButton * doneButton;
@property(nonatomic,weak) UIImageView * senderView;
@property(nonatomic,assign) NSInteger imageIndex;
@property(nonatomic,weak) UIImage * defaultImage;
@property(nonatomic,assign) NSInteger initialIndex;

@property (nonatomic,weak) MHFacebookImageViewerOpeningBlock openingBlock;
@property (nonatomic,weak) MHFacebookImageViewerClosingBlock closingBlock;

@property(nonatomic,weak) UIView * superView;

@property(nonatomic) UIStatusBarStyle statusBarStyle;

- (void) loadAllRequiredViews;
- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex;

@end

@implementation MHFacebookImageViewerCell

//@synthesize originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
//@synthesize rootViewController = _rootViewController;
//@synthesize viewController = _viewController;
//@synthesize blackMask = _blackMask;
//@synthesize closingBlock = _closingBlock;
//@synthesize openingBlock = _openingBlock;
//@synthesize doneButton = _doneButton;
//@synthesize senderView = _senderView;
//@synthesize imageIndex = _imageIndex;
//@synthesize superView = _superView;
//@synthesize defaultImage = _defaultImage;
//@synthesize initialIndex = _initialIndex;

- (void) loadAllRequiredViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = [UIScreen mainScreen].bounds;
    scrollView = [[UIScrollView alloc]initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    [_doneButton addTarget:self
                    action:@selector(close:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex {
    self.imageIndex = imageIndex;
    self.defaultImage = defaultImage;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.senderView.alpha = 0.0f;
        if(!self->imageView){
            self->imageView = [[UIImageView alloc]init];
            [self->scrollView addSubview:self->imageView];
            self->imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        __block UIImageView * imageViewInTheBlock = self->imageView;
        __block MHFacebookImageViewerCell * selfInTheBlock = self;
        __block UIScrollView * scrollViewInTheBlock = self->scrollView;
        
        [self->imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:defaultImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [scrollViewInTheBlock setZoomScale:1.0f animated:YES];
            [imageViewInTheBlock setImage:image];
            imageViewInTheBlock.frame = [selfInTheBlock centerFrameFromImage:imageViewInTheBlock.image];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Image From URL Not loaded");
        }];
        
        if(self->_imageIndex==self.initialIndex && !self->isLoaded){
            self->imageView.frame = self.originalFrameRelativeToScreen;
            [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
                self->imageView.frame = [self centerFrameFromImage:self->imageView.image];
                CGAffineTransform transf = CGAffineTransformIdentity;
                // Root View Controller - move backward
                self.rootViewController.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
                // Root View Controller - move forward
                self.blackMask.alpha = 1;
            }   completion:^(BOOL finished) {
                if (finished) {
                    self->isAnimating = NO;
                    self->isLoaded = YES;
                    if(self.openingBlock)
                        self.openingBlock();
                }
            }];
            
        }
        imageViewInTheBlock.userInteractionEnabled = YES;
        [self addPanGestureToView:imageViewInTheBlock];
        [self addMultipleGesture];
        
    });
}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [gestures addObject:panGesture];
    panGesture = nil;
}

# pragma mark - Avoid Unwanted Horizontal Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:scrollView];
    return fabs(translation.y) > fabs(translation.x) ;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    panOrigin = imageView.frame.origin;
    gestureRecognizer.enabled = YES;
    return !isAnimating;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UITableView * tableView = (UITableView*)self.superview;
    if ( [tableView respondsToSelector:@selector(panGestureRecognizer)] &&
        [otherGestureRecognizer isEqual:(tableView.panGestureRecognizer)] )
    {
        return NO;
    }
    return YES;
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(scrollView.zoomScale != 1.0f || isAnimating)return;
    if(_imageIndex==self.initialIndex){
        if(_senderView.alpha!=0.0f)
            _senderView.alpha = 0.0f;
    }else {
        if(_senderView.alpha!=1.0f)
            _senderView.alpha = 1.0f;
    }
    // Hide the Done Button
    [self hideDoneButton];
    scrollView.bounces = NO;
    CGSize windowSize = _blackMask.bounds.size;
    CGPoint currentPoint = [panGesture translationInView:scrollView];
    CGFloat y = currentPoint.y + panOrigin.y;
    CGRect frame = imageView.frame;
    frame.origin = CGPointMake(0, y);
    
    imageView.frame = frame;
    CGFloat yDiff = fabs((y + imageView.frame.size.height/2) - windowSize.height/2);
    _blackMask.alpha = MAX(1 - yDiff/(windowSize.height/2),kMinBlackMaskAlpha);
    
    if ((panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) && scrollView.zoomScale == 1.0f) {
        
        if(_blackMask.alpha < 0.7) {
            [self dismissViewController];
        }else {
            [self rollbackViewController];
        }
    }
}

#pragma mark - Just Rollback
- (void)rollbackViewController
{
    isAnimating = YES;
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        self->imageView.frame = [self centerFrameFromImage:self->imageView.image];
        self->_blackMask.alpha = 1;
    }   completion:^(BOOL finished) {
        if (finished) {
            self->isAnimating = NO;
        }
    }];
}


#pragma mark - Dismiss
- (void)dismissViewController
{
    isAnimating = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideDoneButton];
        self->imageView.clipsToBounds = YES;
        CGFloat screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        CGFloat imageYCenterPosition = self->imageView.frame.origin.y + self->imageView.frame.size.height/2 ;
        BOOL isGoingUp =  imageYCenterPosition < screenHeight/2;
        [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
            if(self.imageIndex ==self.initialIndex){
                self->imageView.frame = self.originalFrameRelativeToScreen;
            }else {
                self->imageView.frame = CGRectMake(self->imageView.frame.origin.x, isGoingUp?-screenHeight:screenHeight, self->imageView.frame.size.width, self->imageView.frame.size.height);
            }
            CGAffineTransform transf = CGAffineTransformIdentity;
            self.rootViewController.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
            self.blackMask.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.viewController.view removeFromSuperview];
                [self.viewController removeFromParentViewController];
                self.senderView.alpha = 1.0f;
                [UIApplication sharedApplication].statusBarHidden = NO;
                [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
                self->isAnimating = NO;
                if(self.closingBlock)
                    self.closingBlock();
            }
        }];
    });
}

#pragma mark - Compute the new size of image relative to width(window)
- (CGRect) centerFrameFromImage:(UIImage*) image {
    if(!image) return CGRectZero;
    
    CGRect windowBounds = self.rootViewController.view.bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight {
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
    
}


# pragma mark - UIScrollView Delegate
- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.rootViewController.view.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    isAnimating = YES;
    [self hideDoneButton];
    [self centerScrollViewContents];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    isAnimating = NO;
}

- (void)addMultipleGesture {
    UITapGestureRecognizer *twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTwoFingerTap:)];
    twoFingerTapGesture.numberOfTapsRequired = 1;
    twoFingerTapGesture.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTapGesture];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [scrollView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [scrollView addGestureRecognizer:doubleTapRecognizer];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    scrollView.minimumZoomScale = kMinImageScale;
    scrollView.maximumZoomScale = kMaxImageScale;
    scrollView.zoomScale = 1;
    [self centerScrollViewContents];
}

#pragma mark - For Zooming
- (void)didTwoFingerTap:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, scrollView.minimumZoomScale);
    [scrollView setZoomScale:newZoomScale animated:YES];
}

#pragma mark - Showing of Done Button if ever Zoom Scale is equal to 1
- (void)didSingleTap:(UITapGestureRecognizer*)recognizer {
    if(self.doneButton.superview){
        [self hideDoneButton];
    }else {
        if(scrollView.zoomScale == scrollView.minimumZoomScale){
            if(!isDoneAnimating){
                isDoneAnimating = YES;
                [self.viewController.view addSubview:self.doneButton];
                self.doneButton.alpha = 0.0f;
                [UIView animateWithDuration:0.2f animations:^{
                    self.doneButton.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self.viewController.view bringSubviewToFront:self.doneButton];
                    self->isDoneAnimating = NO;
                }];
            }
        }else if(scrollView.zoomScale == scrollView.maximumZoomScale) {
            CGPoint pointInView = [recognizer locationInView:imageView];
            [self zoomInZoomOut:pointInView];
        }
    }
}

#pragma mark - Zoom in or Zoom out
- (void)didDobleTap:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:imageView];
    [self zoomInZoomOut:pointInView];
}

- (void) zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = scrollView.zoomScale > (scrollView.maximumZoomScale/2)?scrollView.minimumZoomScale:scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - Hide the Done Button
- (void) hideDoneButton {
    if(!isDoneAnimating){
        if(self.doneButton.superview) {
            isDoneAnimating = YES;
            self.doneButton.alpha = 1.0f;
            [UIView animateWithDuration:0.2f animations:^{
                self.doneButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self->isDoneAnimating = NO;
                [self.doneButton removeFromSuperview];
            }];
        }
    }
}

- (void)close:(UIButton *)sender {
    self.userInteractionEnabled = NO;
    [sender removeFromSuperview];
    [self dismissViewController];
}

@end

@interface MHFacebookImageViewer()<UIGestureRecognizerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *gestures;
    
    UITableView * tableView;
    UIView *blackMask;
    UIImageView * imageView;
    UIButton * doneButton;
    UIView * superView;
    
    CGPoint panOrigin;
    CGRect originalFrameRelativeToScreen;
    
    BOOL isAnimating;
    BOOL isDoneAnimating;
    
    UIStatusBarStyle statusBarStyle;
}

@end

@implementation MHFacebookImageViewer
//@synthesize rootViewController = _rootViewController;
//@synthesize imageURL = _imageURL;
//@synthesize openingBlock = _openingBlock;
//@synthesize closingBlock = _closingBlock;
//@synthesize senderView = _senderView;
//@synthesize initialIndex = _initialIndex;

#pragma mark - TableView datasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Just to retain the old version
    if(!self.imageDatasource) return 1;
    return [self.imageDatasource numberImagesForImageViewer:self];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString * cellID = @"mhfacebookImageViewerCell";
    MHFacebookImageViewerCell * imageViewerCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!imageViewerCell) {
        CGRect windowFrame = [[UIScreen mainScreen] bounds];
        imageViewerCell = [[MHFacebookImageViewerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        imageViewerCell.transform = CGAffineTransformMakeRotation(M_PI_2);
        imageViewerCell.frame = CGRectMake(0,0,windowFrame.size.width, windowFrame.size.height);
        imageViewerCell.originalFrameRelativeToScreen = originalFrameRelativeToScreen;
        imageViewerCell.viewController = self;
        imageViewerCell.blackMask = blackMask;
        imageViewerCell.rootViewController = self.rootViewController;
        imageViewerCell.closingBlock = self.closingBlock;
        imageViewerCell.openingBlock = self.openingBlock;
        imageViewerCell.superView = self.senderView.superview;
        imageViewerCell.senderView = self.senderView;
        imageViewerCell.doneButton = doneButton;
        imageViewerCell.initialIndex = self.initialIndex;
        imageViewerCell.statusBarStyle = statusBarStyle;
        [imageViewerCell loadAllRequiredViews];
        imageViewerCell.backgroundColor = [UIColor clearColor];
    }
    if(!self.imageDatasource) {
        // Just to retain the old version
        [imageViewerCell setImageURL:self.imageURL defaultImage:self.senderView.image imageIndex:0];
    } else {
        [imageViewerCell setImageURL:[self.imageDatasource imageURLAtIndex:indexPath.row imageViewer:self] defaultImage:[self.imageDatasource imageDefaultAtIndex:indexPath.row imageViewer:self]imageIndex:indexPath.row];
    }
    return imageViewerCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rootViewController.view.bounds.size.width;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [UIApplication sharedApplication].statusBarHidden = NO;
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    
    // Compute Original Frame Relative To Screen
    CGRect newFrame = [self.senderView convertRect:windowBounds toView:nil];
    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = self.senderView.frame.size;
    originalFrameRelativeToScreen = newFrame;
    
    self.view = [[UIView alloc] initWithFrame:windowBounds];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add a Tableview
    tableView = [[UITableView alloc]initWithFrame:windowBounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    //rotate it -90 degrees
    tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    tableView.frame = CGRectMake(0,0,windowBounds.size.width,windowBounds.size.height);
    tableView.pagingEnabled = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [tableView setShowsVerticalScrollIndicator:NO];
    [tableView setContentOffset:CGPointMake(0, self.initialIndex * windowBounds.size.width)];
    
    blackMask = [[UIView alloc] initWithFrame:windowBounds];
    blackMask.backgroundColor = [UIColor blackColor];
    blackMask.alpha = 0.0f;
    blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [
     self.view insertSubview:blackMask atIndex:0];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];  // make click area bigger
    [doneButton setImage:[UIImage imageNamed:@"Done"] forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(windowBounds.size.width - (51.0f + 9.0f),15.0f, 51.0f, 26.0f);
}

#pragma mark - Show
- (void)presentFromRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void)presentFromViewController:(UIViewController *)controller
{
    _rootViewController = controller;
    [[[[UIApplication sharedApplication]windows]objectAtIndex:0]addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
}

- (void) dealloc {
    _rootViewController = nil;
    self.imageURL = nil;
    self.senderView = nil;
    self.imageDatasource = nil;
}
@end


#pragma mark - Custom Gesture Recognizer that will Handle imageURL
@interface MHFacebookImageViewerTapGestureRecognizer : UITapGestureRecognizer
@property(nonatomic,strong) NSURL * imageURL;
@property(nonatomic,strong) MHFacebookImageViewerOpeningBlock openingBlock;
@property(nonatomic,strong) MHFacebookImageViewerClosingBlock closingBlock;
@property(nonatomic,weak) id<MHFacebookImageViewerDatasource> imageDatasource;
@property(nonatomic,assign) NSInteger initialIndex;

@end

@implementation MHFacebookImageViewerTapGestureRecognizer
@synthesize imageURL;
@synthesize openingBlock;
@synthesize closingBlock;
@synthesize imageDatasource;
@end

@interface UIImageView()<UITabBarControllerDelegate>

@end
#pragma mark - UIImageView Category
@implementation UIImageView (MHFacebookImageViewer)

#pragma mark - Initializer for UIImageView
- (void) setupImageViewer {
    [self setupImageViewerWithCompletionOnOpen:nil onClose:nil];
}

- (void) setupImageViewerWithCompletionOnOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithImageURL:nil onOpen:open onClose:close];
}

- (void) setupImageViewerWithImageURL:(NSURL*)url {
    [self setupImageViewerWithImageURL:url onOpen:nil onClose:nil];
}


- (void) setupImageViewerWithImageURL:(NSURL *)url onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *  tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageURL = url;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}


- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithDatasource:imageDatasource initialIndex:0 onOpen:open onClose:close];
}

- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource initialIndex:(NSInteger)initialIndex onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *  tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageDatasource = imageDatasource;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    tapGesture.initialIndex = initialIndex;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}


#pragma mark - Handle Tap
- (void) didTap:(MHFacebookImageViewerTapGestureRecognizer*)gestureRecognizer {
    
    MHFacebookImageViewer * imageBrowser = [[MHFacebookImageViewer alloc]init];
    imageBrowser.senderView = self;
    imageBrowser.imageURL = gestureRecognizer.imageURL;
    imageBrowser.openingBlock = gestureRecognizer.openingBlock;
    imageBrowser.closingBlock = gestureRecognizer.closingBlock;
    imageBrowser.imageDatasource = gestureRecognizer.imageDatasource;
    imageBrowser.initialIndex = gestureRecognizer.initialIndex;
    if(self.image)
        [imageBrowser presentFromRootViewController];
}


#pragma mark Removal
- (void)removeImageViewer
{
    for (UIGestureRecognizer * gesture in self.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[MHFacebookImageViewerTapGestureRecognizer class]])
        {
            [self removeGestureRecognizer:gesture];
            
            MHFacebookImageViewerTapGestureRecognizer *  tapGesture = (MHFacebookImageViewerTapGestureRecognizer *)gesture;
            tapGesture.imageURL = nil;
            tapGesture.openingBlock = nil;
            tapGesture.closingBlock = nil;
        }
    }
}

@end

