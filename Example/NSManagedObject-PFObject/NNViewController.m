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

- (void)viewDidLoad{
    [super viewDidLoad];
}

-(IBAction)onAddButtonTap:(id)sender{
	Thread* thread = [Thread create];
	[thread save];
	[self.tableView reloadData];
}

-(IBAction)onRefreshButtonTap:(id)sender{
	[self.tableView reloadData];
}

-(Thread*)threadAtIndexPath:(NSIndexPath*)indexPath{
	NSArray* threads = [Thread all];
	return threads[indexPath.row];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	Thread* thread = [self threadAtIndexPath:indexPath];
	[thread.pfobject saveEventually:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
		if( error ){
			NBULogError(@"%@", error);
		}
		NBULogInfo(@"%@",thread.pfobject.objectId);
		[self.tableView reloadData];
	}];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [Thread count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	Thread* thread = [self threadAtIndexPath:indexPath];
	
	cell.textLabel.text = thread.uuid;
	cell.detailTextLabel.text = thread.pfobject.objectId;
	NBULogInfo(@"%@",thread.pfobject);
	
	return cell;
}




@end
