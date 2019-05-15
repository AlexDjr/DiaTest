//
//  PostCell.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKContentCell.h"

NS_ASSUME_NONNULL_BEGIN

@class Post;
@protocol PostCellDelegate;

@interface PostCell : VKContentCell
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likesButtonTopConstraint;
extern CGFloat const defaultLikesButtonTopConstraintValue;

@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) id <PostCellDelegate> delegate;

- (IBAction)likeButtonAction:(id)sender;
- (IBAction)commentButtonAction:(id)sender;
@end

@protocol PostCellDelegate <NSObject>
- (void) didSelectLikeButtonInCell: (PostCell *) cell;
- (void) didSelectCommentButtonInCell: (PostCell *) cell;
@end

NS_ASSUME_NONNULL_END
