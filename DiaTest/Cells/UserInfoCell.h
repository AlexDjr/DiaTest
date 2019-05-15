//
//  UserInfoCell.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKContentCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoCell : VKContentCell
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@end

NS_ASSUME_NONNULL_END
