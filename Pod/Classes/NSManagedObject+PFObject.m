/*
 
 モデルにuuid(String)プロパティを用意しておきましょう。
 
 */

// :: Framework ::
#import <NBULog.h>
#import <Parse.h>
#import <objc/runtime.h>
// :: Other ::
#import "NSManagedObject+PFObject.h"
#import "GetPFObjectOfManagedObjectOperation.h"


static NSOperationQueue* _managedObjectPfObjectQuery_queue;

@implementation NSManagedObject (PFObject)

-(id)valueForKeyWithSuppressException:(NSString *)key{
	id result;
	@try {
		result = [self valueForKey:key];
	} @catch (NSException *exception) {
		NBULogError(@"%@", exception);
	} @finally {}
	return result;
}

-(void)setValueWithSuppressException:(id)value forKey:(NSString *)key{
	@try {
		[self setValue:value forKey:key];
	} @catch (NSException *exception) {
		NBULogError(@"%@", exception);
	} @finally {}
}


-(void)getPFObjectInBackground:(void (^)(PFObject* object))completion{
	if( !_managedObjectPfObjectQuery_queue ){
		_managedObjectPfObjectQuery_queue = [NSOperationQueue new];
		_managedObjectPfObjectQuery_queue.maxConcurrentOperationCount = 1;
	}
	
	GetPFObjectOfManagedObjectOperation* op = [[GetPFObjectOfManagedObjectOperation alloc] initWithManagedObject:self completion:completion];
	[_managedObjectPfObjectQuery_queue addOperation:op];
}



-(PFObject*)_pfObject {
	return objc_getAssociatedObject(self, @selector(set_pfObject:));
}
-(void)set_pfObject:(PFObject*)val {
	objc_setAssociatedObject(self, _cmd, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end



































