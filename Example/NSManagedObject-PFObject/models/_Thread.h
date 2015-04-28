// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.h instead.

@import CoreData;

extern const struct ThreadAttributes {
	__unsafe_unretained NSString *notificationEnabled;
	__unsafe_unretained NSString *remoteId;
	__unsafe_unretained NSString *targetUserId;
	__unsafe_unretained NSString *uuid;
} ThreadAttributes;

@interface ThreadID : NSManagedObjectID {}
@end

@interface _Thread : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ThreadID* objectID;

@property (nonatomic, strong) NSNumber* notificationEnabled;

@property (atomic) BOOL notificationEnabledValue;
- (BOOL)notificationEnabledValue;
- (void)setNotificationEnabledValue:(BOOL)value_;

//- (BOOL)validateNotificationEnabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* remoteId;

//- (BOOL)validateRemoteId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* targetUserId;

//- (BOOL)validateTargetUserId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uuid;

//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;

@end

@interface _Thread (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveNotificationEnabled;
- (void)setPrimitiveNotificationEnabled:(NSNumber*)value;

- (BOOL)primitiveNotificationEnabledValue;
- (void)setPrimitiveNotificationEnabledValue:(BOOL)value_;

- (NSString*)primitiveRemoteId;
- (void)setPrimitiveRemoteId:(NSString*)value;

- (NSString*)primitiveTargetUserId;
- (void)setPrimitiveTargetUserId:(NSString*)value;

- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;

@end
