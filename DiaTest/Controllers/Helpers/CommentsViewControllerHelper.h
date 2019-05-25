//
//  CommentsViewControllerHelper.h
//  DiaTest
//
//  Created by Alex Delin on 25/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//
#import <Foundation/Foundation.h>
@class CommentCell;

@interface CommentsViewControllerHelper : NSObject
+ (CommentsViewControllerHelper *)sharedHelper;

- (void)setupAuthorAvatarInCell:(CommentCell *)cell;
- (void)setupAutorNameInCell:(CommentCell *)cell;
- (void)setupCommentTextInCell:(CommentCell *)cell;
- (void)setupCommentDateInCell:(CommentCell *)cell;
- (void)setupLikesCountInCell:(CommentCell *)cell;
- (void)setupLikesImageInCell:(CommentCell *)cell isLikedByUser:(BOOL) isLikedByUser;
- (void)setupLikesColorInCell:(CommentCell *)cell isLikedByUser:(BOOL) isLikedByUser;
@end
