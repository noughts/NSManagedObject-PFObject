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
@property (nonatomic) BOOL _processing;/// PFObject取得処理中かどうか？同時にPFObjectを取得しようとした時に、処理がバッティングするのを防ぐためのフラグです。


-(void)getPFObjectInBackground:(void (^)(PFObject* object))completion;
//-(PFObject*)pfobject;



@end
