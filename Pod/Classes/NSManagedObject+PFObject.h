#import <CoreData/CoreData.h>
@class PFObject;

@interface NSManagedObject (PFObject)




/// 関連するポインターPFObjectを返す。無ければ作成。もしリモートに取りに行く必要が無ければYESを返すので、ローディング表示の調整に使ってください。
-(BOOL)getPFObjectInBackground:(void (^)(PFObject* object))completion;
-(void)setValueWithSuppressException:(id)value forKey:(NSString *)key;
-(id)valueForKeyWithSuppressException:(NSString *)key;





@end
