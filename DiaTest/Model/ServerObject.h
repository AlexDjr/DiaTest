//
//  ServerObject.h
//  APITest
//
//  Created by Alex Delin on 09/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerObject : NSObject
- (id) initWithServerResponse:(NSDictionary*) responseObject;
@end
