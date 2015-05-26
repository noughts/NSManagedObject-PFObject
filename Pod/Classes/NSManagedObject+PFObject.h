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



-(void)setValueWithSuppressException:(id)value forKey:(NSString *)key;

-(id)valueForKeyWithSuppressException:(NSString *)key;
-(void)getPFObjectInBackground:(void (^)(PFObject* object))completion;




@end
