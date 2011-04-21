//
//  MATCDatabaseController.m
//  SimpleCoreData
//
//  Created by Brad Larson on 2/23/2010.
//

#import "MATCDatabaseController.h"

static MATCDatabaseController *sharedDatabaseController = nil;


@implementation MATCDatabaseController

#pragma mark -
#pragma mark Initialization and teardown

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if (sharedDatabaseController == nil) 
		{
            return [super allocWithZone:zone];
        }
    }
    return sharedDatabaseController;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) 
	{
        if (sharedDatabaseController == nil) 
		{
            self = [super init];
            if (self != nil) 
			{
                sharedDatabaseController = self;
				managedObjectModel = nil;
				managedObjectContext = nil;
				persistentStoreCoordinator = nil;	
            }
        }
    }
    return sharedDatabaseController;
}

- (id)copyWithZone:(NSZone *)zone 
{
	return self; 
}

- (id)retain 
{
	return self; 
}

- (unsigned)retainCount 
{
	return UINT_MAX; 
}

- (void)release 
{
}

- (id)autorelease 
{
	return self; 
}

#pragma mark -
#pragma mark Singleton access

+ (MATCDatabaseController *)sharedDatabaseController;
{
    @synchronized(self) 
	{
        if (sharedDatabaseController == nil) 
		{
            sharedDatabaseController = [[self alloc] init];
        }
    }
    return sharedDatabaseController;
}

#pragma mark -
#pragma mark Core Data interaction

- (void)saveChangesToDatabase;
{
	NSError *error = nil;
	if (managedObjectContext != nil)
	{
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
		{
			NSLog(@"Save error %@, %@", error, [error userInfo]);
			for (id errorObject in [[error userInfo] valueForKey:NSDetailedErrorsKey])
			{
				NSLog(@"Detailed error: %@", errorObject);
			}
			error = nil;
		}
	}	
}

- (NSString *)applicationDocumentsDirectory 
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Accessors

- (NSManagedObjectModel *)managedObjectModel;
{
	if (managedObjectModel != nil) 
	{
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext;
{
	if (managedObjectContext != nil) 
	{
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) 
	{
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
		
		// Configure undo for this context
		NSUndoManager *contextUndoManager = [[NSUndoManager alloc] init];
		[contextUndoManager setLevelsOfUndo:10];
		[managedObjectContext setUndoManager:contextUndoManager];
		[contextUndoManager release];		
    }
    return managedObjectContext;	
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
{
	if (persistentStoreCoordinator != nil) 
	{
        return persistentStoreCoordinator;
    }
	
	//	persistentStoreCoordinator = [self preparePersistentStoreCoordinatorForMigration];
	//    if (persistentStoreCoordinator != nil) {
	//        return persistentStoreCoordinator;
	//    }
	
// NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"database.sqlite"]];
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"database.sqlite"];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	// Put down default db if it doesn't already exist
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
	NSError *error = nil;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) 
	{
        // Handle error
		NSLog(@"ERROR in adding persistent store!");
    }    
	
    return persistentStoreCoordinator;
}


@end
