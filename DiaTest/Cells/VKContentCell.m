//
//  AvatarContainingCell.m
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "VKContentCell.h"
#import "UIImageView+AFNetworking.h"
#import "ServerManager.h"

@implementation VKContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupAvatarImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Private Methods
- (void) setupAvatarImageView {
    CALayer *imageLayer = self.avatarImageView.layer;
    CGFloat radius = self.avatarImageView.frame.size.height / 2;
    [imageLayer setCornerRadius:radius];
    [imageLayer setBounds:CGRectMake(0.0f, 0.0f, radius *2, radius *2)];
    [imageLayer setMasksToBounds:YES];
}

#pragma mark - Public Methods
- (void) setAvatarWith:(NSURL*) url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    __weak VKContentCell *weakCell = self;
    
    [self.avatarImageView setImageWithURLRequest:request
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             
                                             weakCell.avatarImageView.image = image;
                                             
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             
                                         }];
}

- (void) changeLikeWith:(LikeAction) actionType on:(NSString*) contentType withId:(NSString*) contentId onWall:(NSString*) wallId withCompletion:(void(^)(id result)) completion {
    ServerManager* manager = [ServerManager sharedManager];
    
    if (actionType == LikeActionPost) {
        [manager postLikeOn:contentType
                     withID:contentId
                     onWall:wallId
                       type:@"user"
                  onSuccess:^(id result) {
                      completion(result);
                  }
                  onFailure:^(NSError *error, NSInteger statusCode) {
                      NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                  }];
    }
    
    if (actionType == LikeActionDelete) {
        [manager deleteLikeFrom:contentType
                         withID:contentId
                         onWall:wallId
                           type:@"user"
                      onSuccess:^(id result) {
                          completion(result);
                      }
                      onFailure:^(NSError *error, NSInteger statusCode) {
                          NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                      }];
    }
}

@end
