//
//  NNViewController.m
//  NSManagedObject-PFObject
//
//  Created by koichi yamamoto on 04/28/2015.
//  Copyright (c) 2014 koichi yamamoto. All rights reserved.
//

#import "NNViewController.h"
// :: Framework ::
#import <NBULog.h>
#import <NSManagedObject+PFObject.h>
#import <ObjectiveRecord.h>
#import <Parse.h>
// :: Other ::
#import "Thread.h"


@implementation NNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	Thread* thread = [Thread create];
	NBULogDebug(@"%@", thread.pfobject);
	NBULogDebug(@"%@", thread.pfobject);
	[thread save];
	
	NBULogVerbose(@"---------------------------");
	
	NSArray* threads = [Thread all];
	for (Thread* thread in threads) {
		NBULogDebug(@"%@", thread.pfobject);
		thread.pfobject[@"hoge"] = @"fuga";
		[thread.pfobject saveEventually];
	}
	
}


@end
