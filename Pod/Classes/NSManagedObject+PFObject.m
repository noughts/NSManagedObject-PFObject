/*
 
 モデルにuuid(String)プロパティを用意しておきましょう。
 
 */

// :: Framework ::
#import "NBULogStub.h"
#import "ObjectiveRecord.h"
#import "Parse.h"
#import <objc/runtime.h>
// :: Other ::
#import "GetPFObjectOfManagedObjectOperation.h"
#import "NSManagedObject+PFObject.h"


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


-(BOOL)getPFObjectInBackground:(void (^)(PFObject* object))completion{
	if( !_managedObjectPfObjectQuery_queue ){
		_managedObjectPfObjectQuery_queue = [NSOperationQueue new];
		_managedObjectPfObjectQuery_queue.maxConcurrentOperationCount = 1;
	}
	
	// もしremoteIdがすでにあれば、すぐにblock実行
	NSString* remoteId = [self valueForKeyPath:@"remoteId"];
	if( remoteId ){
		NBULogVerbose(@"ローカルにremoteIdがあるのでそこからポインターPFObjectを作成して返します。");
		NSString* className = NSStringFromClass([self class]);
		completion( [PFObject objectWithoutDataWithClassName:className objectId:remoteId] );
		return YES;
	}
	
	
	GetPFObjectOfManagedObjectOperation* op = [[GetPFObjectOfManagedObjectOperation alloc] initWithManagedObject:self completion:completion];
	[_managedObjectPfObjectQuery_queue addOperation:op];
	return NO;
}




@end



































