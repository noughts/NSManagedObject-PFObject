//
//  GetPFObjectOfManagedObjectOperation.h
//  Pods
//
//  Created by noughts on 2015/05/26.
//
//

// :: Framework ::
#import <Foundation/Foundation.h>
#import <Parse.h>

@interface GetPFObjectOfManagedObjectOperation : NSOperation

- (id)initWithCompletion:(void (^)(PFObject* object))completion;

@end
