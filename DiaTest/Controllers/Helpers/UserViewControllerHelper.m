//
//  UserViewControllerHelper.m
//  DiaTest
//
//  Created by Alex Delin on 25/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "Utils.h"
#import "UserViewControllerHelper.h"
#import "ImageViewGallery.h"

#import "User.h"
#import "Post.h"
#import "Photo.h"

#import "UserInfoCell.h"
#import "PostCell.h"

static CGFloat const defaultLikesButtonTopConstraintValue = 9.0;

@implementation UserViewControllerHelper
+ (UserViewControllerHelper*)sharedHelper {
    static UserViewControllerHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [UserViewControllerHelper new];
    });
    return helper;
}

- (void)setupUserInfoTextFor:(User *)user inCell:(UserInfoCell *)cell {
    cell.firstNameLabel.text = user.firstName;
    cell.lastNameLabel.text = user.lastName;
    cell.onlineStatusLabel.text = user.isOnline ? @"Онлайн" : @"Оффлайн";
}

- (void)clearUserInfoTextInCell:(UserInfoCell *)cell {
    cell.firstNameLabel.text = nil;
    cell.lastNameLabel.text = nil;
    cell.onlineStatusLabel.text = nil;
}

- (void)setupUserOnlineColorInCell:(UserInfoCell *)cell {
    cell.onlineStatusLabel.textColor = [Utils blueActiveColor];
}

- (void)setupUserOfflineColorInCell:(UserInfoCell *)cell {
    cell.onlineStatusLabel.textColor = [Utils grayDefaultColor];
}

- (void)setupAuthorAvatarInCell:(PostCell *)cell {
    NSURL *authorPhotoURL = cell.post.user.photoURL50;
    [cell setAvatarWith:authorPhotoURL];
}

- (void)setupAutorNameInCell:(PostCell *)cell {
    NSString *authorName = [NSString stringWithFormat:@"%@ %@", cell.post.user.firstName, cell.post.user.lastName];
    cell.authorNameLabel.text = authorName;
}

- (void)setupPostTextInCell:(PostCell *)cell {
    cell.postTextLabel.text = cell.post.text;
}

- (void)setupPostDateInCell:(PostCell *)cell {
    cell.dateLabel.text = cell.post.date;
}

- (void)setupLikesCountInCell:(PostCell *)cell {
    [cell.likesButton setTitle:[NSString stringWithFormat:@"  %ld", cell.post.likesCount] forState:UIControlStateNormal];
}

- (void)setupCommentsCountInCell:(PostCell *)cell {
    [cell.commentsButton setTitle:[NSString stringWithFormat:@"  %ld", cell.post.commentsCount] forState:UIControlStateNormal];
}

- (void)setupLikesImageInCell:(PostCell *)cell isLikedByUser:(BOOL) isLikedByUser {
    if (isLikedByUser) {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeSelected"] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeDefault"] forState:UIControlStateNormal];
    }
}

- (void)setupLikesColorInCell:(PostCell *)cell isLikedByUser:(BOOL) isLikedByUser {
    if (isLikedByUser) {
        [cell.likesButton setTitleColor:[Utils blueActiveColor] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setTitleColor:[Utils grayDefaultColor] forState:UIControlStateNormal];
    }
}

- (void)setupAttachmentPhotosInCell:(PostCell *)cell {
    [self removeImageGalleryFromCell:cell];
    [self addImageGalleryToCell:cell];
}

- (void)removeImageGalleryFromCell:(PostCell *)cell {
    if ([cell.contentView viewWithTag:1]) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
        [self setupConstraintsAfterRemoveImageGalleryInCell:cell];
    }
}

- (void)addImageGalleryToCell:(PostCell *)cell {
    if ([cell.post.attachment count] > 0) {
        ImageViewGallery *gallery = [[ImageViewGallery alloc] initWithImages:cell.post.attachment];
        [cell.contentView addSubview:gallery];
        gallery.translatesAutoresizingMaskIntoConstraints = NO;
        [gallery.topAnchor constraintEqualToAnchor:cell.postTextLabel.bottomAnchor constant: 5.0].active = YES;
        [gallery.bottomAnchor constraintEqualToAnchor:cell.likesButton.topAnchor constant: -5.0].active = YES;
        [gallery.leftAnchor constraintEqualToAnchor:cell.contentView.leftAnchor constant: gallery.galleryOffset].active = YES;
        [gallery.rightAnchor constraintEqualToAnchor:cell.contentView.rightAnchor constant: -gallery.galleryOffset].active = YES;
        gallery.tag = 1;
        
        [self setupConstraintsAfterAddImageGallery:gallery InCell:cell];
    }
}

- (void)setupConstraintsAfterRemoveImageGalleryInCell:(PostCell *)cell {
    cell.likesButtonTopConstraint.constant = defaultLikesButtonTopConstraintValue;
}

- (void)setupConstraintsAfterAddImageGallery:(ImageViewGallery *)gallery InCell:(PostCell *)cell {
    cell.likesButtonTopConstraint.constant = gallery.frame.size.height + cell.likesButtonTopConstraint.constant + 10.0;
}

@end
