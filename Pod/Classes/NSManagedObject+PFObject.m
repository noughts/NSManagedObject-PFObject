/*
 
 モデルにuuid(String)プロパティを用意しておきましょう。
 
 */

// :: Framework ::
#import <NBULog.h>
#import <Parse.h>
#import <objc/runtime.h>
// :: Other ::
#import "NSManagedObject+PFObject.h"


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



-(PFObject*)pfobject{
	NSString* className = NSStringFromClass([self class]);
	NSString* objectId = [self valueForKeyWithSuppressException:@"remoteId"];
	
	if( objectId ){
		return [PFObject objectWithoutDataWithClassName:className objectId:objectId];
	}
	
	if( !self._pfObject ){
		/// メモリに乗ってなければローカルをクエリしてみる
		self._pfObject = [self queryLocalPFObject];
	}
	
	if( !self._pfObject ){
		/// ローカルになければ作成してローカルにpin
		NBULogVerbose(@"ローカルにPFObjectを作成します");
		NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
		if( !uuid ){
			uuid = [[NSUUID UUID] UUIDString];
		}
		self._pfObject = [PFObject objectWithClassName:className];
		self._pfObject[@"uuid"] = uuid;
		[self._pfObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];/// 次回以降の起動でクエリできるように
		[self setValueWithSuppressException:uuid forKey:@"uuid"];
	}
	return self._pfObject;
}


-(PFObject*)queryLocalPFObject{
	NSString* className = NSStringFromClass([self class]);
	NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
	if( !uuid ){
		return nil;
	}
	NBULogVerbose(@"ローカルをクエリします");
	PFQuery* query = [PFQuery queryWithClassName:className];
	[query fromLocalDatastore];
	[query whereKey:@"uuid" equalTo:uuid];
	return [query getFirstObject];// バックグラウンドで行うと処理が複雑になるので、メインスレッドで。
}




-(PFObject*)_pfObject {
	return objc_getAssociatedObject(self, @selector(set_pfObject:));
}
-(void)set_pfObject:(PFObject*)val {
	objc_setAssociatedObject(self, _cmd, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
