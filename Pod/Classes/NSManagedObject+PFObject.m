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
	if( self._pfObject ){
		NBULogVerbose(@"メモリ上にあったPFObjectを返します");
		return self._pfObject;
	}
	
	NSString* className = NSStringFromClass([self class]);
	NSString* objectId = [self valueForKeyWithSuppressException:@"remoteId"];
	
	if( objectId ){
		NBULogVerbose(@"remoteIdがすでにDBにあるので、それからPointerを作成して返します");
		self._pfObject = [PFObject objectWithoutDataWithClassName:className objectId:objectId];
		return self._pfObject;
	}
	

	self._pfObject = [self queryLocalPFObject];
	if( self._pfObject ){
		NBULogVerbose(@"ローカルストレージにPFObjectが見つかったので返します");
		return self._pfObject;
	}
	
	/// ローカルストレージになければ作成してローカルストレージにpin
	NBULogVerbose(@"ローカルストレージにPFObjectを作成します");
	NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
	if( !uuid ){
		uuid = [[NSUUID UUID] UUIDString];
	}
	self._pfObject = [PFObject objectWithClassName:className];
	self._pfObject[@"uuid"] = uuid;
	[self._pfObject pin];// 次回以降の呼び出しででクエリできるように
	[self setValueWithSuppressException:uuid forKey:@"uuid"];
	return self._pfObject;
}


-(PFObject*)queryLocalPFObject{
	NSString* className = NSStringFromClass([self class]);
	NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
	if( !uuid ){
		return nil;
	}
	PFQuery* query = [PFQuery queryWithClassName:className];
	[query fromLocalDatastore];
	[query whereKey:@"uuid" equalTo:uuid];
	return [query getFirstObject];
}





-(PFObject*)_pfObject {
	return objc_getAssociatedObject(self, @selector(set_pfObject:));
}
-(void)set_pfObject:(PFObject*)val {
	objc_setAssociatedObject(self, _cmd, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
