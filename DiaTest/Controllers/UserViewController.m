//
//  ViewController.m
//  DiaTest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "UserViewController.h"
#import "LoginViewController.h"
#import "CommentsViewController.h"
#import "ServerManager.h"
#import "UserViewControllerHelper.h"
#import "ImageViewGallery.h"
#import "Utils.h"

#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#import "User.h"
#import "Post.h"
#import "Photo.h"

#import "UserInfoCell.h"
#import "PostCell.h"

static NSString * const userInfoIdentifier = @"UserInfoCell";
static NSString * const postCellIdentifier = @"PostCell";
static NSInteger const postsInRequest = 20;

@interface UserViewController () <PostCellDelegate>
@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) Post *currentPost;
@property (strong, nonatomic) ServerManager *manager;
@property (strong, nonatomic) UserViewControllerHelper *helper;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    if (self.user) {
        [self obtainUserInfo];
        [self obtainPosts];
    } else {
        [self login];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self.postsArray count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoIdentifier];
            }
            
            [self setup:cell withUser:self.user];
            return cell;
            break;
        }
        case 1:
        {
            PostCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier];
            if (!cell) {
                cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellIdentifier];
            }
            
            cell.delegate = self;
            Post *post = [self.postsArray objectAtIndex:indexPath.row];
            [self setup:cell withPost:post];
            return cell;
            break;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 128.0;
            break;
        default:
            return UITableViewAutomaticDimension;
            break;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 15.0;
            break;
        default:
            return 0.0;
            break;
    }
    return 0.0;
}

#pragma mark - PostCellDelegate
- (void)didSelectLikeButtonInCell:(PostCell *)cell {
    LikeAction likeAction = LikeActionDefault;
    
    if (cell.post.isLikedByUser) {
        likeAction = LikeActionDelete;
    } else {
        likeAction = LikeActionPost;
    }
    
    [cell changeLikeWith:likeAction on:@"post" withId:cell.post.postId onWall:self.user.userId withCompletion:^(id  _Nonnull result) {
        for (Post *post in self.postsArray) {
            if ([post isEqual:cell.post]) {
                [self updateLikesAt:cell after:likeAction with:result];
            }
        }
    }];
}

- (void)didSelectCommentButtonInCell:(PostCell *)cell {
    for (Post *post in self.postsArray) {
        if ([post isEqual:cell.post]) {
            self.currentPost = post;
        }
    }
    [self performSegueWithIdentifier:@"userCommentsSegue" sender:self];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"userCommentsSegue"]) {
        CommentsViewController *controller = segue.destinationViewController;
        controller.user = self.user;
        controller.post = self.currentPost;
    }
}

#pragma mark - API
- (void)obtainUserInfo {
    [self.manager getUser:self.user.userId
                onSuccess:^(User *user) {
                    [self setupControllerWith:user];
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    [Utils print:error withCode:statusCode];
                }];
}

- (void)obtainPosts {
    if (!self.postsArray) {
        self.postsArray = [NSMutableArray array];
    }
    
    [self.manager getWall:self.user.userId
                     type:@"user"
                wthOffset:[self.postsArray count]
                    count:postsInRequest
                onSuccess:^(NSArray *posts) {
                    [self.postsArray addObjectsFromArray:posts];
                    NSMutableArray * newIndexPaths = [self obtainIndexPathsFor:posts];
                    [self insertRowsInTableViewAt:newIndexPaths];
                    [self stopInfiniteScrollingAnimation];
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    [self stopInfiniteScrollingAnimation];
                    [Utils print:error withCode:statusCode];
                }];
}

- (void)refreshWall {
    [self.manager getWall:self.user.userId
                     type:@"user"
                wthOffset:0
                    count:MAX(postsInRequest, [self.postsArray count])
                onSuccess:^(NSArray *posts) {
                    [self reloadTableViewWith:posts];
                    [self.refreshControl endRefreshing];
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    [self.refreshControl endRefreshing];
                    [Utils print:error withCode:statusCode];
                }];
}

#pragma mark - Methods
- (void)setupView {
    self.manager = [ServerManager sharedManager];
    self.helper = [UserViewControllerHelper sharedHelper];
    [self setupNavController];
    [self setupTableView];
    [self addInfiniteScrolling];
    [self addRefreshControl];
}

- (void)login {
    LoginViewController *loginController = [[LoginViewController alloc] initWithCompletionBlock:^(AccessToken *token) {
        [self.manager authorizeUserWithToken:token andCompletion:^(User *user) {
            self.manager.currentUser = user;
            self.user = user;
            [self obtainUserInfo];
            [self obtainPosts];
        }];
    }];
    
    [self presentController:loginController];
}

- (void)setup:(UserInfoCell *)cell withUser:(User *)user {
    [cell setAvatarWith:self.user.photoURL200];
    
    if (user) {
        [self.helper setupUserInfoTextFor:user inCell:cell];
        if (user.isOnline) {
            [self.helper setupUserOnlineColorInCell:cell];
        } else {
            [self.helper setupUserOfflineColorInCell:cell];
        }
    } else {
        [self.helper clearUserInfoTextInCell:cell];
    }
}

- (void)setup:(PostCell *)cell withPost:(Post*) post {
    cell.post = post;
    
    [self.helper setupAuthorAvatarInCell:cell];
    [self.helper setupAutorNameInCell:cell];
    [self.helper setupPostTextInCell:cell];
    [self.helper setupPostDateInCell:cell];
    
    [self.helper setupLikesCountInCell:cell];
    [self.helper setupCommentsCountInCell:cell];
    
    [self.helper setupLikesImageInCell:cell isLikedByUser:post.isLikedByUser];
    [self.helper setupLikesColorInCell:cell isLikedByUser:post.isLikedByUser];
    
    [self.helper setupAttachmentPhotosInCell:cell];
}

- (void)updateLikesAt:(PostCell *)cell after:(LikeAction)actionType with:(id)result {
    BOOL isLikedByUser = NO;
    
    if (actionType == LikeActionDelete) {
        isLikedByUser = NO;
    } else if (actionType == LikeActionPost) {
        isLikedByUser = YES;
    }
    cell.post.isLikedByUser = isLikedByUser;
    
    NSDictionary *dict = [result objectForKey:@"response"];
    cell.post.likesCount = [[dict objectForKey:@"likes"] integerValue];
    
    [self.helper setupLikesCountInCell:cell];
    [self.helper setupLikesColorInCell:cell isLikedByUser:isLikedByUser];
    [self.helper setupLikesImageInCell:cell isLikedByUser:isLikedByUser];
}

- (void)setupControllerWith:(User *)user {
    self.user = user;
    self.navigationItem.title = user.firstName;
    [self.tableView reloadData];
}

- (void)setupTableView {
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)setupNavController {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)addInfiniteScrolling {
    __weak UserViewController *weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf obtainPosts];
    }];
}

- (void)addRefreshControl {
    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)insertRowsInTableViewAt:(NSMutableArray *)paths {
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)presentController:(LoginViewController *)loginController {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    UIViewController *mainController = self;
    [mainController presentViewController:navController animated:YES completion:nil];
}

- (NSMutableArray *)obtainIndexPathsFor:(NSArray *)posts {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = (int)(self.postsArray.count - posts.count); i < self.postsArray.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
    }
    return indexPaths;
}

- (void)stopInfiniteScrollingAnimation {
    //    self.tableView.showsInfiniteScrolling = NO;
    [self.tableView.infiniteScrollingView stopAnimating];
}

- (void)reloadTableViewWith:(NSArray *)posts {
    [self.postsArray removeAllObjects];
    [self.postsArray addObjectsFromArray:posts];
    [self.tableView reloadData];
}

# pragma mark - Actions
- (IBAction)logoutAction:(UIBarButtonItem *)sender {
    [self.manager logoutWithCompletion:^{
        [self login];
    }];
    
}
@end
