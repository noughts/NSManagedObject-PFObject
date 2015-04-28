// :: Framework ::
#import <NBULog.h>
#import <Parse.h>
#import <objc/runtime.h>
// :: Other ::
#import "NSManagedObject+PFObject.h"


@implementation NSManagedObject (PFObject)




-(PFObject*)pfobject{
	if( !self._pfObject ){
		/// メモリに乗ってなければローカルをクエリしてみる
		self._pfObject = [self queryLocalPFObject];
	}
	
	if( !self._pfObject ){
		/// ローカルになければ作成してローカルにpin
		NBULogVerbose(@"ローカルにPFObjectを作成します");
		NSString* uuid = [[NSUUID UUID] UUIDString];
		self._pfObject = [PFObject objectWithClassName:@"Thread"];
		self._pfObject[@"uuid"] = uuid;
		[self._pfObject pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];/// 次回以降の起動でクエリできるように
		[self setValue:uuid forKey:@"uuid"];
	}
	return self._pfObject;
}

-(PFObject*)queryLocalPFObject{
	NSString* uuid = [self valueForKey:@"uuid"];
	if( !uuid ){
		return nil;
	}
	NBULogVerbose(@"ローカルをクエリします");
	PFQuery* query = [PFQuery queryWithClassName:@"Thread"];
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
