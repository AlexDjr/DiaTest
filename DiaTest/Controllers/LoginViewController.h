//
//  LoginViewController.h
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AccessToken;

typedef void(^LoginCompletionBlock)(AccessToken* _Nullable token);

@interface LoginViewController : UIViewController
- (id) initWithCompletionBlock:(LoginCompletionBlock) completion;
@end

NS_ASSUME_NONNULL_END
