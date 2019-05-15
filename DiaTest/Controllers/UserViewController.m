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
#import "ImageViewGallery.h"

#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#import "User.h"
#import "Post.h"
#import "Photo.h"

#import "UserInfoCell.h"
#import "PostCell.h"


@interface UserViewController () <PostCellDelegate>
@property (strong, nonatomic) NSMutableArray *postsArray;
@property (strong, nonatomic) Post *currentPost;
@property (strong, nonatomic) ServerManager * manager;

- (IBAction)logoutAction:(UIBarButtonItem *)sender;
@end

@implementation UserViewController

static NSInteger postsInRequest = 20;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    //    проверяем, авторизован ли юзер
    if (self.user) {
        [self getUserInfo];
        [self getPosts];
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
    static NSString* userInfoIdentifier = @"UserInfoCell";
    static NSString* postCellIdentifier = @"PostCell";
    
    if (indexPath.section == 0) {
        
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoIdentifier];
        if (!cell) {
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoIdentifier];
        }
        
        [self setup:cell withUser:self.user];
        return cell;
        
    } else if (indexPath.section == 1) {
        
        PostCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier];
        if (!cell) {
            cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellIdentifier];
        }
        
        cell.delegate = self;
        Post *post = [self.postsArray objectAtIndex:indexPath.row];
        [self setup:cell withPost:post];
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 128.0;
    } else {
        return UITableViewAutomaticDimension;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat footerHeight = 0.0;
    if (section == 0) {
        footerHeight = 15.0;
    }
    return footerHeight;
}

#pragma mark - PostCellDelegate
- (void) didSelectLikeButtonInCell:(PostCell *) cell {
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

- (void) didSelectCommentButtonInCell:(PostCell *) cell {
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
- (void) getUserInfo {
    [self.manager getUser:self.user.userId
                onSuccess:^(User *user) {
                    self.user = user;
                    self.navigationItem.title = user.firstName;
                    [self.tableView reloadData];
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                }];
}

- (void) getPosts {
    if (!self.postsArray) {
        self.postsArray = [NSMutableArray array];
    }
    
    [self.manager getWall:self.user.userId
                     type:@"user"
                wthOffset:[self.postsArray count]
                    count:postsInRequest
                onSuccess:^(NSArray *posts) {
                    [self.postsArray addObjectsFromArray:posts];
                    NSMutableArray *newPaths = [NSMutableArray array];
                    for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                    }
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                    
                    [self.tableView.infiniteScrollingView stopAnimating];
                    
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    self.tableView.showsInfiniteScrolling = NO;
                    [self.tableView.infiniteScrollingView stopAnimating];
                    NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                }];
}

- (void) refreshWall {
    [self.manager getWall:self.user.userId
                     type:@"user"
                wthOffset:0
                    count:MAX(postsInRequest, [self.postsArray count])
                onSuccess:^(NSArray *posts) {
                    [self.postsArray removeAllObjects];
                    [self.postsArray addObjectsFromArray:posts];
                    [self.tableView reloadData];
                    
                    [self.refreshControl endRefreshing];
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                    [self.refreshControl endRefreshing];
                }];
}

#pragma mark - Methods
- (void) setupView {
    self.manager = [ServerManager sharedManager];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self infiniteScrolling];
    
    //    добавляем рефреш-контрол
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void) login {
    LoginViewController *loginController = [[LoginViewController alloc] initWithCompletionBlock:^(AccessToken *token) {
        [self.manager authorizeUserWithToken:token andCompletion:^(User *user) {
            self.manager.currentUser = user;
            self.user = user;
            [self getUserInfo];
            [self getPosts];
        }];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    UIViewController *mainController = self;
    [mainController presentViewController:navController animated:YES completion:nil];
}

- (void) setup:(UserInfoCell *)cell withUser:(User*) user {
    [cell setAvatarWith:self.user.photoURL200];
    
    if (user) {
        cell.firstNameLabel.text = user.firstName;
        cell.lastNameLabel.text = user.lastName;
        cell.onlineStatusLabel.text = user.isOnline ? @"Онлайн" : @"Оффлайн";
        if (user.isOnline) {
            cell.onlineStatusLabel.textColor = [UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0];
        } else {
            cell.onlineStatusLabel.textColor = [UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
        }
    } else {
        cell.firstNameLabel.text = nil;
        cell.lastNameLabel.text = nil;
        cell.onlineStatusLabel.text = nil;
    }
}

- (void) setup:(PostCell *)cell withPost:(Post*) post {
    cell.post = post;
    
    NSURL *authorPhotoURL = nil;
    NSString *authorName = nil;
    authorName = [NSString stringWithFormat:@"%@ %@", post.user.firstName, post.user.lastName];
    authorPhotoURL = post.user.photoURL50;
    
    cell.postTextLabel.text = post.text;
    cell.authorNameLabel.text = authorName;
    cell.dateLabel.text = post.date;
    
    //    устанавливаем кол-во лайков и комментов
    [cell.likesButton setTitle:[NSString stringWithFormat:@"  %ld", post.likesCount] forState:UIControlStateNormal];
    [cell.commentsButton setTitle:[NSString stringWithFormat:@"  %ld", post.commentsCount] forState:UIControlStateNormal];
    
    //    меняем картинку и цвет текста, в зависимости от того, стоит ли лайк
    if (post.isLikedByUser) {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeSelected"] forState:UIControlStateNormal];
        [cell.likesButton setTitleColor:[UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        [cell.likesButton setImage:[UIImage imageNamed:@"likeDefault"] forState:UIControlStateNormal];
        [cell.likesButton setTitleColor:[UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
    [cell setAvatarWith:authorPhotoURL];
    
    //    удаляем галлерею с фото, если она была
    if ([cell.contentView viewWithTag:1]) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
        cell.likesButtonTopConstraint.constant = defaultLikesButtonTopConstraintValue;
    }
    
    //    добавляем фото из attachments
    if ([post.attachment count] > 0) {
        
        ImageViewGallery *gallery = [[ImageViewGallery alloc] initWithImageArray:post.attachment];
        [cell.contentView addSubview:gallery];
        gallery.translatesAutoresizingMaskIntoConstraints = NO;
        [gallery.topAnchor constraintEqualToAnchor:cell.postTextLabel.bottomAnchor constant: 5.0].active = YES;
        [gallery.bottomAnchor constraintEqualToAnchor:cell.likesButton.topAnchor constant: -5.0].active = YES;
        [gallery.leftAnchor constraintEqualToAnchor:cell.contentView.leftAnchor constant: imageViewGalleryOffset].active = YES;
        [gallery.rightAnchor constraintEqualToAnchor:cell.contentView.rightAnchor constant: -imageViewGalleryOffset].active = YES;
        
        gallery.tag = 1;
        cell.likesButtonTopConstraint.constant = gallery.frame.size.height + cell.likesButtonTopConstraint.constant + 10.0;
    }
}

- (void) updateLikesAt:(PostCell*) cell after:(LikeAction) actionType with:(id) result {
    UIColor *likesColor = [[UIColor alloc] init];
    UIImage *likesImage = [[UIImage alloc] init];
    BOOL isLikedByUser = FALSE;
    
    if (actionType == LikeActionDelete) {
        likesColor = [UIColor colorWithRed:165.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
        likesImage = [UIImage imageNamed:@"likeDefault"];
        isLikedByUser = FALSE;
    }
    
    if (actionType == LikeActionPost) {
        likesColor = [UIColor colorWithRed:78.0/255.0 green:118.0/255.0 blue:161.0/255.0 alpha:1.0];
        likesImage = [UIImage imageNamed:@"likeSelected"];
        isLikedByUser = TRUE;
    }
    
    NSDictionary *dict = [result objectForKey:@"response"];
    cell.post.likesCount = [[dict objectForKey:@"likes"] integerValue];
    [cell.likesButton setTitle:[NSString stringWithFormat:@"  %ld", cell.post.likesCount] forState:UIControlStateNormal];
    [cell.likesButton setTitleColor:likesColor forState:UIControlStateNormal];
    [cell.likesButton setImage:likesImage forState:UIControlStateNormal];
    cell.post.isLikedByUser = isLikedByUser;
}

- (void) infiniteScrolling {
    __weak UserViewController* weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getPosts];
    }];
}

# pragma mark - Actions
- (IBAction)logoutAction:(UIBarButtonItem *)sender {
    [self.manager logoutWithCompletion:^{
        [self login];
    }];
    
}
@end
