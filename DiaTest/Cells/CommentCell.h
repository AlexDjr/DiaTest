//
//  CommentCell.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKContentCell.h"
@class Post;
@class Comment;
@protocol CommentCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : VKContentCell
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;

@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) id <CommentCellDelegate> delegate;

- (IBAction)likeButtonAction:(id)sender;
@end

@protocol CommentCellDelegate <NSObject>
- (void) didSelectLikeButtonInCell: (CommentCell *) cell;
@end

NS_ASSUME_NONNULL_END
