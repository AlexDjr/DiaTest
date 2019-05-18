//
//  AvatarContainingCell.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum LikeAction : NSUInteger {
    LikeActionDefault,
    LikeActionPost,
    LikeActionDelete
} LikeAction;

@interface VKContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
- (void)setAvatarWith:(NSURL *)url;
- (void)changeLikeWith:(LikeAction)actionType on:(NSString *)type withId:(NSString *)contentId onWall:(NSString *)wallId withCompletion:(void(^)(id result))completion;
@end

NS_ASSUME_NONNULL_END
