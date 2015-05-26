//
//  GetPFObjectOfManagedObjectOperation.m
//  Pods
//
//  Created by noughts on 2015/05/26.
//
//

#import "GetPFObjectOfManagedObjectOperation.h"
// :: Framework ::
#import <NBULog.h>

// :: Other ::
#import "NSManagedObject+PFObject.h"

@implementation GetPFObjectOfManagedObjectOperation{
	NSManagedObject* _managedObject;
	void (^_completion)(PFObject* object);
	BOOL isExecuting, isFinished;
}
// 監視するキー値の設定
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
	if ([key isEqualToString:@"isExecuting"] ||
		[key isEqualToString:@"isFinished"]) {
		return YES;
	}
	return [super automaticallyNotifiesObserversForKey:key];
}
// YES を返さないとメインスレッド以外で動かなくなる
- (BOOL)isConcurrent {
	return YES;
}
- (BOOL)isExecuting {
	return isExecuting;
}
- (BOOL)isFinished {
	return isFinished;
}
- (id)initWithCompletion:(void (^)(PFObject* object))completion{
	if (self = [super init]) {
		_completion = completion;
	}
	isExecuting = NO;
	isFinished = NO;
	return self;
}


- (void)start {
	if( _managedObject._pfObject ){
		NBULogVerbose(@"メモリ上にあったPFObjectを返します");
		_completion( _managedObject._pfObject );
		return;
	}
	
	NSString* className = NSStringFromClass([self class]);
	NSString* objectId = [_managedObject valueForKeyWithSuppressException:@"remoteId"];
	
	if( objectId ){
		NBULogVerbose(@"remoteIdがすでにDBにあるので、それからPointerを作成して返します");
		_managedObject._pfObject = [PFObject objectWithoutDataWithClassName:className objectId:objectId];
		_completion( _managedObject._pfObject );
		return;
	}
	
	
	[self queryLocalPFObjectInBackground:^(PFObject *object) {
		_managedObject._pfObject = object;
		if( object ){
			NBULogVerbose(@"ローカルストレージにPFObjectが見つかったので返します");
			_completion( object);
			return;
		}
		
		/// ローカルストレージになければ作成してローカルストレージにpin
		NBULogVerbose(@"ローカルストレージにPFObjectを作成します");
		NSString* uuid = [_managedObject valueForKeyWithSuppressException:@"uuid"];
		if( !uuid ){
			uuid = [[NSUUID UUID] UUIDString];
		}
		_managedObject._pfObject = [PFObject objectWithClassName:className];
		_managedObject._pfObject[@"uuid"] = uuid;
		[_managedObject._pfObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
			[_managedObject setValueWithSuppressException:uuid forKey:@"uuid"];
			[_managedObject.managedObjectContext save:nil];
			_completion( _managedObject._pfObject );
		}];
	}];
	
}


-(void)queryLocalPFObjectInBackground:(void (^)(PFObject* object))completion{
	NSString* uuid = [_managedObject valueForKeyWithSuppressException:@"uuid"];
	if( !uuid ){
		completion( nil );
		return;
	}
	NSString* className = NSStringFromClass([_managedObject class]);
	PFQuery* query = [PFQuery queryWithClassName:className];
	[query fromLocalDatastore];
	[query whereKey:@"uuid" equalTo:uuid];
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
		completion( object );
	}];
}




@end



