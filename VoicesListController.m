//
//  VoicesListController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/5/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "VoicesListController.h"
#import "MATCDatabaseController.h"
#import "VoiceEditController.h"
#import <CoreData/CoreData.h>
#import "RickysFlashCardsAppDelegate.h"
#import "RFCVoiceListUITableViewCell.h"

#define SECTION_NEW_VOICE 0
#define SECTION_EXISTING_VOICE 1

@interface VoicesListController (Private)
- (NSManagedObject *)newVoice;
@end	

@implementation VoicesListController

@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
 */

- (void)viewWillAppear:(BOOL)animated {
	// Guarantee a data refresh by clearing out
	// the fetchedResultsConroller
	if (nil != fetchedResultsController) {
		[fetchedResultsController release];
		fetchedResultsController = nil;
		[(UITableView*)self.view reloadData];
	}
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// The number of sections is fetchted + 1 for new.
    return [[self.fetchedResultsController sections] count] + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numRows = 0;
	NSInteger modifiedSection = section - 1;
	id <NSFetchedResultsSectionInfo> sectionInfo;
	
	switch (section) {
		case SECTION_NEW_VOICE:
			numRows = 1;
			break;
		case SECTION_EXISTING_VOICE:
			sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:modifiedSection];
			numRows = [sectionInfo numberOfObjects];
			break;
		default:
			break;
	}
	
	return numRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
    NSInteger section = indexPath.section;
    static NSString *CellIdentifier = @"Cell";
	NSManagedObject *managedObject = nil;
	NSIndexPath	*modifiedIndexPath;
	NSString *name = nil;
    
    // RFCVoiceListUITableViewCell *cell = (RFCVoiceListUITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		/*
        cell = [[[RFCVoiceListUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setEditButtonTarget:self action:@selector(editVoicesButtonPressed:event:)];
		 */
	}
	
	/*
	Create a button (it can be transparent) to set over the accessory view.
	This button will link up to accessoryButtonTappedForRowWithIndexPath
	For testing, have the button have a red color.  This will help to gauge its size
	*/
	
	switch (section) {
		case SECTION_NEW_VOICE:
			cell.textLabel.text = @"New Voice";
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case SECTION_EXISTING_VOICE:
			// Decrement the indexPath.section to match the fetch
			modifiedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
			NSLog(@"modifiedIndexPath is %d, %d", modifiedIndexPath.row, modifiedIndexPath.section);
			NSLog(@"indexPath is %d, %d", indexPath.row, indexPath.section);
			managedObject = [self.fetchedResultsController objectAtIndexPath:modifiedIndexPath];
			name = [[managedObject valueForKey:@"name"] description];
			cell.textLabel.text = name;
			
			if (TRUE ==[delegate voiceNameIsEditable:name]) {
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}

			if ([name compare:[delegate currentVoiceName]] == NSOrderedSame) {
				cell.textLabel.textColor = [UIColor blackColor];
			} else {
				cell.textLabel.textColor = [UIColor grayColor];
			}
			
			if (nil != managedObject) {
				NSLog(@"managedObject is NOT nil");
			} else {
				NSLog(@"managedObject is nil");
			}
			break;
		default:
			break;
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int	row = indexPath.row;
	int section = indexPath.section;
	VoiceEditController	*voiceEditController = [[VoiceEditController alloc] initWithNibName:@"VoiceEditController" bundle:nil];
	NSManagedObject *voice = nil;
	NSIndexPath	*modifiedIndexPath;
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	
	switch (section) {
		case SECTION_NEW_VOICE:
			// Create a new Voice object
			voice = [self newVoice];
			voiceEditController.voice = voice;
			voiceEditController.title = @"Edit Voice";
			[self.navigationController pushViewController:voiceEditController animated:YES];
			
			break;
		case SECTION_EXISTING_VOICE:
			modifiedIndexPath = [NSIndexPath indexPathForRow:row inSection:section - 1];
			voice = [self.fetchedResultsController objectAtIndexPath:modifiedIndexPath];
			[delegate setCurrentVoiceName:[voice valueForKey:@"name"]];
			[self.tableView reloadData];
			break;
		default:
			break;
	}
	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	int	row = indexPath.row;
	int section = indexPath.section;
	VoiceEditController	*voiceEditController = [[VoiceEditController alloc] initWithNibName:@"VoiceEditController" bundle:nil];
	NSManagedObject *voice = nil;
	NSIndexPath	*modifiedIndexPath;
	
	switch (section) {
		case SECTION_NEW_VOICE:
			// Create a new Voice object
			voice = [self newVoice];
			voiceEditController.voice = voice;
			voiceEditController.title = @"Edit Voice";
			
			break;
		case SECTION_EXISTING_VOICE:
			modifiedIndexPath = [NSIndexPath indexPathForRow:row inSection:section - 1];
			voice = [self.fetchedResultsController objectAtIndexPath:modifiedIndexPath];
			voiceEditController.voice = voice;
			voiceEditController.title = [voice valueForKey:@"name"];
			[self.tableView reloadData];
			break;
		default:
			break;
	}
	
	[self.navigationController pushViewController:voiceEditController animated:YES];
}

- (IBAction) editVoicesButtonPressed:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[fetchedResultsController release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    NSFetchedResultsController	*retVal = fetchedResultsController;
	
	if (retVal == nil) {
		/*
		 Set up the fetched results controller.
		 */
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *managedObjectContext = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
		// Edit the entity name as appropriate.
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		
		// Set the batch size to a suitable number.
		[fetchRequest setFetchBatchSize:20];
		
		// Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
		aFetchedResultsController.delegate = self;
		self.fetchedResultsController = aFetchedResultsController;
		
		[aFetchedResultsController release];
		[fetchRequest release];
		[sortDescriptor release];
		[sortDescriptors release];
		
		retVal = self.fetchedResultsController;
		
		NSError *error = nil;
		if (![retVal performFetch:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately. 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
	}
	
	return retVal;
}    

@end

@implementation VoicesListController (Private)

- (NSManagedObject *)newVoice {
	
	// Create a new instance of the entity managed by the 
	// fetched results controller.
    NSManagedObjectContext *context = [[self fetchedResultsController] managedObjectContext];
    NSEntityDescription *entity = [[[self fetchedResultsController] fetchRequest] entity];
    NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
								  inManagedObjectContext:context];
	/*
	NSError *error;
	
	[newVoice setValue:@"PJC" forKey:@"name"];
	
    if (![context save:&error]) {
        NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
    }
	*/
	
	return newVoice;
}

@end


