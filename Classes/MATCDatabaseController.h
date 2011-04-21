//
//  MATCDatabaseController.h
//  SimpleCoreData
//
//  Created by Brad Larson on 2/23/2010.
//

#import <Foundation/Foundation.h>


@interface MATCDatabaseController : NSObject 
{
	// Core Data stack
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;	
	
}

@property(nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Singleton access
+ (MATCDatabaseController *)sharedDatabaseController;

// Core Data interaction
- (void)saveChangesToDatabase;
- (NSString *)applicationDocumentsDirectory;

@end
