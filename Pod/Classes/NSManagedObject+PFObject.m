/*
 
 モデルにuuid(String)プロパティを用意しておきましょう。
 
 */

// :: Framework ::
#import <NBULog.h>
#import <Parse.h>
#import <objc/runtime.h>
// :: Other ::
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
	
	
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		while (self._processing) {
//			NBULogVerbose( @"PFObject取得処理中なので待機します" );
		}
		
		self._processing = YES;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self queryLocalPFObjectInBackground:^(PFObject *object) {
				self._pfObject = object;
				if( self._pfObject ){
					NBULogVerbose(@"ローカルストレージにPFObjectが見つかったので返します");
					self._processing = NO;
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
					self._processing = NO;
					completion( self._pfObject );
				}];
			}];
		});
	});
	
	

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


















@interface GetPFObjectOperation : NSOperation
@end

@implementation GetPFObjectOperation{
	NSURL *url;
	NSMutableData *responseData;
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
- (id)initWithURL:(NSURL *)targetUrl {
	self = [super init];
	if (self) {
		url = targetUrl;
	}
	isExecuting = NO;
	isFinished = NO;
	return self;
}


- (void)start {
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
	if (conn != nil) {
		// NSURLConnection は RunLoop をまわさないとメインスレッド以外で動かない
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (isExecuting);
	}
}
// レスポンスヘッダ受け取り
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
}
// データの受け取り
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}
// 通信エラー
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", @"エラー");
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}
// 通信終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", responseString);
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}
@end





















