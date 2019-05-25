//
//  UserViewControllerHelper.h
//  DiaTest
//
//  Created by Alex Delin on 25/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class UserInfoCell;
@class PostCell;
@class ImageViewGallery;

@interface UserViewControllerHelper : NSObject
+ (UserViewControllerHelper *)sharedHelper;

- (void)setupUserInfoTextFor:(User *)user inCell:(UserInfoCell *)cell;
- (void)clearUserInfoTextInCell:(UserInfoCell *)cell;
- (void)setupUserOnlineColorInCell:(UserInfoCell *)cell;
- (void)setupUserOfflineColorInCell:(UserInfoCell *)cell;
- (void)setupAuthorAvatarInCell:(PostCell *)cell;
- (void)setupAutorNameInCell:(PostCell *)cell;
- (void)setupPostTextInCell:(PostCell *)cell;
- (void)setupPostDateInCell:(PostCell *)cell;
- (void)setupLikesCountInCell:(PostCell *)cell;
- (void)setupCommentsCountInCell:(PostCell *)cell;
- (void)setupLikesImageInCell:(PostCell *)cell isLikedByUser:(BOOL) isLikedByUser;
- (void)setupLikesColorInCell:(PostCell *)cell isLikedByUser:(BOOL) isLikedByUser;
- (void)setupAttachmentPhotosInCell:(PostCell *)cell;
- (void)removeImageGalleryFromCell:(PostCell *)cell;
- (void)addImageGalleryToCell:(PostCell *)cell;
- (void)setupConstraintsAfterRemoveImageGalleryInCell:(PostCell *)cell;
- (void)setupConstraintsAfterAddImageGallery:(ImageViewGallery *)gallery InCell:(PostCell *)cell;
@end
