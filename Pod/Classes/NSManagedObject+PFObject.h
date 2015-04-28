//
//  NSManagedObject+PFObject.h
//  Pods
//
//  Created by noughts on 2015/04/28.
//
//

#import <CoreData/CoreData.h>
@class PFObject;

@interface NSManagedObject (PFObject)
 @property (nonatomic) PFObject *_pfObject;


-(PFObject*)pfobject;

@end
