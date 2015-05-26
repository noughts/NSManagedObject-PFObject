//
//  PracticeOperation.h
//  NSManagedObject-PFObject
//
//  Created by noughts on 2015/05/26.
//  Copyright (c) 2015年 koichi yamamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>

@interface PracticeOperation : NSOperation

-(instancetype)initWithBlock:(PFArrayResultBlock)block;

@end
