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


-(void)getPFObjectInBackground:(void (^)(PFObject* object))completion{
	if( self._pfObject ){
		NBULogVerbose(@"メモリ上にあったPFObjectを返します");
		completion( self._pfObject );
		return;
	}
	
	NSString* className = NSStringFromClass([self class]);
	NSString* objectId = [self valueForKeyWithSuppressException:@"remoteId"];
	
	if( objectId ){
		NBULogVerbose(@"remoteIdがすでにDBにあるので、それからPointerを作成して返します");
		self._pfObject = [PFObject objectWithoutDataWithClassName:className objectId:objectId];
		completion( self._pfObject );
		return;
	}
	
	[self queryLocalPFObjectInBackground:^(PFObject *object) {
		self._pfObject = object;
		if( self._pfObject ){
			NBULogVerbose(@"ローカルストレージにPFObjectが見つかったので返します");
			completion( self._pfObject );
			return;
		}
		
		/// ローカルストレージになければ作成してローカルストレージにpin
		NBULogVerbose(@"ローカルストレージにPFObjectを作成します");
		NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
		if( !uuid ){
			uuid = [[NSUUID UUID] UUIDString];
		}
		self._pfObject = [PFObject objectWithClassName:className];
		self._pfObject[@"uuid"] = uuid;
		[self._pfObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
			[self setValueWithSuppressException:uuid forKey:@"uuid"];
			[self.managedObjectContext save:nil];
			completion( self._pfObject );
		}];
	}];
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

-(void)queryLocalPFObjectInBackground:(void (^)(PFObject* object))completion{
	NSString* className = NSStringFromClass([self class]);
	NSString* uuid = [self valueForKeyWithSuppressException:@"uuid"];
	if( !uuid ){
		completion( nil );
		return;
	}
	PFQuery* query = [PFQuery queryWithClassName:className];
	[query fromLocalDatastore];
	[query whereKey:@"uuid" equalTo:uuid];
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
		completion( object );
	}];
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


-(BOOL)_processing {
	NSNumber *number = objc_getAssociatedObject(self, @selector(set_processing:));
	return [number boolValue];
}
-(void)set_processing:(BOOL)_processing {
	objc_setAssociatedObject(self, _cmd, @(_processing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
