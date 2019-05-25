//
//  CommentsViewControllerHelper.m
//  DiaTest
//
//  Created by Alex Delin on 25/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "CommentsViewControllerHelper.h"
#import "Utils.h"
#import "CommentCell.h"
#import "Comment.h"
#import "Group.h"
#import "User.h"

@implementation CommentsViewControllerHelper
+ (CommentsViewControllerHelper*)sharedHelper {
    static CommentsViewControllerHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [CommentsViewControllerHelper new];
    });
    return helper;
}

- (void)setupAuthorAvatarInCell:(CommentCell *)cell {
    const BOOL isCommentFromGroup = [cell.comment.fromId hasPrefix:@"-"];
    if (isCommentFromGroup) {
        [cell setAvatarWith:cell.comment.group.photoURL50];
    } else {
        [cell setAvatarWith:cell.comment.user.photoURL50];
    }
}

- (void)setupAutorNameInCell:(CommentCell *)cell {
    const BOOL isCommentFromGroup = [cell.comment.fromId hasPrefix:@"-"];
    if (isCommentFromGroup) {
        cell.authorNameLabel.text = cell.comment.group.name;
    } else {
        NSString *authorName = [NSString stringWithFormat:@"%@ %@", cell.comment.user.firstName, cell.comment.user.lastName];
        cell.authorNameLabel.text = authorName;
    }
}

- (void)setupCommentTextInCell:(CommentCell *)cell {
    cell.commentTextLabel.text = cell.comment.text;
}

- (void)setupCommentDateInCell:(CommentCell *)cell {
    cell.dateLabel.text = cell.comment.date;
}

- (void)setupLikesCountInCell:(CommentCell *)cell {
    [cell.likesButton setTitle:[NSString stringWithFormat:@"  %ld", cell.comment.likesCount] forState:UIControlStateNormal];
}

- (void)setupLikesImageInCell:(CommentCell *)cell isLikedByUser:(BOOL) isLikedByUser {
    if (isLikedByUser) {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeSelectedSmall"] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeDefaultSmall"] forState:UIControlStateNormal];
    }
}

- (void)setupLikesColorInCell:(CommentCell *)cell isLikedByUser:(BOOL) isLikedByUser {
    if (isLikedByUser) {
        [cell.likesButton setTitleColor:[Utils blueActiveColor] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setTitleColor:[Utils grayDefaultColor] forState:UIControlStateNormal];
    }
}
@end


