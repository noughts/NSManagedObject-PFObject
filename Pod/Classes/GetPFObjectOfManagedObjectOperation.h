//
//  GetPFObjectOfManagedObjectOperation.h
//  Pods
//
//  Created by noughts on 2015/05/26.
//
//

// :: Framework ::
#import <Foundation/Foundation.h>
#import "Parse.h"
@import CoreData;

@interface GetPFObjectOfManagedObjectOperation : NSOperation

- (instancetype)initWithManagedObject:(NSManagedObject*)managedObject completion:(void (^)(PFObject* object))completion;

@end
