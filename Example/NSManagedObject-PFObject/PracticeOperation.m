//
//  PracticeOperation.m
//  NSManagedObject-PFObject
//
//  Created by noughts on 2015/05/26.
//  Copyright (c) 2015年 koichi yamamoto. All rights reserved.
//

#import "PracticeOperation.h"

@implementation PracticeOperation{
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