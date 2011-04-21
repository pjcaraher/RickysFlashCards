//
//  VoicesEditController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoicesEditController.h"
#import "MATCDatabaseController.h"

#define VOICE_NAME_KEY @"name"
#define VOICE_TEMPLATE_NAME_KEY @"name"

#define EDIT_VIEW_DISPLAY_TIME 1.0

@interface VoicesEditController (Private)
- (void) _displayEditNameView;
- (void) _hideEditNameView;
- (void) _initializeDefaults;
@end

@implementation VoicesEditController

@synthesize voice;
@synthesize editNameView;
@synthesize errorMessage;
@synthesize voiceNameText;
@dynamic fetchedTemplatesResultsController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self _initializeDefaults];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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
    return [[self.fetchedTemplatesResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedTemplatesResultsController sections] objectAtIndex:section];
	NSLog(@"Number of rows is %d\n", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSManagedObject *managedObject = [self.fetchedTemplatesResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:VOICE_TEMPLATE_NAME_KEY];
	
	if (nil != managedObject) {
		NSLog(@"managedObject is NOT nil");
	} else {
		NSLog(@"managedObject is nil");
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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedTemplatesResultsController 
{
    NSFetchedResultsController	*retVal = fetchedTemplatesResultsController;
	
	if (retVal == nil) {
		/*
		 Set up the fetched results controller.
		 */
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *managedObjectContext = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
		// Edit the entity name as appropriate.
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"VoiceTemplate" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		
		// Set the batch size to a suitable number.
		[fetchRequest setFetchBatchSize:20];
		
		// Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
		aFetchedResultsController.delegate = self;
		fetchedTemplatesResultsController = [aFetchedResultsController retain];
		
		NSLog(@"fetchedTemplatesResultsController retainCount is %d", [fetchedTemplatesResultsController retainCount]);
		
		[aFetchedResultsController release];
		[fetchRequest release];
		[sortDescriptor release];
		[sortDescriptors release];
		
		NSLog(@"fetchedTemplatesResultsController retainCount is %d", [fetchedTemplatesResultsController retainCount]);
		retVal = fetchedTemplatesResultsController;
		
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

#pragma mark TextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	if(theTextField == voiceNameText)
		[self saveNameUpdate:theTextField];
	return YES;
}

- (IBAction) saveNameUpdate:(id)sender
{
	[[self voice] setValue:voiceNameText.text forKey:VOICE_NAME_KEY];
	[(UITableView *)self.view reloadData];
	[self _hideEditNameView];
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
	[voice release];
	[editNameView release];
	[errorMessage release];
	[voiceNameText release];
	[fetchedTemplatesResultsController release];
	
    [super dealloc];
}


@end

@implementation VoicesEditController (Private)

- (void) _displayEditNameView
{
	CGRect	editNameViewRect = [self.editNameView frame];
	
	voiceNameText.text = [[self voice] valueForKey:VOICE_NAME_KEY];
	errorMessage.text = @"";
	
	// Start the animation
    [UIView beginAnimations:@"Show Name Edit" context:nil];
    [UIView setAnimationDuration:EDIT_VIEW_DISPLAY_TIME];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:[self view] cache:YES];
	self.editNameView.frame = CGRectMake(editNameViewRect.origin.x, 0.0, editNameViewRect.size.width, editNameViewRect.size.height);
	
	[[self view] bringSubviewToFront:self.editNameView];
	
    [UIView commitAnimations];
}

- (void) _hideEditNameView
{
	CGRect	editNameViewRect = [self.editNameView frame];
	
	// Start the animation
    [UIView beginAnimations:@"Show Name Edit" context:nil];
    [UIView setAnimationDuration:EDIT_VIEW_DISPLAY_TIME];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:[self view] cache:YES];
	self.editNameView.frame = CGRectMake(editNameViewRect.origin.x, 360.0, editNameViewRect.size.width, editNameViewRect.size.height);
	
	[[self view] bringSubviewToFront:self.editNameView];
	
    [UIView commitAnimations];
}

- (void) _initializeDefaults
{
	// For some reason, Interface Builder won't let me edit the x,y coordinates
	// of the editNameView.  So, we have to set them here.
	CGRect	editNameViewRect = [self.editNameView frame];
	self.editNameView.frame = CGRectMake(0, 360.0, editNameViewRect.size.width, editNameViewRect.size.height);
}

@end

