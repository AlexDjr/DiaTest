//
//  PostCell.m
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "PostCell.h"

CGFloat const defaultLikesButtonTopConstraintValue = 9.0;

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark ACTIONS
- (IBAction)likeButtonAction:(id)sender {
    [self.delegate didSelectLikeButtonInCell:self];
}

- (IBAction)commentButtonAction:(id)sender {
    [self.delegate didSelectCommentButtonInCell:self];
}
@end

