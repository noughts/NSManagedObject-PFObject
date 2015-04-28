// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.m instead.

#import "_Thread.h"

const struct ThreadAttributes ThreadAttributes = {
	.notificationEnabled = @"notificationEnabled",
	.remoteId = @"remoteId",
	.targetUserId = @"targetUserId",
	.uuid = @"uuid",
};

@implementation ThreadID
@end

@implementation _Thread

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Thread";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:moc_];
}

- (ThreadID*)objectID {
	return (ThreadID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"notificationEnabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notificationEnabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic notificationEnabled;

- (BOOL)notificationEnabledValue {
	NSNumber *result = [self notificationEnabled];
	return [result boolValue];
}

- (void)setNotificationEnabledValue:(BOOL)value_ {
	[self setNotificationEnabled:@(value_)];
}

- (BOOL)primitiveNotificationEnabledValue {
	NSNumber *result = [self primitiveNotificationEnabled];
	return [result boolValue];
}

- (void)setPrimitiveNotificationEnabledValue:(BOOL)value_ {
	[self setPrimitiveNotificationEnabled:@(value_)];
}

@dynamic remoteId;

@dynamic targetUserId;

@dynamic uuid;

@end

