//
//  CommentsViewController.m
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "CommentsViewController.h"
#import "ServerManager.h"
#import "UIImageView+AFNetworking.h"

#import "CommentCell.h"
#import "VKContentCell.h"

#import "Post.h"
#import "User.h"
#import "Group.h"
#import "Comment.h"

static NSString * const commentCellIdentifier = @"CommentCell";

@interface CommentsViewController () <CommentCellDelegate>
@property (strong, nonatomic) NSMutableArray *commentsArray;
@property (strong, nonatomic) NSString *wallID;
@property (strong, nonatomic) ServerManager *manager;
@end

@implementation CommentsViewController

static NSInteger commentsInRequest = 20;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [ServerManager sharedManager];
    
    self.commentsArray = [NSMutableArray array];
    self.wallID = nil;
    
    if (self.user) {
        self.wallID = self.user.userId;
    }
    
    [self getComments];
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
- (void)getComments {
    [self.manager getCommentsFromPost:self.post.postId
                               onWall:self.wallID
                                 type:@"user"
                            wthOffset:[self.commentsArray count]
                                count:commentsInRequest
                            onSuccess:^(NSArray *comments) {
                                [self.commentsArray addObjectsFromArray:comments];
                                NSMutableArray *newPaths = [NSMutableArray array];
                                for (int i = (int)[self.commentsArray count] - (int)[comments count]; i < [self.commentsArray count]; i++) {
                                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                }
                                [self.tableView beginUpdates];
                                [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationRight];
                                [self.tableView endUpdates];
                            }
                            onFailure:^(NSError *error, NSInteger statusCode) {
                                NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                            }];
}

- (void)deleteLikeFrom:(CommentCell *)cell {
    [self.manager deleteLikeFrom:@"comment"
                          withID:cell.comment.commentId
                          onWall:self.wallID
                            type:@"user"
                       onSuccess:^(id result) {
                           for (Comment *comment in self.commentsArray) {
                               if ([comment isEqual:cell.comment]) {
                                   NSDictionary *dict = [result objectForKey:@"response"];
                                   comment.likesCount = [[dict objectForKey:@"likes"] integerValue];
                                   [cell.likesButton setTitle:[NSString stringWithFormat:@" %ld", comment.likesCount] forState:UIControlStateNormal];
                                   [cell.likesButton setTitleColor:[UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                                   [cell.likesButton setImage:[UIImage imageNamed:@"likeDefaultSmall"] forState:UIControlStateNormal];
                                   cell.comment.isLikedByUser = FALSE;
                               }
                           }
                       }
                       onFailure:^(NSError *error, NSInteger statusCode) {
                           NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                       }];
}

- (void)postLikeOn:(CommentCell *)cell {
    [self.manager postLikeOn:@"comment"
                      withID:cell.comment.commentId
                      onWall:self.wallID
                        type:@"user"
                   onSuccess:^(id result) {
                       for (Comment *comment in self.commentsArray) {
                           if ([comment isEqual:cell.comment]) {
                               NSDictionary *dict = [result objectForKey:@"response"];
                               comment.likesCount = [[dict objectForKey:@"likes"] integerValue];
                               [cell.likesButton setTitle:[NSString stringWithFormat:@" %ld", comment.likesCount] forState:UIControlStateNormal];
                               [cell.likesButton setTitleColor:[UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                               [cell.likesButton setImage:[UIImage imageNamed:@"likeSelectedSmall"] forState:UIControlStateNormal];
                               cell.comment.isLikedByUser = TRUE;
                           }
                       }
                   }
                   onFailure:^(NSError *error, NSInteger statusCode) {
                       NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                   }];
}

#pragma mark - Methods
- (void)setup:(CommentCell *)cell withComment:(Comment *)comment {
    cell.comment = comment;
    
    NSURL *authorPhotoURL = nil;
    NSString *authorName = nil;
    //    если пост от группы, то в from_id будет ИД с минусом
    if ([comment.fromId hasPrefix:@"-"]) {
        authorName = comment.group.name;
        authorPhotoURL = comment.group.photoURL50;
    } else {
        authorName = [NSString stringWithFormat:@"%@ %@", comment.user.firstName, comment.user.lastName];
        authorPhotoURL = comment.user.photoURL50;
    }
    
    cell.commentTextLabel.text = comment.text;
    cell.authorNameLabel.text = authorName;
    cell.dateLabel.text = comment.date;
    
    //    организуем область лайков
    [cell.likesButton setTitle:[NSString stringWithFormat:@" %ld", comment.likesCount] forState:UIControlStateNormal];
    
    //    меняем картинку и цвет текста, в зависимости от того, стоит ли лайк
    if (comment.isLikedByUser) {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeSelectedSmall"] forState:UIControlStateNormal];
        [cell.likesButton setTitleColor:[UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeDefaultSmall"] forState:UIControlStateNormal];
        [cell.likesButton setTitleColor:[UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
    [cell setAvatarWith:authorPhotoURL];
}

- (void)updateLikesAt:(CommentCell *)cell after:(LikeAction)actionType with:(id)result {
    UIColor *likesColor = [[UIColor alloc] init];
    UIImage *likesImage = [[UIImage alloc] init];
    BOOL isLikedByUser = FALSE;
    
    if (actionType == LikeActionDelete) {
        likesColor = [UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
        likesImage = [UIImage imageNamed:@"likeDefaultSmall"];
        isLikedByUser = FALSE;
    }
    
    if (actionType == LikeActionPost) {
        likesColor = [UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0];
        likesImage = [UIImage imageNamed:@"likeSelectedSmall"];
        isLikedByUser = TRUE;
    }
    
    NSDictionary *dict = [result objectForKey:@"response"];
    cell.comment.likesCount = [[dict objectForKey:@"likes"] integerValue];
    [cell.likesButton setTitle:[NSString stringWithFormat:@"  %ld", cell.comment.likesCount] forState:UIControlStateNormal];
    [cell.likesButton setTitleColor:likesColor forState:UIControlStateNormal];
    [cell.likesButton setImage:likesImage forState:UIControlStateNormal];
    cell.comment.isLikedByUser = isLikedByUser;
}

@end
