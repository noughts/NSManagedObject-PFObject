//
//  GetPFObjectOfManagedObjectOperation.m
//  Pods
//
//  Created by noughts on 2015/05/26.
//
//

#import "GetPFObjectOfManagedObjectOperation.h"
#import "ObjectiveRecord.h"
#import "NBULogStub.h"
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

- (BOOL)isConcurrent {
	return YES;
}
- (BOOL)isExecuting {
	return isExecuting;
}
- (BOOL)isFinished {
	return isFinished;
}


/// operationを終わらせる
-(void)finish{
	[self setValue:@(NO) forKey:@"isExecuting"];
	[self setValue:@(YES) forKey:@"isFinished"];
}




- (instancetype)initWithManagedObject:(NSManagedObject*)managedObject completion:(void (^)(PFObject* object))completion{
	if (self = [super init]) {
		_managedObject = managedObject;
		_completion = completion;
	}
	isExecuting = NO;
	isFinished = NO;
	return self;
}


- (void)start {
	NBULogVerbose(@"start");
	[self setValue:@(YES) forKey:@"isExecuting"];
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		NSString* className = NSStringFromClass([_managedObject class]);
		
		// すでにあれば返す。
		// まだリモートにないobjectのpfobjectを同時に取得しようとした時にも対応するため、operation内でも判定する
		NSString* objectId = [_managedObject valueForKeyWithSuppressException:@"remoteId"];
		if( objectId ){
			NBULogVerbose(@"remoteIdがすでにDBにあるので、それからPointerを作成して返します");
			_completion( [PFObject objectWithoutDataWithClassName:className objectId:objectId] );
			[self finish];
			return;
		}
		
		/// リモート作成成功〜ローカルにremoteIdを保存の間にクラッシュするとリモートに重複オブジェクトが作成されてしまうため、作成前にuuidでqueryして重複チェックが必要かと思ったが、
		/// getPFObject後にもろもろのプロパティを設定するため、そのクラッシュ時のPFObjectはただのゾンビオブジェクトになるので放置してもOKか？
		
		NBULogVerbose(@"%@をリモートに作成します...", className);
		PFObject* object = [PFObject objectWithClassName:className];
		[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
			if( succeeded ){
				NBULogVerbose(@"完了!");
				[_managedObject setValue:object.objectId forKey:@"remoteId"];
				_completion( object );
				[[CoreDataManager sharedManager] saveContext];
			}
			[self finish];
		}];
	}];
}




@end




