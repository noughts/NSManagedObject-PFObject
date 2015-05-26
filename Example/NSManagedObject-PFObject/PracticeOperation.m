//
//  PracticeOperation.m
//  NSManagedObject-PFObject
//
//  Created by noughts on 2015/05/26.
//  Copyright (c) 2015年 koichi yamamoto. All rights reserved.
//

#import "PracticeOperation.h"
// :: Framework ::
#import <NBULog.h>
#import <Parse.h>


@implementation PracticeOperation{
	PFArrayResultBlock _block;
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


-(instancetype)initWithBlock:(PFArrayResultBlock)block{
	if( self = [super init] ){
		_block = block;
	}
	return self;
}


- (id)initWithURL:(NSURL *)targetUrl{
	self = [super init];
	if (self) {
		url = targetUrl;
	}
	isExecuting = NO;
	isFinished = NO;
	return self;
}


- (void)start {
	NBULogVerbose(@"start");
	[self setValue:@(YES) forKey:@"isExecuting"];

	PFQuery* query = [PFQuery queryWithClassName:@"TestObject"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error){
		NBULogVerbose(@"complete");
		_block( objects, error );
		[self setValue:@(NO) forKey:@"isExecuting"];
		[self setValue:@(YES) forKey:@"isFinished"];
		
	}];

}

@end