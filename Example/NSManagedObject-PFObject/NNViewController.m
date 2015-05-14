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


@implementation NNViewController{
	Thread* _thread;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	
	NSString* uuid = @"nroahgueralhjcekwa";
	_thread = [Thread where:@{@"uuid":uuid}].firstObject;
	
	if( !_thread ){
		_thread = [Thread create];
		_thread.uuid = uuid;
		[_thread save];
	}
	
	NSLog( @"%@", _thread );
	
}


-(IBAction)onChange1ButtonTap:(id)sender{
	[_thread getPFObjectInBackground:^(PFObject *object) {
		object[@"hoge"] = @"fuga";
		[object saveEventually];
	}];

}


-(IBAction)onChange2ButtonTap:(id)sender{
	[_thread getPFObjectInBackground:^(PFObject *object) {
		object[@"piyo"] = @"baga";
		[object saveEventually];
	}];
}


-(IBAction)onBothButtonTap:(id)sender{
	[_thread getPFObjectInBackground:^(PFObject *object) {
		object[@"hoge"] = @"fuga";
		[object saveEventually];
	}];
	[_thread getPFObjectInBackground:^(PFObject *object) {
		object[@"piyo"] = @"baga";
		[object saveEventually];
	}];
}

@end
