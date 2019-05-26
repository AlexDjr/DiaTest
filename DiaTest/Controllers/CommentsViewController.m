//
//  CommentsViewController.m
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "CommentsViewController.h"
#import "ServerManager.h"
#import "CommentsViewControllerHelper.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"

#import "CommentCell.h"
#import "VKContentCell.h"

#import "Post.h"
#import "User.h"
#import "Group.h"
#import "Comment.h"

static NSString * const commentCellIdentifier = @"CommentCell";
static NSInteger const commentsInRequest = 20;

@interface CommentsViewController () <CommentCellDelegate>
@property (strong, nonatomic) NSMutableArray *commentsArray;
@property (strong, nonatomic) NSString *wallID;
@property (strong, nonatomic) ServerManager *manager;
@property (strong, nonatomic) CommentsViewControllerHelper *helper;
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    if (self.user) {
        self.wallID = self.user.userId;
    }
    
    [self obtainComments];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
    }
    
    cell.delegate = self;
    Comment *comment = [self.commentsArray objectAtIndex:indexPath.row];
    [self setup:cell withComment:comment];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - CommentCellDelegate
- (void)didSelectLikeButtonInCell:(CommentCell *)cell {
    LikeAction likeAction = LikeActionDefault;
    
    if (cell.comment.isLikedByUser) {
        likeAction = LikeActionDelete;
    } else {
        likeAction = LikeActionPost;
    }
    
    [cell changeLikeWith:likeAction on:@"comment" withId:cell.comment.commentId onWall:self.wallID withCompletion:^(id  _Nonnull result) {
        for (Comment *comment in self.commentsArray) {
            if ([comment isEqual:cell.comment]) {
                [self updateLikesAt:cell after:likeAction with:result];
            }
        }
    }];
}

#pragma mark - API
- (void)obtainComments {
    if (!self.commentsArray) {
        self.commentsArray = [NSMutableArray array];
    }
    
    [self.manager obtainCommentsFromPost:self.post.postId
                               onWall:self.wallID
                                 type:@"user"
                            wthOffset:[self.commentsArray count]
                                count:commentsInRequest
                            onSuccess:^(NSArray *comments) {
                                [self.commentsArray addObjectsFromArray:comments];
                                NSMutableArray * newIndexPaths = [self obtainIndexPathsFor:comments];
                                [self insertRowsInTableViewAt:newIndexPaths];
                            }
                            onFailure:^(NSError *error, NSInteger statusCode) {
                                [Utils print:error withCode:statusCode];
                            }];
}

#pragma mark - Methods
- (void)setupView {
    self.manager = [ServerManager sharedManager];
    self.helper = [CommentsViewControllerHelper sharedHelper];
    self.wallID = nil;
}

- (void)setup:(CommentCell *)cell withComment:(Comment *)comment {
    cell.comment = comment;
    
    [self.helper setupAuthorAvatarInCell:cell];
    [self.helper setupAutorNameInCell:cell];
    [self.helper setupCommentTextInCell:cell];
    [self.helper setupCommentDateInCell:cell];
    [self.helper setupLikesCountInCell:cell];
    
    [self.helper setupLikesImageInCell:cell isLikedByUser:comment.isLikedByUser];
    [self.helper setupLikesColorInCell:cell isLikedByUser:comment.isLikedByUser];
}

- (void)updateLikesAt:(CommentCell *)cell after:(LikeAction)actionType with:(id)result {
    BOOL isLikedByUser = NO;
    
    if (actionType == LikeActionDelete) {
        isLikedByUser = NO;
    } else if (actionType == LikeActionPost) {
        isLikedByUser = YES;
    }
    cell.comment.isLikedByUser = isLikedByUser;
    
    NSDictionary *dict = [result objectForKey:@"response"];
    cell.comment.likesCount = [[dict objectForKey:@"likes"] integerValue];
    
    [self.helper setupLikesCountInCell:cell];
    [self.helper setupLikesColorInCell:cell isLikedByUser:isLikedByUser];
    [self.helper setupLikesImageInCell:cell isLikedByUser:isLikedByUser];
}

- (NSMutableArray *)obtainIndexPathsFor:(NSArray *)comments {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = (int)(self.commentsArray.count - comments.count); i < self.commentsArray.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    return indexPaths;
}

- (void)insertRowsInTableViewAt:(NSMutableArray *)paths {
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

@end
